class class_based_test extends class_base;
    local virtual ALU_IF test_vif;
    class_based_env env;

    function new(virtual ALU_IF test_vif);
        this.test_vif = test_vif;
    endfunction

    task run();
        env = new(test_vif);
        env.connect();
        `ifdef DEBUG
            $display("[TEST] running fixed full regression");
        `endif
        env.run();
        @(env.generator_handle.generator_done);
        wait (env.gen2drv_mb.num() == 0 && env.monitor_handle.mon2subSb_mb.num() == 0);
        repeat (2) @(posedge test_vif.clk);

        `ifdef DEBUG
            $display("[TEST] regression complete, scoreboard drained all generated checks");
        `endif

        $finish;
    endtask

    function void report();
        if (env != null) begin
            env.report();
        end
    endfunction
endclass