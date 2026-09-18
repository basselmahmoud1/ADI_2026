`ifndef FFT_TEST_IMPULSE_N0_SVH
`define FFT_TEST_IMPULSE_N0_SVH

class fft_test_impulse_n0 extends fft_test_base;
    `uvm_component_utils(fft_test_impulse_n0)

    function new(string name = "fft_test_impulse_n0", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_impulse_n0 seq;
        phase.raise_objection(this);
        `uvm_info("FFT_TEST_IMPULSE_N0", "Starting unit impulse at n=0 test...", UVM_LOW)
        seq = fft_sequence_impulse_n0::type_id::create("seq");
        seq.start(env.agent.fft_seqr);
        #200;
        phase.drop_objection(this);
    endtask
endclass

`endif
