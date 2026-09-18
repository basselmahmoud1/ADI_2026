`ifndef FFT_SEQUENCER_SVH
`define FFT_SEQUENCER_SVH

    class fft_sequencer extends uvm_sequencer #(.REQ(fft_seq_item));
        `uvm_component_utils(fft_sequencer);

        function new (string name = "fft_sequencer" , uvm_component parent = null);
            super.new(name,parent);
        endfunction
        
    endclass

`endif