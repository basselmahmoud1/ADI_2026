`ifndef FFT_TEST_REAL_RAMP_SVH
`define FFT_TEST_REAL_RAMP_SVH

class fft_test_real_ramp extends fft_test_base;
    `uvm_component_utils(fft_test_real_ramp)

    function new(string name = "fft_test_real_ramp", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_real_ramp seq;
        phase.raise_objection(this);
        `uvm_info("FFT_TEST_REAL_RAMP", "Starting real ramp test...", UVM_LOW)
        seq = fft_sequence_real_ramp::type_id::create("seq");
        seq.start(env.agent.fft_seqr);
        #200;
        phase.drop_objection(this);
    endtask
endclass

`endif
