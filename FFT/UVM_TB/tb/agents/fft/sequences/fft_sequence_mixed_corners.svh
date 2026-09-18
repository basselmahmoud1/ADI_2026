`ifndef FFT_SEQUENCE_MIXED_CORNERS_SVH
`define FFT_SEQUENCE_MIXED_CORNERS_SVH

class fft_sequence_mixed_corners extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_mixed_corners)

    function new(string name = "fft_sequence_mixed_corners");
        super.new(name);
        sequence_id = "FFT_SEQ_MIXED_CORNERS";
    endfunction

    virtual task body();
        real_samples = {2047,0,-2048,0,0,0,0,0};
        imag_samples = {0,2047,0,-2048,0,0,0,0};
        execute_scenario("mixed real/imag corners");
    endtask
endclass

`endif
