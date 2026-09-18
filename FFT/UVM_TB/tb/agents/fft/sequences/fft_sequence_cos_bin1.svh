`ifndef FFT_SEQUENCE_COS_BIN1_SVH
`define FFT_SEQUENCE_COS_BIN1_SVH

class fft_sequence_cos_bin1 extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_cos_bin1)

    function new(string name = "fft_sequence_cos_bin1");
        super.new(name);
        sequence_id = "FFT_SEQ_COS_BIN1";
    endfunction

    virtual task body();
        real_samples = {256,181,0,-181,-256,-181,0,181};
        imag_samples = {0,0,0,0,0,0,0,0};
        execute_scenario("cosine bin 1");
    endtask
endclass

`endif
