`ifndef FFT_SEQUENCE_MIN_NEGATIVE_IMPULSE_SVH
`define FFT_SEQUENCE_MIN_NEGATIVE_IMPULSE_SVH

class fft_sequence_min_negative_impulse extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_min_negative_impulse)

    function new(string name = "fft_sequence_min_negative_impulse");
        super.new(name);
        sequence_id = "FFT_SEQ_MIN_NEGATIVE_IMPULSE";
    endfunction

    virtual task body();
        real_samples = {-2048,0,0,0,0,0,0,0};
        imag_samples = {0,0,0,0,0,0,0,0};
        execute_scenario("minimum negative impulse");
    endtask
endclass

`endif
