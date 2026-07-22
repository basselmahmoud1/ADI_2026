import ALU_pkg::*;

interface ALU_IF (
    input logic clk
);
    logic rst;
    logic signed [3:0] a;
    logic signed [3:0] b;
    alu_opcode_t op_code;

    logic signed [3:0] result;
    logic z;
    logic n;
    logic c;
    logic v;

    modport DUT (
        input clk, rst, a, b, op_code,
        output result, z, n, c, v
    );
    endinterface