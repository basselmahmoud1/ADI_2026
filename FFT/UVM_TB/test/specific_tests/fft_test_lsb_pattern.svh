`ifndef FFT_TEST_LSB_PATTERN_SVH
`define FFT_TEST_LSB_PATTERN_SVH

class fft_test_lsb_pattern extends fft_test_base;
    `uvm_component_utils(fft_test_lsb_pattern)

    function new(string name = "fft_test_lsb_pattern", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_lsb_pattern seq;
        phase.raise_objection(this);
        `uvm_info("FFT_TEST_LSB_PATTERN", "Starting plus/minus 1 LSB test...", UVM_LOW)
        seq = fft_sequence_lsb_pattern::type_id::create("seq");
        seq.start(env.agent.fft_seqr);
        #200;
        phase.drop_objection(this);
    endtask
endclass

`endif
