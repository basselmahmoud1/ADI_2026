`ifndef FFT_SEQUENCE_DC_NEG_SVH
`define FFT_SEQUENCE_DC_NEG_SVH

class fft_sequence_dc_neg extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_dc_neg)

    function new(string name = "fft_sequence_dc_neg");
        super.new(name);
        sequence_id = "FFT_SEQ_DC_NEG";
    endfunction

    virtual task body();
        real_samples = {-256,-256,-256,-256,-256,-256,-256,-256};
        imag_samples = {0,0,0,0,0,0,0,0};
        execute_scenario("-1 DC");
    endtask
endclass

`endif
