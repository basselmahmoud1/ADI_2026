import AHB_pkg::*;

module AHB_slave_mock #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter SLAVE_SIZE_KB = 1,
    parameter [ADDR_WIDTH-1:0] BASE_ADDR = 0
)(
    input  logic                    hclk,
    input  logic                    hresetn,
    
    // AHB interface
    input  logic                    hsel,
    input  logic [ADDR_WIDTH-1:0]   haddr,
    input  logic [DATA_WIDTH-1:0]   hwdata,
    input  logic                    hwrite,
    input  trans_types_e            htrans,
    input  size_e                   hsize,
    
    // Testbench control overrides
    input  logic                    hreadyout_ctrl,
    input  logic                    hresp_ctrl,
    
    // Slave outputs
    output logic [DATA_WIDTH-1:0]   hrdata,
    output logic                    hreadyout,
    output logic                    hresp
);

    localparam SLAVE_WORDS = (SLAVE_SIZE_KB * 1024) / (DATA_WIDTH/8);
    
    logic [DATA_WIDTH-1:0] memory [SLAVE_WORDS];
    logic [ADDR_WIDTH-1:0] addr_reg;
    logic write_reg;
    logic sel_reg;
    
    logic dec_err;
    assign dec_err = sel_reg && (addr_reg < BASE_ADDR || addr_reg >= (BASE_ADDR + SLAVE_SIZE_KB * 1024));
    
    logic error_cycle_2;
    always_ff @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            error_cycle_2 <= 1'b0;
        end else if (dec_err && !error_cycle_2) begin
            error_cycle_2 <= 1'b1;
        end else begin
            error_cycle_2 <= 1'b0;
        end
    end
    
    
    assign hreadyout = dec_err ? (error_cycle_2 ? 1'b1 : 1'b0) : hreadyout_ctrl;
    assign hresp     = dec_err ? 1'b1 : hresp_ctrl;
    
    always_ff @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            addr_reg <= 0;
            write_reg <= 0;
            sel_reg <= 0;
        end else if (hreadyout && hsel && (htrans == NONSEQ || htrans == SEQ)) begin
            if (!dec_err) begin
                addr_reg <= haddr;
                write_reg <= hwrite;
                sel_reg <= 1'b1;
            end
        end else if (hreadyout) begin
            sel_reg <= 1'b0;
        end
    end

    always_ff @(posedge hclk) begin
        if (sel_reg && write_reg && hreadyout && !dec_err) begin
            memory[addr_reg[$clog2(SLAVE_WORDS)+1:2]] <= hwdata;
        end
    end

    assign hrdata = (sel_reg && !write_reg && !dec_err) ? memory[addr_reg[$clog2(SLAVE_WORDS)+1:2]] : {DATA_WIDTH{1'b0}};

endmodule
