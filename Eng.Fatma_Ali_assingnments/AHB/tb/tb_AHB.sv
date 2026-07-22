`timescale 1ns/1ps
import AHB_pkg::*;

module tb_AHB;

    parameter DATA_WIDTH    = 32 ;
    parameter ADDR_WIDTH    = 32 ;
    parameter SLAVE_NUM     = 4  ;
    parameter SLAVE_SIZE_KB = 1  ;

    logic hclk;
    logic hresetn;

    initial begin
        hclk = 0;
        forever #5 hclk = ~hclk;
    end

    initial begin
        hresetn = 0;
        #20 hresetn = 1;
    end

    logic valid;
    logic write;
    logic end_burst;
    size_e size;
    burst_e burst;
    logic [DATA_WIDTH-1:0] w_data;
    logic [ADDR_WIDTH-1:0] addr_in;

    logic [DATA_WIDTH-1:0] hwdata;
    logic [ADDR_WIDTH-1:0] haddr;
    trans_types_e htrans;
    size_e hsize;
    burst_e hburst;
    logic hwrite;
    logic hmastlock;
    logic [3:0] hprot;

    logic [DATA_WIDTH-1:0] hrdata;
    logic hready;
    logic hresp;

    logic [DATA_WIDTH-1:0] r_data;
    logic ready;

    logic [SLAVE_NUM-1:0] hsel;

    logic [SLAVE_NUM-1:0][31:0] hrdata_s;
    logic [SLAVE_NUM-1:0] hresp_s;
    logic [SLAVE_NUM-1:0] hreadyout_s;

    logic [SLAVE_NUM-1:0] hreadyout_ctrl;
    logic [SLAVE_NUM-1:0] hresp_ctrl;
    logic [31:0] read_val;


    AHB_MASTER_LITE #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_master (
        .hclk(hclk),
        .hresetn(hresetn),
        .valid(valid),
        .write(write),
        .end_burst(end_burst),
        .size(size),
        .burst(burst),
        .w_data(w_data),
        .addr_in(addr_in),
        .hready(hready),
        .hresp(hresp),
        .hrdata(hrdata),
        .hwdata(hwdata),
        .haddr(haddr),
        .htrans(htrans),
        .hsize(hsize),
        .hburst(hburst),
        .hwrite(hwrite),
        .hmastlock(hmastlock),
        .hprot(hprot),
        .r_data(r_data),
        .ready(ready)
    );

    AHB_interconnect #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .SLAVE_NUM(SLAVE_NUM),
        .SLAVE_SIZE_KB(SLAVE_SIZE_KB)
    ) u_interconnect (
        .haddr(haddr),
        .hrdata_s(hrdata_s),
        .hresp_s(hresp_s),
        .hreadyout_s(hreadyout_s),
        .hrdata(hrdata),
        .hready(hready),
        .hsel(hsel),
        .hresp(hresp)
    );

    genvar i;
    generate
        for (i = 0; i < SLAVE_NUM; i++) begin : gen_slaves
            AHB_slave_mock #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH),
                .SLAVE_SIZE_KB(SLAVE_SIZE_KB),
                .BASE_ADDR(i * SLAVE_SIZE_KB * 1024)
            ) u_slave (
                .hclk(hclk),
                .hresetn(hresetn),
                .hsel(hsel[i]),
                .haddr(haddr),
                .hwdata(hwdata),
                .hwrite(hwrite),
                .htrans(htrans),
                .hsize(hsize),
                .hreadyout_ctrl(hreadyout_ctrl[i]),
                .hresp_ctrl(hresp_ctrl[i]),
                .hrdata(hrdata_s[i]),
                .hreadyout(hreadyout_s[i]),
                .hresp(hresp_s[i])
            );
        end
    endgenerate

    task do_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        @(negedge hclk);
        valid = 1;
        write = 1;
        addr_in = addr;
        w_data = data;
        burst = SINGLE;
        size = WORD;
        
        do begin @(negedge hclk); end while (!ready);
        valid = 0;
        write = 0;
        
        do begin @(negedge hclk); end while (!hready);
    endtask

    task do_read(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data);
        @(negedge hclk);
        valid = 1;
        write = 0;
        addr_in = addr;
        burst = SINGLE;
        size = WORD;
        
        do begin @(negedge hclk); end while (!ready);
        valid = 0;
        
        do begin @(negedge hclk); end while (!hready);
        data = r_data;
    endtask

    
    // test starting 
    initial begin
        valid = 0;
        write = 0;
        end_burst = 0;
        size = WORD;
        burst = SINGLE;
        w_data = 0;
        addr_in = 0;

        for(int j=0; j<SLAVE_NUM; j++) begin
            hreadyout_ctrl[j] = 1'b1;
            hresp_ctrl[j] = 1'b0;
        end
        
        wait(hresetn);
        #10;
        
        $display("=== Starting Directed Tests ===");
        
        $display("Test 1: Single Write/Read to Slave 0");
        do_write(32'h0000_0004, 32'hDEADBEEF);
        do_read(32'h0000_0004, read_val);
        if (read_val !== 32'hDEADBEEF) $error("Mismatch Slave 0: Expected DEADBEEF, got %h", read_val);
        
        $display("Test 2: Cross Slave Writes and Reads");
        do_write(32'h0000_0404, 32'h11111111);
        do_write(32'h0000_0808, 32'h22222222);
        do_write(32'h0000_0C0C, 32'h33333333);

        do_read(32'h0000_0404, read_val);
        if (read_val !== 32'h11111111) $error("Mismatch Slave 1: Expected 11111111, got %h", read_val);
        
        do_read(32'h0000_0808, read_val);
        if (read_val !== 32'h22222222) $error("Mismatch Slave 2: Expected 22222222, got %h", read_val);

        do_read(32'h0000_0C0C, read_val);
        if (read_val !== 32'h33333333) $error("Mismatch Slave 3: Expected 33333333, got %h", read_val);
        
        $display("Test 3: Back-to-back writes");
        @(negedge hclk);
        valid = 1; write = 1; addr_in = 32'h0000_0010; w_data = 32'hA1A1A1A1; burst = SINGLE;
        do begin @(negedge hclk); end while (!ready);
        
        valid = 1; write = 1; addr_in = 32'h0000_0014; w_data = 32'hB2B2B2B2; burst = SINGLE;
        do begin @(negedge hclk); end while (!ready);
        
        valid = 0; write = 0;
        do begin @(negedge hclk); end while (!hready);
        
        do_read(32'h0000_0010, read_val);
        do_read(32'h0000_0014, read_val);
        
        $display("Test 4: INCR4 Burst Transfer (WORD)");
        @(negedge hclk);
        valid = 1; write = 1; addr_in = 32'h0000_0020; w_data = 32'hC3C3C3C3; burst = INCR4; size = WORD;
        do begin @(negedge hclk); end while (!ready);
        
        w_data = 32'hC4C4C4C4;
        do begin @(negedge hclk); end while (!ready);
        
        w_data = 32'hC5C5C5C5;
        do begin @(negedge hclk); end while (!ready);
        
        w_data = 32'hC6C6C6C6; end_burst = 1;
        do begin @(negedge hclk); end while (!ready);
        
        valid = 0; write = 0; end_burst = 0;
        do begin @(negedge hclk); end while (!hready);
        
        $display("Test 5: INCR8 Burst Transfer (HALFWORD)");
        @(negedge hclk);
        valid = 1; write = 1; addr_in = 32'h0000_0030; w_data = 32'hAAAA; burst = INCR8; size = HALFWORD;
        do begin @(negedge hclk); end while (!ready);
        
        for (int b = 1; b < 8; b++) begin
            w_data = 32'hAAAA + b;
            if (b == 7) end_burst = 1;
            do begin @(negedge hclk); end while (!ready);
        end
        valid = 0; write = 0; end_burst = 0;
        do begin @(negedge hclk); end while (!hready);
        
        $display("Test 6: INCR16 Burst Transfer (BYTE)");
        @(negedge hclk);
        valid = 1; write = 1; addr_in = 32'h0000_0050; w_data = 32'hBB; burst = INCR16; size = BYTE;
        do begin @(negedge hclk); end while (!ready);
        
        for (int b = 1; b < 16; b++) begin
            w_data = 32'hBB + b;
            if (b == 15) end_burst = 1;
            do begin @(negedge hclk); end while (!ready);
        end
        valid = 0; write = 0; end_burst = 0;
        do begin @(negedge hclk); end while (!hready);
        
        $display("=== Starting Corner Cases ===");
        
        $display("Corner Case 1: Slave wait states");
        hreadyout_ctrl[0] = 0;
        @(negedge hclk);
        hreadyout_ctrl[0] = 1;
        
        fork
            begin
                do_write(32'h0000_0040, 32'hABCDABCD);
            end
            begin
                #15; 
                hreadyout_ctrl[0] = 0;
                #20;
                hreadyout_ctrl[0] = 1;
            end
        join

        $display("Corner Case 2: Error response from Slave 1");
        fork
            begin
                do_write(32'h0000_0410, 32'hBAD0BAD0);
            end
            begin
                #15;
                hresp_ctrl[1] = 1;
                hreadyout_ctrl[1] = 0;
                #10;
                hreadyout_ctrl[1] = 1;
                #10;
                hresp_ctrl[1] = 0;
            end
        join

        $display("Corner Case 3: Invalid address space");
        do_write(32'h0000_1000, 32'hFFFFFFFF);

        #100;
        $display("Simulation Finished");
        $stop;
    end

endmodule
