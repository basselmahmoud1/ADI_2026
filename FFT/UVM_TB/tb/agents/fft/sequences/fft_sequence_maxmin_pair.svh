`ifndef FFT_SEQUENCE_MAXMIN_PAIR_SVH
`define FFT_SEQUENCE_MAXMIN_PAIR_SVH

class fft_sequence_maxmin_pair extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_maxmin_pair)

    function new(string name = "fft_sequence_maxmin_pair");
        super.new(name);
        sequence_id = "FFT_SEQ_MAXMIN_PAIR";
    endfunction

    virtual task body();
        real_samples = {2047,-2048,0,0,0,0,0,0};
        imag_samples = {0,0,0,0,0,0,0,0};
        execute_scenario("MAX/MIN pair");
    endtask
endclass

`endif
