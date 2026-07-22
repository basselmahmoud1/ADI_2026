class class_based_scoreboard extends class_base;
    class_based_transaction score_transc ; 
    // instantiate mailbox
    mailbox #(class_based_transaction) mon2subSb_mb;
     
    int error_count , correct_count ; 
    
    function new();
        score_transc = new();
        mon2subSb_mb = new(1);
        error_count = 0;
        correct_count = 0;
        
    endfunction 
    
    task recieve_transc (output class_based_transaction transc);
        `ifdef DEBUG
            $display("-------- IAM in the SCOREBOARD and going to Wait for the transaction --------");
        `endif 
            mon2subSb_mb.get(transc);
        `ifdef DEBUG
            $display("-------- IAM in the SCOREBOARD and recieved the transaction --------");
        `endif 
    endtask

    task golden_task(
        input class_based_transaction transc,
        output logic signed [3:0] expected_result,
        output logic expected_z,
        output logic expected_n,
        output logic expected_c,
        output logic expected_v
    );
        logic [4:0] ext_math;

        expected_result = '0;
        expected_z = 1'b1;
        expected_n = 1'b0;
        expected_c = 1'b0;
        expected_v = 1'b0;

        if (transc.rst) begin
            expected_result = '0;
            expected_z = 1'b1;
            expected_n = 1'b0;
            expected_c = 1'b0;
            expected_v = 1'b0;
        end else begin
            case (transc.op_code)
                ALU_ADD: begin
                    ext_math = {1'b0, transc.a} + {1'b0, transc.b};
                    expected_result = ext_math[3:0];
                    expected_c = ext_math[4];
                    expected_v = (~(transc.a[3] ^ transc.b[3])) & (expected_result[3] ^ transc.a[3]);
                end
                ALU_SUB: begin
                    ext_math = {1'b0, transc.a} - {1'b0, transc.b};
                    expected_result = ext_math[3:0];
                    expected_c = ext_math[4];
                    expected_v = (transc.a[3] ^ transc.b[3]) & (expected_result[3] ^ transc.a[3]);
                end
                ALU_AND: begin
                    expected_result = transc.a & transc.b;
                end
                ALU_OR: begin
                    expected_result = transc.a | transc.b;
                end
                default: begin
                    expected_result = '0;
                end
            endcase

            expected_z = ~(|expected_result);
            expected_n = expected_result[3];
        end
    endtask

    task check_data(input class_based_transaction transc);
        logic signed [3:0] expected_result;
        logic expected_z;
        logic expected_n;
        logic expected_c;
        logic expected_v;
        
        golden_task(transc, expected_result, expected_z, expected_n, expected_c, expected_v);
        
        if (transc.result !== expected_result ||
            transc.z !== expected_z ||
            transc.n !== expected_n ||
            transc.c !== expected_c ||
            transc.v !== expected_v) begin
            error_count++;
            $display("@%0t [SCOREBOARD ERROR] op=%0d rst=%0b a=%0d b=%0d | exp(result,z,n,c,v)=(%0d,%0b,%0b,%0b,%0b) got=(%0d,%0b,%0b,%0b,%0b)",
                     $realtime,
                     transc.op_code,
                     transc.rst,
                     transc.a,
                     transc.b,
                     expected_result,
                     expected_z,
                     expected_n,
                     expected_c,
                     expected_v,
                     transc.result,
                     transc.z,
                     transc.n,
                     transc.c,
                     transc.v);
        end
        else begin
            correct_count++;
            `ifdef DEBUG
                $display("@%0t [SCOREBOARD PASS] op=%0d a=%0d b=%0d -> result=%0d z=%0b n=%0b c=%0b v=%0b",
                         $realtime,
                         transc.op_code,
                         transc.a,
                         transc.b,
                         transc.result,
                         transc.z,
                         transc.n,
                         transc.c,
                         transc.v);
            `endif
        end
    endtask

    //Question? --> Who will trigger the Check_data task ?
    // answer is the monitor will fork it   
    task run ();
        forever begin 
            // Recive the transaction form the monitor "BLOCKS on the transaction form the monitor" 
            recieve_transc(score_transc);
            `ifdef DEBUG
                    $display("-------- IAM in the SCOREBOARD and going to check data --------");
            `endif 
            // check data mechanism using golden task
            check_data(score_transc);
            `ifdef DEBUG
                    $display("-------- IAM in the SCOREBOARD and Finished Data checking --------");
            `endif
        end
        `ifdef DEBUG
                    $display("-------- IAM in the SCOREBOARD and SCOREBOARD DIED (there might be racing)--------");
        `endif
    endtask
    
    // Report function to display final results
    function void report();
        $display("========================================");
        $display("       SCOREBOARD FINAL REPORT         ");
        $display("========================================");
        $display("Total Correct: %0d", correct_count);
        $display("Total Errors:  %0d", error_count);
        $display("Total Checks:  %0d", correct_count + error_count);
        if (error_count == 0) begin
            $display("STATUS: ALL TESTS PASSED!");
        end
        else begin
            $display("STATUS: %0d TEST(S) FAILED!", error_count);
        end
        $display("========================================");
    endfunction
endclass 