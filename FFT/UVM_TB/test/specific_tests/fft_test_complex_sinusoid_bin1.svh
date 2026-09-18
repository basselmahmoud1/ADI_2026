`ifndef FFT_TEST_COMPLEX_SINUSOID_BIN1_SVH
`define FFT_TEST_COMPLEX_SINUSOID_BIN1_SVH

class fft_test_complex_sinusoid_bin1 extends fft_test_base;
    `uvm_component_utils(fft_test_complex_sinusoid_bin1)

    function new(string name = "fft_test_complex_sinusoid_bin1", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_complex_sinusoid_bin1 seq;
        phase.raise_objection(this);
        `uvm_info("FFT_TEST_COMPLEX_SINUSOID_BIN1", "Starting complex sinusoid bin 1 test...", UVM_LOW)
        seq = fft_sequence_complex_sinusoid_bin1::type_id::create("seq");
        seq.start(env.agent.fft_seqr);
        #200;
        phase.drop_objection(this);
    endtask
endclass

`endif
