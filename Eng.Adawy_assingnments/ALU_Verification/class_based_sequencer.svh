class class_based_sequencer extends class_base;
    // Mailbox to driver
    mailbox #(class_based_transaction) seq2drv_mb;
    
    // Transaction instance
    class_based_transaction seq_transc;
    
    // Number of transactions to generate
    int num_transactions = 100;
    
   
    
    // Constructor
    function new(mailbox #(class_based_transaction) mb = null);
        if (mb == null) begin
            seq2drv_mb = new();
        end else begin
            seq2drv_mb = mb;
        end
        seq_transc = new();
        `ifdef DEBUG
            $display("-------- IAM in the SEQUENCER and Created --------");
        `endif
    endfunction
    
    // Task to send one transaction
    task send_transaction();
        if (!seq_transc.randomize()) begin
            $error("[SEQUENCER] Randomization failed!");
        end
        
        `ifdef DEBUG
            $display("-------- IAM in the SEQUENCER and Sending the transaction to the Driver --------");
        `endif
        
        seq2drv_mb.put(seq_transc);
        
        `ifdef DEBUG
            $display("-------- IAM in the SEQUENCER and Sent the transaction to the Driver --------");
        `endif
    endtask
    
    // Main run task - generates transactions
    task run();
        `ifdef DEBUG
            $display("-------- IAM in the SEQUENCER and Started --------");
        `endif
        
        // Generate reset transactions first
        repeat(5) begin
            seq_transc.rst.rand_mode(0);
            seq_transc.rst = 1;
            if (!seq_transc.randomize()) $error("[SEQUENCER] Randomization failed!");
            seq2drv_mb.put(seq_transc);
            @(finished_monitoring);
             seq_transc.rst.rand_mode(1);
        end
        
        // Generate normal random transactions
        repeat(num_transactions) begin
            `ifdef DEBUG
                $display("############################## NEW iteration ################################################");
            `endif
            send_transaction();
            // Wait until monitoring is finished before next iteration
            @(finished_monitoring);
            `ifdef DEBUG
                $display("##############################  iteration Ended  ################################################");
            `endif
        end
        
        `ifdef DEBUG
            $display("-------- IAM in the SEQUENCER and Completed all transactions --------");
        `endif
        $finish;
    endtask
    
endclass //class_based_sequencer