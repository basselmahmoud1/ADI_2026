`ifndef FFT_SEQUENCE_SIN_SVH
`define FFT_SEQUENCE_SIN_SVH

// Sine wave test: drives one period of a real sinusoid sampled at N=8 points.
// With a tone at bin k=1 (one full cycle over 8 samples), the FFT should show
// a single peak at bin 1 (and its conjugate at bin 7) and zeros elsewhere.
//
// Signal:  x[n] = A * sin(2*pi*k*n/N),  n = 0..7,  k=1,  A = 1024
//
// Pre-computed 12-bit integer values (A=1024, k=1, N=8):
//   n=0: sin(0)     =  0
//   n=1: sin(pi/4)  =  724  (1024 * 0.7071)
//   n=2: sin(pi/2)  = 1024
//   n=3: sin(3pi/4) =  724
//   n=4: sin(pi)    =  0
//   n=5: sin(5pi/4) = -724
//   n=6: sin(3pi/2) = -1024
//   n=7: sin(7pi/4) = -724
class fft_sequence_sin extends uvm_sequence #(.REQ(fft_seq_item));
    `uvm_object_utils(fft_sequence_sin)

    function new(string name = "fft_sequence_sin");
        super.new(name);
    endfunction

    virtual task body();
        fft_seq_item items[8];
        // Pre-computed integer values: A * sin(2*pi*n/8) with A=1024
        // All imaginary parts = 0 (real-valued input signal)
        shortint sin_vals[8] = '{0, 724, 1024, 724, 0, -724, -1024, -724};

        int fd;
        int status;
        string matlab_cmd;

        // ---------------------------------------------------------------
        // 1. Build the sine input block & write to file
        // ---------------------------------------------------------------
        fd = $fopen("fft_in.txt", "w");
        if (fd == 0) begin
            `uvm_fatal("FFT_SEQ_SIN", "Failed to open fft_in.txt for writing");
        end

        for (int i = 0; i < 8; i++) begin
            items[i] = fft_seq_item::type_id::create($sformatf("item_%0d", i));
            items[i].valid_in = 1'b1;
            items[i].rstn     = 1'b1;
            items[i].DIN.re   = 12'(sin_vals[i]);
            items[i].DIN.im   = 12'sd0;
            $fdisplay(fd, "%0d %0d", items[i].DIN.re, items[i].DIN.im);
        end
        $fclose(fd);

        // ---------------------------------------------------------------
        // 2. Run MATLAB reference model
        // ---------------------------------------------------------------
        `uvm_info("FFT_SEQ_SIN", "Running MATLAB for sine reference...", UVM_LOW)
        matlab_cmd = "matlab -batch \"cd ../../matlab_model; run_fft_model; exit\"";
        status = $system(matlab_cmd);
        if (status != 0) begin
            `uvm_error("FFT_SEQ_SIN", "MATLAB execution failed!");
        end
        `uvm_info("FFT_SEQ_SIN", "MATLAB reference done.", UVM_LOW)

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
