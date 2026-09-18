`ifndef FFT_TEST_MAXMIN_PAIR_SVH
`define FFT_TEST_MAXMIN_PAIR_SVH

class fft_test_maxmin_pair extends fft_test_base;
    `uvm_component_utils(fft_test_maxmin_pair)

    function new(string name = "fft_test_maxmin_pair", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_maxmin_pair seq;
        phase.raise_objection(this);
        `uvm_info("FFT_TEST_MAXMIN_PAIR", "Starting MAX/MIN pair test...", UVM_LOW)
        seq = fft_sequence_maxmin_pair::type_id::create("seq");
        seq.start(env.agent.fft_seqr);
        #200;
        phase.drop_objection(this);
    endtask
endclass

`endif
