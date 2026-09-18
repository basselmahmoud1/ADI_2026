`ifndef FFT_SEQUENCE_IMPULSE_N3_SVH
`define FFT_SEQUENCE_IMPULSE_N3_SVH

class fft_sequence_impulse_n3 extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_impulse_n3)

    function new(string name = "fft_sequence_impulse_n3");
        super.new(name);
        sequence_id = "FFT_SEQ_IMPULSE_N3";
    endfunction

    virtual task body();
        real_samples = {0,0,0,256,0,0,0,0};
        imag_samples = {0,0,0,0,0,0,0,0};
        execute_scenario("unit impulse at n=3");
    endtask
endclass

`endif
