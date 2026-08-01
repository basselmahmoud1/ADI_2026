module spi_memory (
    input logic clk,
    input logic rst_n,
    input logic [14:0] addr,
    input logic [7:0] wr_data,
    input logic wr_en,
    output logic [7:0] rd_data
);
    `define SIM
    
    logic [7:0] mem [0:32767];

    assign rd_data = mem[addr];
    `ifdef SIM
        initial begin
            $readmemh("mem_init.txt", mem);
        end
    `endif
    always_ff @(posedge clk) begin
        if (wr_en) begin
            mem[addr] <= wr_data;
        end
    end

endmodule
