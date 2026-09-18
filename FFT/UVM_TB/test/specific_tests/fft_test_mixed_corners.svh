`ifndef FFT_TEST_MIXED_CORNERS_SVH
`define FFT_TEST_MIXED_CORNERS_SVH

class fft_test_mixed_corners extends fft_test_base;
    `uvm_component_utils(fft_test_mixed_corners)

    function new(string name = "fft_test_mixed_corners", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_mixed_corners seq;
        phase.raise_objection(this);
        `uvm_info("FFT_TEST_MIXED_CORNERS", "Starting mixed real/imag corners test...", UVM_LOW)
        seq = fft_sequence_mixed_corners::type_id::create("seq");
        seq.start(env.agent.fft_seqr);
        #200;
        phase.drop_objection(this);
    endtask
endclass

`endif
