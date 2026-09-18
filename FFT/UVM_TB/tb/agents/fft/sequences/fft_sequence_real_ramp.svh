`ifndef FFT_SEQUENCE_REAL_RAMP_SVH
`define FFT_SEQUENCE_REAL_RAMP_SVH

class fft_sequence_real_ramp extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_real_ramp)

    function new(string name = "fft_sequence_real_ramp");
        super.new(name);
        sequence_id = "FFT_SEQ_REAL_RAMP";
    endfunction

    virtual task body();
        real_samples = {-256,-192,-128,-64,0,64,128,192};
        imag_samples = {0,0,0,0,0,0,0,0};
        execute_scenario("real ramp");
    endtask
endclass

`endif
