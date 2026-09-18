`ifndef FFT_TEST_ALL_ZEROS_SVH
`define FFT_TEST_ALL_ZEROS_SVH

class fft_test_all_zeros extends fft_test_base;
    `uvm_component_utils(fft_test_all_zeros)

    function new(string name = "fft_test_all_zeros", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_all_zeros seq;
        phase.raise_objection(this);
        `uvm_info("FFT_TEST_ALL_ZEROS", "Starting all zeros test...", UVM_LOW)
        seq = fft_sequence_all_zeros::type_id::create("seq");
        seq.start(env.agent.fft_seqr);
        #200;
        phase.drop_objection(this);
    endtask
endclass

`endif
