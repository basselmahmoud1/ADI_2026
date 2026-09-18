import Complex_pack::*;

module FFT_RAM #(
    parameter DATA_WIDTH = 12,
    parameter ADDR_WIDTH = 3,
)(
    input                                     clk,
    input                                     we,       // Write Enable (driven by RAM_WRITE)
    input                    [ADDR_WIDTH-1:0] addr,     // Address (driven by RAM_ADDR)
    input  complex_data_t                     din,
    output complex_data_t                     dout
);

    // Memory array declaration
    complex_data_t mem [ADDR_WIDTH-1:0];

    always_ff @(posedge clk) begin
        if (we) begin
            mem[addr] <= din;
        end
        // Synchronous read
        dout <= mem[addr]; 
    end

endmodule