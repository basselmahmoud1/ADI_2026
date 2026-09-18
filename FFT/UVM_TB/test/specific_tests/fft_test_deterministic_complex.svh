`ifndef FFT_TEST_DETERMINISTIC_COMPLEX_SVH
`define FFT_TEST_DETERMINISTIC_COMPLEX_SVH

class fft_test_deterministic_complex extends fft_test_base;
    `uvm_component_utils(fft_test_deterministic_complex)

    function new(string name = "fft_test_deterministic_complex", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_deterministic_complex seq;
        phase.raise_objection(this);
        `uvm_info("FFT_TEST_DETERMINISTIC_COMPLEX", "Starting deterministic complex vector test...", UVM_LOW)
        seq = fft_sequence_deterministic_complex::type_id::create("seq");
        seq.start(env.agent.fft_seqr);
        #200;
        phase.drop_objection(this);
    endtask
endclass

`endif
