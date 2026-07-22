class class_based_env extends class_base;
    class_based_generator generator_handle ; 
    class_based_driver dirver_handle ; 
    class_based_monitor monitor_handle ;
    class_based_scoreboard sb_handle ;
    class_based_subscriber subscriber_handle ;
    
    mailbox #(class_based_transaction) gen2drv_mb;
    mailbox #(class_based_transaction) mon2subSb_mb;
    local virtual ALU_IF env_vif ; 

    function new(virtual ALU_IF env_vif);
        generator_handle  = new();
        dirver_handle     = new("VIF_driv");
        monitor_handle    = new("VIF_mon");
        sb_handle         = new();
        subscriber_handle = new();
        gen2drv_mb        = new();
        mon2subSb_mb      = new();
        //Assign the interface with the virtual interface passed form the top module 
        this.env_vif = env_vif;
    endfunction
    task connect ();
        `ifdef DEBUG
                    $display("-------- IAM in the ENV and going to Connect the gen2drv_mb --------");
        `endif 
        generator_handle.gen2drv_mb    = gen2drv_mb ; 
        dirver_handle.gen2drv_mb       = gen2drv_mb ; 
        `ifdef DEBUG
                    $display("-------- IAM in the ENV and going to Connect the mon2subSb_mb --------");
        `endif
         monitor_handle.mon2subSb_mb     = mon2subSb_mb ; 
         sb_handle.mon2subSb_mb          = mon2subSb_mb ; 
         subscriber_handle.mon2subSb_mb  = mon2subSb_mb ;
         `ifdef DEBUG
                    $display("-------- IAM in the ENV and going to Put Vif in the Database --------");
        `endif
        // put the vif in thte associative array 
        vif_associative["VIF_driv"] = env_vif ;
        vif_associative["VIF_mon"] = env_vif ;
    endtask
    // We must take the Interface form the Top and pass it to the monitor and the driver 
    task run ();
        `ifdef DEBUG
                    $display("-------- IAM in the ENV and going to Fork and run the env --------");
        `endif
        fork
            generator_handle.run();   
            dirver_handle.run();     
            monitor_handle.run();    
            sb_handle.run();         
            subscriber_handle.run(); 
        join_none 
        `ifdef DEBUG
                    $display("-------- IAM in the ENV and ENV DIED (there might be racing)--------");
        `endif
    endtask 
    
    // Report function to display scoreboard results
    function void report();
        sb_handle.report();
    endfunction
endclass //class_based_env extends superClass