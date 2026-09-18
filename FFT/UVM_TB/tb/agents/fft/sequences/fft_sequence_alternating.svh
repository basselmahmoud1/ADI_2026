`ifndef FFT_SEQUENCE_ALTERNATING_SVH
`define FFT_SEQUENCE_ALTERNATING_SVH

class fft_sequence_alternating extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_alternating)

    function new(string name = "fft_sequence_alternating");
        super.new(name);
        sequence_id = "FFT_SEQ_ALTERNATING";
    endfunction

    virtual task body();
        real_samples = {256,-256,256,-256,256,-256,256,-256};
        imag_samples = {0,0,0,0,0,0,0,0};
        execute_scenario("alternating");
    endtask
endclass

`endif
