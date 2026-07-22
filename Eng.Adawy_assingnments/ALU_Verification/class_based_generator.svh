class class_based_generator extends class_base;
    mailbox #(class_based_transaction) gen2drv_mb;

    int num_random_transactions = 10000;
    event generator_done;

    function new(mailbox #(class_based_transaction) mb = null);
        if (mb == null) begin
            gen2drv_mb = new();
        end else begin
            gen2drv_mb = mb;
        end
        `ifdef DEBUG
            $display("-------- IAM in the GENERATOR and Created --------");
        `endif
    endfunction

    function class_based_transaction make_tr(
        input bit rst,
        input logic signed [3:0] a,
        input logic signed [3:0] b,
        input alu_opcode_t op
    );
        class_based_transaction t;
        t = new();
        t.rst = rst;
        t.a = a;
        t.b = b;
        t.op_code = op;
        return t;
    endfunction

    task send_transaction(input class_based_transaction t);
        gen2drv_mb.put(t.clone());
        // @(finished_monitoring);
    endtask

    task send_random_transaction();
        class_based_transaction t;
        t = new();
        if (!t.randomize()) begin
            $error("[GENERATOR] Randomization failed");
        end
        send_transaction(t);
    endtask

    task seq_01_reset();
        repeat (3) begin
            send_transaction(make_tr(1'b1, 0, 0, ALU_ADD));
        end
        repeat (5) begin
            send_random_transaction();
        end
    endtask

    task seq_02_add_corner();
        send_transaction(make_tr(0, 7, 1, ALU_ADD));
        send_transaction(make_tr(0, 0, 0, ALU_ADD));
        send_transaction(make_tr(0, -8, -1, ALU_ADD));
    endtask

    task seq_03_sub_corner();
        send_transaction(make_tr(0, -8, 1, ALU_SUB));
        send_transaction(make_tr(0, 0, 0, ALU_SUB));
        send_transaction(make_tr(0, 7, -8, ALU_SUB));
    endtask

    task seq_04_and_all_zeros();
        send_transaction(make_tr(0, -1, 0, ALU_AND));
        send_transaction(make_tr(0, 0, -1, ALU_AND));
    endtask

    task seq_05_and_all_ones();
        send_transaction(make_tr(0, -1, -1, ALU_AND));
    endtask

    task seq_06_or_all_zeros();
        send_transaction(make_tr(0, 0, 0, ALU_OR));
    endtask

    task seq_07_or_all_ones();
        send_transaction(make_tr(0, 7, -8, ALU_OR));
    endtask

    task seq_08_zero_flag();
        send_transaction(make_tr(0, 5, -5, ALU_ADD));
        send_transaction(make_tr(0, 3, 3, ALU_SUB));
    endtask

    task seq_09_negative_flag();
        send_transaction(make_tr(0, -4, 1, ALU_ADD));
        send_transaction(make_tr(0, 1, 3, ALU_SUB));
    endtask

    task seq_10_opcode_sweep();
        logic signed [3:0] a_local;
        logic signed [3:0] b_local;
        a_local = 3;
        b_local = 2;
        send_transaction(make_tr(0, a_local, b_local, ALU_ADD));
        send_transaction(make_tr(0, a_local, b_local, ALU_SUB));
        send_transaction(make_tr(0, a_local, b_local, ALU_AND));
        send_transaction(make_tr(0, a_local, b_local, ALU_OR));
    endtask

    task seq_11_back_to_back();
        repeat (num_random_transactions) begin
            send_random_transaction();
        end
    endtask

    task seq_12_reset_mid_sequence();
        repeat (10) begin
            send_random_transaction();
        end
        send_transaction(make_tr(1, 0, 0, ALU_ADD));
        send_transaction(make_tr(1, 0, 0, ALU_SUB));
        repeat (10) begin
            send_random_transaction();
        end
    endtask

    task run();
        `ifdef DEBUG
            $display("-------- IAM in the GENERATOR and Started full regression --------");
        `endif

        seq_01_reset();
        seq_02_add_corner();
        seq_03_sub_corner();
        seq_04_and_all_zeros();
        seq_05_and_all_ones();
        seq_06_or_all_zeros();
        seq_07_or_all_ones();
        seq_08_zero_flag();
        seq_09_negative_flag();
        seq_10_opcode_sweep();
        seq_11_back_to_back();
        seq_12_reset_mid_sequence();

        `ifdef DEBUG
            $display("-------- IAM in the GENERATOR and Completed --------");
        `endif
        ->generator_done;
    endtask
endclass