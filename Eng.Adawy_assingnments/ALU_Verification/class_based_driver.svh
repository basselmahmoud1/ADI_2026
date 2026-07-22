class class_based_driver extends class_base ; 

    local virtual ALU_IF driv_vif ; 
    mailbox #(class_based_transaction) gen2drv_mb;
    class_based_transaction driver_transc;
     
    string key ; 
    function new (string key = "");
        driver_transc = new();
        gen2drv_mb    = new(1);
        this.key = key ; 
    endfunction

    task recieve_transc (output class_based_transaction transc);
        `ifdef DEBUG
            $display("-------- IAM in the Driver and going to Wait for the transaction --------");
        `endif 
            gen2drv_mb.get(transc);
        `ifdef DEBUG
            $display("-------- IAM in the Driver and recieved the transaction --------");
        `endif 
    endtask

    task body (); 
        // get the virtual interface 
        get_vif(key);
    endtask

    task get_vif (string key = "");
        `ifdef DEBUG
            $display("-------- IAM in the Driver and going to Get VIF --------");
        `endif 
            // As key reprenest the Key to get the vif
            if(key == "")
                $error("FAILD to get IF :Passing empty KEY to the DRIVER");
            else
                driv_vif = vif_associative[key];
            if(driv_vif == null)
                $error("FAILD to get IF :Passing null VIF to the driver");
        
        `ifdef DEBUG
            $display("-------- IAM in the Driver and GOT to Get VIF --------");
        `endif 
    endtask
    task run ();
        // Get the Vif 
        body();
        
        forever begin
            // get the new randomized data from the sequencer and begin to assign this data to the interface
            recieve_transc(driver_transc);
            `ifdef DEBUG
                $display("-------- IAM in the Driver and going to drive --------");
            `endif 
                @(negedge driv_vif.clk);
                driv_vif.a         = driver_transc.a;
                driv_vif.b         = driver_transc.b;
                driv_vif.op_code   = driver_transc.op_code;
                driv_vif.rst       = driver_transc.rst;
            `ifdef DEBUG
                $display("-------- IAM in the Driver and finished driving --------");
            `endif 
            ->finished_driving ;
        end
        `ifdef DEBUG
                    $display("-------- IAM in the Driver and Driver DIED (there might be racing)--------");
        `endif
    endtask  
endclass
    