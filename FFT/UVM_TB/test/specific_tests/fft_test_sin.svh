`ifndef FFT_TEST_SIN_SVH
`define FFT_TEST_SIN_SVH

// Sine wave test: drives one full period of a k=1 sinusoid (8 samples).
// Expected: single spectral peak at bin 1 (and conjugate at bin 7).
class fft_test_sin extends fft_test_base;
    `uvm_component_utils(fft_test_sin)

    function new(string name = "fft_test_sin", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_sin seq;

        phase.raise_objection(this);
        `uvm_info("FFT_TEST_SIN", "Starting sine wave test...", UVM_LOW)

        seq = fft_sequence_sin::type_id::create("seq");
        seq.start(env.agent.fft_seqr);

        `uvm_info("FFT_TEST_SIN", "Sine wave test completed.", UVM_LOW)
        #100;
        phase.drop_objection(this);
    endtask

endclass

`endif
