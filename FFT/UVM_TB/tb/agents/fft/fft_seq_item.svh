`ifndef FFT_SEQ_ITEM_SVH
`define FFT_SEQ_ITEM_SVH

    import Complex_pack::*;
    class fft_seq_item extends uvm_sequence_item;
        `uvm_object_utils(fft_seq_item)
    
        logic rstn;
        logic valid_in;
        complex_data_t DIN;
        logic valid_out;
        complex_data_t DOUT;
        
        // for printing options 
        fft_display_mode_e display_mode;


        function new (string name = "fft_seq_item");
            super.new(name);
        endfunction

        virtual function string convert2string();
            string s;

            if (display_mode == SHOW_INPUT_ONLY) begin
                return $sformatf("valid_in=%0b DIN=(%0d,%0d)", valid_in, DIN.re, DIN.im);
            end
            else if (display_mode == SHOW_OUTPUT_ONLY) begin
                return $sformatf("valid_out=%0b DOUT=(%0d,%0d)", valid_out, DOUT.re, DOUT.im);
            end
            else begin
                return $sformatf("valid_in=%0b DIN=(%0d,%0d) valid_out=%0b DOUT=(%0d,%0d)",
                                valid_in, DIN.re, DIN.im, valid_out, DOUT.re, DOUT.im);
            end
        endfunction

    endclass


`endif