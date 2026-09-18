`ifndef FFT_SEQUENCE_IMPULSE_SVH
`define FFT_SEQUENCE_IMPULSE_SVH

// Sanity test: drives a single impulse (x[0] = max_val, x[1..7] = 0).
// The FFT of an impulse is a flat spectrum (all bins equal), which makes
// it the simplest possible check that all N output samples are correct.
class fft_sequence_impulse extends uvm_sequence #(.REQ(fft_seq_item));
    `uvm_object_utils(fft_sequence_impulse)

    // Impulse amplitude: use a modest value well within the 12-bit signed range
    // 12-bit signed max = 2047. Use 1024 for safe headroom after the FFT scaling.
    localparam int IMPULSE_AMP = {4'd1,8'd0};

    function new(string name = "fft_sequence_impulse");
        super.new(name);
    endfunction

    virtual task body();
        fft_seq_item items[8];
        int fd;
        int status;
        string matlab_cmd;

        // ---------------------------------------------------------------
        // 1. Build the impulse input block & write to file
        // ---------------------------------------------------------------
        fd = $fopen("fft_in.txt", "w");
        if (fd == 0) begin
            `uvm_fatal("FFT_SEQ_IMP", "Failed to open fft_in.txt for writing");
        end

        for (int i = 0; i < 8; i++) begin
            items[i] = fft_seq_item::type_id::create($sformatf("item_%0d", i));
            items[i].valid_in = 1'b1;
            items[i].rstn     = 1'b1;
            // Impulse: only sample 0 is non-zero
            if (i == 0) begin
                items[i].DIN.re = IMPULSE_AMP;
                items[i].DIN.im = 12'sd0;
            end else begin
                items[i].DIN.re = 12'sd0;
                items[i].DIN.im = 12'sd0;
            end
            $fdisplay(fd, "%0d %0d", items[i].DIN.re, items[i].DIN.im);
        end
        $fclose(fd);

        // ---------------------------------------------------------------
        // 2. Run MATLAB reference model
        // ---------------------------------------------------------------
        `uvm_info("FFT_SEQ_IMP", "Running MATLAB for impulse reference...", UVM_LOW)
        matlab_cmd = "matlab -batch \"cd ../../matlab_model; run_fft_model; exit\"";
        status = $system(matlab_cmd);
        if (status != 0) begin
            `uvm_error("FFT_SEQ_IMP", "MATLAB execution failed!");
        end
        `uvm_info("FFT_SEQ_IMP", "MATLAB reference done.", UVM_LOW)

        // ---------------------------------------------------------------
        // 3. Drive items to the DUT
        // ---------------------------------------------------------------
        for (int i = 0; i < 8; i++) begin
            start_item(items[i]);
            finish_item(items[i]);
        end

    endtask
endclass

`endif
