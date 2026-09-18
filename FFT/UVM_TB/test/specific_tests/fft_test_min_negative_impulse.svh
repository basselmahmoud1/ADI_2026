`ifndef FFT_TEST_MIN_NEGATIVE_IMPULSE_SVH
`define FFT_TEST_MIN_NEGATIVE_IMPULSE_SVH

class fft_test_min_negative_impulse extends fft_test_base;
    `uvm_component_utils(fft_test_min_negative_impulse)

    function new(string name = "fft_test_min_negative_impulse", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_min_negative_impulse seq;
        phase.raise_objection(this);
        `uvm_info("FFT_TEST_MIN_NEGATIVE_IMPULSE", "Starting minimum negative impulse test...", UVM_LOW)
        seq = fft_sequence_min_negative_impulse::type_id::create("seq");
        seq.start(env.agent.fft_seqr);
        #200;
        phase.drop_objection(this);
    endtask
endclass

`endif
