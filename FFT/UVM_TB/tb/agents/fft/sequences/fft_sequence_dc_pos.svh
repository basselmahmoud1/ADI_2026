`ifndef FFT_SEQUENCE_DC_POS_SVH
`define FFT_SEQUENCE_DC_POS_SVH

class fft_sequence_dc_pos extends fft_sequence_vector_base;
    `uvm_object_utils(fft_sequence_dc_pos)

    function new(string name = "fft_sequence_dc_pos");
        super.new(name);
        sequence_id = "FFT_SEQ_DC_POS";
    endfunction

    virtual task body();
        real_samples = {256,256,256,256,256,256,256,256};
        imag_samples = {0,0,0,0,0,0,0,0};
        execute_scenario("+1 DC");
    endtask
endclass

`endif
