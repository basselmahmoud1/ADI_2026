`ifndef FFT_TEST_MATLAB_SVH
`define FFT_TEST_MATLAB_SVH

class fft_test_matlab extends fft_test_base;
    `uvm_component_utils(fft_test_matlab)

    function new(string name = "fft_test_matlab", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fft_sequence_matlab_ref seq;
        
        phase.raise_objection(this);
        `uvm_info("FFT_TEST", "Starting matlab reference sequence...", UVM_LOW)
        
        seq = fft_sequence_matlab_ref::type_id::create("seq");
        seq.start(env.agent.fft_seqr);
        
        `uvm_info("FFT_TEST", "Matlab reference sequence completed.", UVM_LOW)
        // Add a small delay to allow the last outputs to drain from the DUT
        #100;
        phase.drop_objection(this);
    endtask

endclass

`endif
