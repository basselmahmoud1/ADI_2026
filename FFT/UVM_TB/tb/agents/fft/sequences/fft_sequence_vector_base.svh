`ifndef FFT_SEQUENCE_VECTOR_BASE_SVH
`define FFT_SEQUENCE_VECTOR_BASE_SVH

class fft_sequence_vector_base extends uvm_sequence #(.REQ(fft_seq_item));
    `uvm_object_utils(fft_sequence_vector_base)

    localparam int N = 8;
    // Pipeline drain time: 8 input cycles (80ns) + 8 output cycles (80ns) + margin
    localparam int DRAIN_NS = 200;

    string sequence_id = "FFT_SEQ_VECTOR";

    shortint real_samples[N];
    shortint imag_samples[N];

    function new(string name = "fft_sequence_vector_base");
        super.new(name);
    endfunction

    task execute_scenario(string label);
        int fd;
        int status;
        string matlab_cmd;
        fft_seq_item items[N];

        // 1. Write the 8 samples for MATLAB to read
        fd = $fopen("fft_in.txt", "w");
        if (fd == 0)
            `uvm_fatal(sequence_id, "Failed to open fft_in.txt for writing");
        for (int i = 0; i < N; i++)
            $fdisplay(fd, "%0d %0d", 12'(real_samples[i]), 12'(imag_samples[i]));
        $fclose(fd);

        // 2. Call MATLAB to compute the 8 reference outputs
        `uvm_info(sequence_id, $sformatf("Running MATLAB reference for: %s", label), UVM_LOW)
        matlab_cmd = "matlab -batch \"cd ../../matlab_model; run_fft_model; exit\"";
        status = $system(matlab_cmd);
        if (status != 0)
            `uvm_error(sequence_id, "MATLAB execution failed!");
        `uvm_info(sequence_id, "MATLAB reference done.", UVM_LOW)

        // 3. Drive the samples to the DUT
        for (int i = 0; i < N; i++) begin
            items[i] = fft_seq_item::type_id::create($sformatf("item_%0d", i));
            items[i].valid_in = 1'b1;
            items[i].rstn     = 1'b1;
            items[i].DIN.re   = 12'(real_samples[i]);
            items[i].DIN.im   = 12'(imag_samples[i]);
        end

        for (int i = 0; i < N; i++) begin
            start_item(items[i]);
            finish_item(items[i]);
        end

        // Wait for pipeline to drain before finishing sequence
        #(DRAIN_NS);
    endtask

    virtual task body();
        // Derived classes override body() to call execute_scenario()
    endtask

endclass

`endif // FFT_SEQUENCE_VECTOR_BASE_SVH
