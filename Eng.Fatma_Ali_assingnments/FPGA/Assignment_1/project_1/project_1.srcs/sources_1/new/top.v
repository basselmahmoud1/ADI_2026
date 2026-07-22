module top (
    input clk,
    input rst_n,
    output [2:0] counter
);
   wire clk_pll;
   wire locked;
    wire clk_1hz;
    clk_wiz_0 u_pll
   (
    // Clock out ports
    .clk_out1(clk_pll),     // output clk_out1
    // Status and control signals
    .resetn(rst_n), // input resetn
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk));
    clk_div u_clk_div(
    .clk_8MHZ(clk_pll),
     .rst_n(locked),
    .clk_1HZ(clk_1hz)
    );
    counter u_count(
       .clk(clk_1hz),
       .rst_n(locked),
       .counter(counter)
       );

 
endmodule