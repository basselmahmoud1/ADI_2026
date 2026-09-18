`ifndef FFT_SEQUENCE_IMPULSE_N0_SVH
`define FFT_SEQUENCE_IMPULSE_N0_SVH

class fft_sequence_impulse_n0 extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_impulse_n0)

    function new(string name = "fft_sequence_impulse_n0");
        super.new(name);
        sequence_id = "FFT_SEQ_IMPULSE_N0";
    endfunction

    virtual task body();
        real_samples = {256,0,0,0,0,0,0,0};
        imag_samples = {0,0,0,0,0,0,0,0};
        execute_scenario("unit impulse at n=0");
    endtask
endclass

`endif
