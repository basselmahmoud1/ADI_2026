`ifndef FFT_TEST_SANITY_SVH
`define FFT_TEST_SANITY_SVH

// Sanity test: drives a unit impulse through the FFT.
// Expected result: all 8 output bins should be equal (flat spectrum).
class fft_test_sanity extends fft_test_base;
    `uvm_component_utils(fft_test_sanity)

    function new(string name = "fft_test_sanity", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_impulse seq;

        phase.raise_objection(this);
        `uvm_info("FFT_TEST_SANITY", "Starting impulse (sanity) test...", UVM_LOW)

        seq = fft_sequence_impulse::type_id::create("seq");
        seq.start(env.agent.fft_seqr);

        `uvm_info("FFT_TEST_SANITY", "Impulse test completed.", UVM_LOW)
        #100;
        phase.drop_objection(this);
    endtask

endclass

`endif
