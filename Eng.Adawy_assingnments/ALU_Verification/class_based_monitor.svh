class class_based_monitor extends class_base ; 
    local virtual ALU_IF monitor_vif ; 
    class_based_transaction mon_transc;
    mailbox #(class_based_transaction) mon2subSb_mb;
    
    string key ; 
    function new (string key = "");
        mon_transc = new();
        mon2subSb_mb = new(2);
        // get_vif(key);
        this.key = key ; 
    endfunction
    
    
    task get_vif (string key = "");
        `ifdef DEBUG
            $display("-------- IAM in the MONITOR and going to Get VIF --------");
        `endif 
            // As key reprenest the Key to get the vif
            if(key == "")
                $error("FAILD to get IF :Passing empty KEY to the MONITOR");
            else
                monitor_vif = vif_associative[key];
            
            if(monitor_vif == null)
                $error("FAILD to get IF :Passing null VIF to the MONITOR");
        
        `ifdef DEBUG
            $display("-------- IAM in the MONITOR and GOT to Get VIF --------");
        `endif 
    endtask
    // Question?--> when and Who will finish this forever loop "expected to be forked join none then disable all forks" 
    
    
    task body (); 
        // get the virtual interface 
        get_vif(key);
    endtask
    
    task send_transc (input class_based_transaction transc);
        `ifdef DEBUG
                    $display("-------- IAM in the MONITOR and Sending the transaction to the SB and Subs --------");
        `endif
            mon2subSb_mb.put(transc);
            mon2subSb_mb.put(transc);
        `ifdef DEBUG
                    $display("-------- IAM in the MONITOR and Sent the transaction to the SB and Subs --------");
        `endif
    endtask
    
    task run ();
        // fork to activate the send data to the subscriber and the scoreboard 
        body();
        forever begin
            @(finished_driving);
            if (monitor_vif == null) begin
                $error("Passing null VIF to the monitor");
            end
            `ifdef DEBUG
                $display("-------- IAM in the MONITOR and going to monitor --------");
            `endif 
            // create new transaction 
            mon_transc = new();
            @(posedge monitor_vif.clk);
            #1step;
                mon_transc.a            = monitor_vif.a;
                mon_transc.b            = monitor_vif.b;
                mon_transc.op_code      = monitor_vif.op_code;
                mon_transc.rst          = monitor_vif.rst;
                mon_transc.result       = monitor_vif.result;
                mon_transc.z            = monitor_vif.z;
                mon_transc.n            = monitor_vif.n;
                mon_transc.c            = monitor_vif.c;
                mon_transc.v            = monitor_vif.v;
            `ifdef DEBUG
                $display("-------- IAM in the MONITOR and finished monitoring --------");
            `endif 
            // Send the transaction 
            send_transc(mon_transc);
        end
        `ifdef DEBUG
                    $display("-------- IAM in the MONITOR and MONITOR DIED (there might be racing)--------");
        `endif
    endtask  
endclass