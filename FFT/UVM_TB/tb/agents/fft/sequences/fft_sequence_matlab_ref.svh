`ifndef FFT_SEQUENCE_MATLAB_REF_SVH
`define FFT_SEQUENCE_MATLAB_REF_SVH

class fft_sequence_matlab_ref extends uvm_sequence #(.REQ(fft_seq_item));
    `uvm_object_utils(fft_sequence_matlab_ref)

    function new(string name = "fft_sequence_matlab_ref");
        super.new(name);
    endfunction

    virtual task body();
        fft_seq_item items[8];
        int fd;
        int status;
        string matlab_cmd;

        // 1. Generate 8 random items and open input file
        fd = $fopen("fft_in.txt", "w");
        if (fd == 0) begin
            `uvm_fatal("FFT_SEQ", "Failed to open fft_in.txt for writing");
        end

        for (int i = 0; i < 8; i++) begin
            items[i] = fft_seq_item::type_id::create($sformatf("item_%0d", i));
            if (!items[i].randomize() with { valid_in == 1; rstn == 1; }) begin
                `uvm_fatal("FFT_SEQ", "Randomization failed");
            end
            // Write to file (real and imaginary parts as integers)
            $fdisplay(fd, "%0d %0d", items[i].DIN.re, items[i].DIN.im);
        end
        $fclose(fd);

        // 2. Call MATLAB to generate reference output
        `uvm_info("FFT_SEQ", "Running MATLAB reference model...", UVM_LOW)
        matlab_cmd = "matlab -batch \"cd ../../matlab_model; run_fft_model; exit\"";
        status = $system(matlab_cmd);
        if (status != 0) begin
            `uvm_error("FFT_SEQ", "MATLAB execution failed!");
        end
        `uvm_info("FFT_SEQ", "MATLAB reference model completed.", UVM_LOW)

        // 3. Drive the items to the DUT
        for (int i = 0; i < 8; i++) begin
            start_item(items[i]);
            finish_item(items[i]);
        end
    endtask
endclass

`endif
