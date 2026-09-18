`ifndef FFT_SEQUENCE_ALL_ZEROS_SVH
`define FFT_SEQUENCE_ALL_ZEROS_SVH

class fft_sequence_all_zeros extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_all_zeros)

    function new(string name = "fft_sequence_all_zeros");
        super.new(name);
        sequence_id = "FFT_SEQ_ALL_ZEROS";
    endfunction

    virtual task body();
        real_samples = {0,0,0,0,0,0,0,0};
        imag_samples = {0,0,0,0,0,0,0,0};
        execute_scenario("all zeros");
    endtask
endclass

`endif
