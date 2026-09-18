`ifndef FFT_SEQUENCE_LSB_PATTERN_SVH
`define FFT_SEQUENCE_LSB_PATTERN_SVH

class fft_sequence_lsb_pattern extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_lsb_pattern)

    function new(string name = "fft_sequence_lsb_pattern");
        super.new(name);
        sequence_id = "FFT_SEQ_LSB_PATTERN";
    endfunction

    virtual task body();
        real_samples = {1,-1,1,-1,1,-1,1,-1};
        imag_samples = {-1,1,1,-1,1,1,-1,1};
        execute_scenario("plus/minus 1 LSB");
    endtask
endclass

`endif
