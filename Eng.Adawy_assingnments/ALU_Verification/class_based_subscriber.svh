class class_based_subscriber extends class_base;
    class_based_transaction subscriber_transc;
    mailbox #(class_based_transaction) mon2subSb_mb; 
    
    // Simple coverage group
    covergroup transaction_cg;
        cp_a: coverpoint subscriber_transc.a {
            bins corner[] = {0, 1, -1, 7, -8, 6, -7};
        }

        cp_b: coverpoint subscriber_transc.b {
            bins corner[] = {0, 1, -1, 7, -8, 6, -7};
        }

        cp_opcode: coverpoint subscriber_transc.op_code {
            bins op[] = {ALU_ADD, ALU_SUB, ALU_AND, ALU_OR};
        }

        cp_rst: coverpoint subscriber_transc.rst {
            bins active = {1};
            bins inactive = {0};
        }
        
        cp_z: coverpoint subscriber_transc.z {
            bins b[] = {0, 1};
        }
        cp_n: coverpoint subscriber_transc.n {
            bins b[] = {0, 1};
        }
        cp_c: coverpoint subscriber_transc.c {
            bins b[] = {0, 1};
        }
        cp_v: coverpoint subscriber_transc.v {
            bins b[] = {0, 1};
        }


    endgroup
    
    function new();
        subscriber_transc = new();
        mon2subSb_mb = new(1);
        transaction_cg = new();
    endfunction 
    
    task recieve_transc(output class_based_transaction transc);
        `ifdef DEBUG
            $display("[%0t] [SUBSCRIBER] Waiting for transaction", $time);
        `endif 
        mon2subSb_mb.get(transc);
    endtask
    
    // Display coverage report
    function void display_coverage();
        $display("\n========== COVERAGE REPORT ==========");
        $display("Total Coverage: %.2f%%", transaction_cg.get_coverage());
        $display("=====================================\n");
    endfunction
    
    task run();
        forever begin 
            recieve_transc(subscriber_transc);
            
            `ifdef DEBUG
                subscriber_transc.display("[SUBSCRIBER]");
            `endif 
            
            transaction_cg.sample();
        end
    endtask
endclass