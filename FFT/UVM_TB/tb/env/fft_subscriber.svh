`ifndef FFT_SUBSCRIBER_SVH
`define FFT_SUBSCRIBER_SVH

class fft_subscriber extends uvm_subscriber #(fft_seq_item);
    `uvm_component_utils(fft_subscriber)

    fft_seq_item t_item;

    covergroup cg_fft_inputs;
        option.per_instance = 1;
        
        cp_re: coverpoint 12'(t_item.DIN.re) {
            bins zero = {0};
            bins max_pos = {2047};
            bins min_neg = {-2048};
            bins positive = {[1:2046]};
            bins negative = {[-2047:-1]};
        }

        cp_im: coverpoint 12'(t_item.DIN.im) {
            bins zero = {0};
            bins max_pos = {2047};
            bins min_neg = {-2048};
            bins positive = {[1:2046]};
            bins negative = {[-2047:-1]};
        }

        cross cp_re, cp_im {
            ignore_bins extreme_re_nonzero_im = binsof(cp_re.min_neg) && !binsof(cp_im.zero) ||
                                                binsof(cp_re.max_pos) && !binsof(cp_im.zero);
            ignore_bins extreme_im_nonzero_re = binsof(cp_im.min_neg) && !binsof(cp_re.zero) ||
                                                binsof(cp_im.max_pos) && !binsof(cp_re.zero);
        }
    endgroup

    function new(string name = "fft_subscriber", uvm_component parent = null);
        super.new(name, parent);
        cg_fft_inputs = new();
    endfunction

    function void write(fft_seq_item t);
        if (t == null) begin
            `uvm_fatal("FFT_SUB_NULL", "subscriber received a null fft_seq_item")
        end

        `uvm_info("FFT_SUB",
                  $sformatf("received transaction: %s", t.convert2string()),
                  UVM_LOW)
                  
        if (t.valid_in) begin
            t_item = t;
            cg_fft_inputs.sample();
        end
    endfunction

endclass

`endif
