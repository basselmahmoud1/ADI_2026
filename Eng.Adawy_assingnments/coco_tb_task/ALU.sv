/******************************************************************************
 * File         : alu.sv
 * Project      : ALU
 *
 * Author       : Bassel Mahmoud
 * Created      : 15-Jul-2026
 * Version      : 1.0.0
 *
 * Description  :
 *   Implements a parameterizable Arithmetic Logic Unit (ALU) supporting
 *   basic arithmetic and logical operations. The ALU performs addition,
 *   subtraction, bitwise AND, and bitwise OR based on the selected
 *   operation code.
 *
 * Supported Operations :
 *   - Addition
 *   - Subtraction
 *   - Bitwise AND
 *   - Bitwise OR
 *
 * Inputs      :
 *   - A       : First operand
 *   - B       : Second operand
 *   - OPCODE  : Operation select
 *
 * Outputs      :
 *   - RESULT  : ALU operation result
 *   - FLAGS   : Status flags (if implemented)
 ******************************************************************************/
 
 
 import ALU_pkg::*;
 module ALU #(
    parameter WIDTH = 4 
 )
 (
    input logic clk, rst,
    input wire signed [WIDTH-1:0] a, b,
    input alu_opcode_t op_code,
    output logic signed [WIDTH-1:0] result,
    output logic z,n,c,v
 );

    logic signed [WIDTH-1:0] result_n;
    logic z_n, n_n, c_n, v_n;

    always_comb begin
        result_n = '0;
        c_n = 1'b0;
        v_n = 1'b0;

        case (op_code)
            ALU_ADD: begin
                {c_n, result_n} = {1'b0, a} + {1'b0, b};
                v_n = (~(a[WIDTH-1] ^ b[WIDTH-1])) & (result_n[WIDTH-1] ^ a[WIDTH-1]);
            end 
            ALU_SUB: begin
                // For subtraction, c=1 means no borrow and c=0 means borrow.
                {c_n, result_n} = {1'b0, a} - {1'b0, b};
                v_n = (a[WIDTH-1] ^ b[WIDTH-1]) & (result_n[WIDTH-1] ^ a[WIDTH-1]);
            end
            ALU_AND: result_n = a & b;
            ALU_OR : result_n = a | b;
            default: result_n = '0;
        endcase

        z_n = ~(|result_n);
        n_n = result_n[WIDTH-1];
    end

    always_ff @(posedge clk) begin
        if(rst)begin
            result <= 0;
            z <= 1;
            n <= 0;
            c <= 0;
            v <= 0;  
        end
        else begin    
            result <= result_n;
            z <= z_n;
            n <= n_n;
            c <= c_n;
            v <= v_n;
        end
    end

 endmodule