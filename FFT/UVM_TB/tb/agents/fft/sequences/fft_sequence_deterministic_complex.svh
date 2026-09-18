`ifndef FFT_SEQUENCE_DETERMINISTIC_COMPLEX_SVH
`define FFT_SEQUENCE_DETERMINISTIC_COMPLEX_SVH

class fft_sequence_deterministic_complex extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_deterministic_complex)

    function new(string name = "fft_sequence_deterministic_complex");
        super.new(name);
        sequence_id = "FFT_SEQ_DETERMINISTIC_COMPLEX";
    endfunction

    virtual task body();
        real_samples = {300,-271,128,-63,377,-345,42,-190};
        imag_samples = {-120,333,-384,211,19,-256,301,-77};
        execute_scenario("deterministic complex vector");
    endtask
endclass

`endif
