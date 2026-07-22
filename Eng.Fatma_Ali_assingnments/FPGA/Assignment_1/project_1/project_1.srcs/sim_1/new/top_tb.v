`timescale 1ns / 1ns

module top_tb;

    reg clk;
    reg rst_n;
    wire [2:0] counter;

    top DUT (
        .clk(clk),
        .rst_n(rst_n),
        .counter(counter)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
        
        #20000;
        $finish;
    end

    

endmodule