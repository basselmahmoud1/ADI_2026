`ifndef FFT_SEQUENCE_MAX_POSITIVE_IMPULSE_SVH
`define FFT_SEQUENCE_MAX_POSITIVE_IMPULSE_SVH

class fft_sequence_max_positive_impulse extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_max_positive_impulse)

    function new(string name = "fft_sequence_max_positive_impulse");
        super.new(name);
        sequence_id = "FFT_SEQ_MAX_POSITIVE_IMPULSE";
    endfunction

    virtual task body();
        real_samples = {2047,0,0,0,0,0,0,0};
        imag_samples = {0,0,0,0,0,0,0,0};
        execute_scenario("maximum positive impulse");
    endtask
endclass

`endif
