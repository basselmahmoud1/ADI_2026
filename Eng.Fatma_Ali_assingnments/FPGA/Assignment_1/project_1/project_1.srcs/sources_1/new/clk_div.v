module clk_div(
    input  wire clk_8MHZ,
    input  wire rst_n,
    output reg  clk_1HZ
);

 localparam integer FINAL_COUNT = 4_000_000;
//localparam integer FINAL_COUNT = 4;
localparam integer WIDTH = $clog2(FINAL_COUNT);

reg [WIDTH-1:0] cnt;

always @(posedge clk_8MHZ or negedge rst_n) begin
    if (!rst_n) begin
        cnt     <= 0;
        clk_1HZ <= 0;
    end
    else if (cnt == FINAL_COUNT-1) begin
        cnt     <= 0;
        clk_1HZ <= ~clk_1HZ;
    end
    else begin
        cnt <= cnt + 1;
    end
end

endmodule