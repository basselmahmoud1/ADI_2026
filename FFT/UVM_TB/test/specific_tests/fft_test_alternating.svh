`ifndef FFT_TEST_ALTERNATING_SVH
`define FFT_TEST_ALTERNATING_SVH

class fft_test_alternating extends fft_test_base;
    `uvm_component_utils(fft_test_alternating)

    function new(string name = "fft_test_alternating", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_alternating seq;
        phase.raise_objection(this);
        `uvm_info("FFT_TEST_ALTERNATING", "Starting alternating test...", UVM_LOW)
        seq = fft_sequence_alternating::type_id::create("seq");
        seq.start(env.agent.fft_seqr);
        #200;
        phase.drop_objection(this);
    endtask
endclass

`endif
