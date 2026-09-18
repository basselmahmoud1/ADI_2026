`ifndef FFT_TEST_DC_NEG_SVH
`define FFT_TEST_DC_NEG_SVH

class fft_test_dc_neg extends fft_test_base;
    `uvm_component_utils(fft_test_dc_neg)

    function new(string name = "fft_test_dc_neg", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_dc_neg seq;
        phase.raise_objection(this);
        `uvm_info("FFT_TEST_DC_NEG", "Starting -1 DC test...", UVM_LOW)
        seq = fft_sequence_dc_neg::type_id::create("seq");
        seq.start(env.agent.fft_seqr);
        #200;
        phase.drop_objection(this);
    endtask
endclass

`endif
