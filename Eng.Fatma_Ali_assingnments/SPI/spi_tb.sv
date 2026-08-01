import spi_types::*;

module spi_tb;

    // Testbench signals
    logic tb_clk;
    logic sclk;
    logic rst_n;
    logic sdi;
    logic csb;
    logic sdo;

    // Internal signals between SPI slave and Memory
    logic [7:0] rd_data;
    logic [14:0] addr;
    logic [7:0] wr_data;
    logic wr_en;

    // Instantiate the DUT (SPI Slave)
    spi_slave u_slave (
        .sclk(sclk),
        .rst_n(rst_n),
        .sdi(sdi),
        .csb(csb),
        .rd_data(rd_data),
        .sdo(sdo),
        .addr(addr),
        .wr_data(wr_data),
        .wr_en(wr_en)
    );

    // Instantiate Memory (Register Map)
    spi_memory u_mem (
        .clk(tb_clk), 
        .rst_n(rst_n),
        .addr(addr),
        .wr_data(wr_data),
        .wr_en(wr_en),
        .rd_data(rd_data)
    );

    // Clock Generation
    initial begin
        tb_clk = 0;
        forever #5 tb_clk = ~tb_clk;
    end

    
    // Write Task (Single or Burst)
    task spi_write(input logic [14:0] waddr, input logic [7:0] wdata_array[]);
        int num_bytes;
        logic [15:0] header;
        
        num_bytes = wdata_array.size();
        header = {1'b0, waddr}; // W=0, MSB first
        
        // Assert CSB
        @(posedge tb_clk);
        csb = 0;
        
        // t_lead 
        repeat(2) @(posedge tb_clk); 
        
        // Send Header (16 bits)
        for (int i = 15; i >= 0; i--) begin
            sdi = header[i];
            sclk = 1;
            @(negedge tb_clk);
            sclk = 0;
            @(posedge tb_clk);
        end
        
        // Send Data bytes (8 bits each)
        for (int b = 0; b < num_bytes; b++) begin
            for (int i = 7; i >= 0; i--) begin
                sdi = wdata_array[b][i];
                sclk = 1;
                @(negedge tb_clk);
                sclk = 0;
                @(posedge tb_clk);
            end
        end
        
        //tlag
        repeat(2) @(posedge tb_clk); 
        csb = 1; 
        
        // Wait between transactions
        repeat(4) @(posedge tb_clk);     
    endtask

    // Read Task (Single or Burst)
    task spi_read(input logic [14:0] raddr, input int num_bytes);
        logic [15:0] header;
        logic [7:0] rdata_array[];
        
        rdata_array = new[num_bytes];
        header = {1'b1, raddr}; // R=1
        
        // Assert CSB
        @(posedge tb_clk);
        csb = 0;
        
        // t_lead 
        repeat(2) @(posedge tb_clk); 
        
        // Send Header (16 bits)
        for (int i = 15; i >= 0; i--) begin
            sdi = header[i];
            sclk = 1;
            @(negedge tb_clk);
            sclk = 0;
            @(posedge tb_clk);
        end
        
        // Receive Data bytes (8 bits each)
        for (int b = 0; b < num_bytes; b++) begin
            for (int i = 7; i >= 0; i--) begin
                sclk = 1;
                @(negedge tb_clk);
                rdata_array[b][i] = sdo; // Sample near falling edge or center
                sclk = 0;
                @(posedge tb_clk);
            end
        end
        
        // t_lag 
        repeat(2) @(posedge tb_clk); 
        csb = 1; 
        
        // Wait between transactions
        repeat(4) @(posedge tb_clk);
        
        $display("Read from addr 0x%04x:", raddr);
        for (int b = 0; b < num_bytes; b++) begin
            $display("  Byte %0d: 0x%02x", b, rdata_array[b]);
        end
    endtask

   
    initial begin
        // Initialize signals
        sclk = 0;
        rst_n = 0;
        csb = 1;
        sdi = 0;
        
        // Apply Reset
        repeat(5) @(posedge tb_clk);
        rst_n = 1;
        repeat(4) @(posedge tb_clk);
        
        // 1. Single Write to address 0x0010
        $display("--- Test 1: Single Write ---");
        spi_write(15'h0010, '{8'hAA});
        
        // 2. Single Read from address 0x0010 (Expected: 0xAA)
        $display("--- Test 2: Single Read ---");
        spi_read(15'h0010, 1);
        
        // 3. Burst Write to address 0x0100 (4 bytes)
        $display("\n--- Test 3: Burst Write ---");
        spi_write(15'h0100, '{8'h11, 8'h22, 8'h33, 8'h44});
        
        // 4. Burst Read from address 0x0100 (4 bytes, Expected: 0x11, 0x22, 0x33, 0x44)
        $display("--- Test 4: Burst Read ---");
        spi_read(15'h0100, 4);
        
        // 5. Another Burst Write
        $display("\n--- Test 5: Burst Write across boundaries ---");
        spi_write(15'h001F, '{8'h55, 8'h66});
        
        // 6. Burst Read to verify
        $display("--- Test 6: Burst Read across boundaries ---");
        spi_read(15'h001F, 2);
        
        repeat(10) @(posedge tb_clk);
        $display("\nSimulation Complete.");
        $finish;
    end
    
endmodule
