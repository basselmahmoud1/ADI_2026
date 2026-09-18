`ifndef FFT_TEST_MAX_POSITIVE_IMPULSE_SVH
`define FFT_TEST_MAX_POSITIVE_IMPULSE_SVH

class fft_test_max_positive_impulse extends fft_test_base;
    `uvm_component_utils(fft_test_max_positive_impulse)

    function new(string name = "fft_test_max_positive_impulse", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_max_positive_impulse seq;
        phase.raise_objection(this);
        `uvm_info("FFT_TEST_MAX_POSITIVE_IMPULSE", "Starting maximum positive impulse test...", UVM_LOW)
        seq = fft_sequence_max_positive_impulse::type_id::create("seq");
        seq.start(env.agent.fft_seqr);
        #200;
        phase.drop_objection(this);
    endtask
endclass

`endif
