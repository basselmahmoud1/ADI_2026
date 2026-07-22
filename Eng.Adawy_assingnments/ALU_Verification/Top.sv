module top ();
    import ALU_pkg::*;
    import pack::*;
    logic clk ; 

    initial begin
        clk = 0 ; 
        forever begin
            #1; clk = ~clk ; 
        end
    end

    class_based_test test;

    ALU_IF aluif (clk);

    ALU dut (
        .clk(aluif.clk),
        .rst(aluif.rst),
        .a(aluif.a),
        .b(aluif.b),
        .op_code(aluif.op_code),
        .result(aluif.result),
        .z(aluif.z),
        .n(aluif.n),
        .c(aluif.c),
        .v(aluif.v)
    );

    initial begin
        `ifdef DEBUG
                $display("-------- IAM in the TOP and Going to start simulation --------");
        `endif 

        test = new(aluif);
        test.run();

        `ifdef DEBUG
                $display("-------- IAM in the TOP and Finished simulation --------");
        `endif 
    end

    // Print some logs after the sim finishes 
    final begin
        $display(" SIM Finished successfully ");
        if (test != null) begin
            test.report();
        end
    end  

endmodule 