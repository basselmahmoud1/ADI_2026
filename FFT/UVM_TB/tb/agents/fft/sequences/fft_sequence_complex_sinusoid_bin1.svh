`ifndef FFT_SEQUENCE_COMPLEX_SINUSOID_BIN1_SVH
`define FFT_SEQUENCE_COMPLEX_SINUSOID_BIN1_SVH

class fft_sequence_complex_sinusoid_bin1 extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_complex_sinusoid_bin1)

    function new(string name = "fft_sequence_complex_sinusoid_bin1");
        super.new(name);
        sequence_id = "FFT_SEQ_COMPLEX_SINUSOID_BIN1";
    endfunction

    virtual task body();
        real_samples = {192,136,0,-136,-192,-136,0,136};
        imag_samples = {0,136,192,136,0,-136,-192,-136};
        execute_scenario("complex sinusoid bin 1");
    endtask
endclass

`endif
