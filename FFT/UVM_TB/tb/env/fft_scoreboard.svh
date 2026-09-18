`ifndef FFT_SCOREBOARD_SVH
`define FFT_SCOREBOARD_SVH

`uvm_analysis_imp_decl(_mon)
import Complex_pack::*;


class fft_scoreboard extends uvm_component;
    `uvm_component_utils(fft_scoreboard)

    uvm_analysis_imp_mon #(fft_seq_item, fft_scoreboard) agent_imp;

    // Queue to hold expected outputs
    complex_data_t expected_q[$];
    int match_count = 0;
    int mismatch_count = 0;

    int dut_out_fd;

    function new(string name = "fft_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        agent_imp = new("agent_imp", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        dut_out_fd = $fopen("dut_out.txt", "w");
        if (dut_out_fd == 0) begin
            `uvm_fatal("FFT_SB", "Failed to open dut_out.txt for writing");
        end
    endfunction

    virtual function void extract_phase(uvm_phase phase);
        super.extract_phase(phase);
        if (dut_out_fd != 0) $fclose(dut_out_fd);
    endfunction

    function void load_ref_file();
        int fd;
        int val_re, val_im;
        complex_data_t exp_data;

        fd = $fopen("fft_out_ref.txt", "r");
        if (fd == 0) begin
            `uvm_fatal("FFT_SB", "Could not open fft_out_ref.txt for reading. Did MATLAB run?");
        end

        while (!$feof(fd)) begin
            if ($fscanf(fd, "%d %d\n", val_re, val_im) == 2) begin
                exp_data.re = val_re;
                exp_data.im = val_im;
                expected_q.push_back(exp_data);
            end
        end
        $fclose(fd);
        `uvm_info("FFT_SB", $sformatf("Loaded %0d expected items from MATLAB ref file.", expected_q.size()), UVM_LOW)
    endfunction

    function void write_mon(fft_seq_item t);
        int err_re, err_im;
        
        if (t == null) begin
            `uvm_fatal("FFT_SB_NULL", "scoreboard received a null fft_seq_item")
        end

        // Only check output transactions
        if (t.valid_out == 1'b1) begin
            complex_data_t exp_data;

            if (expected_q.size() == 0) begin
                load_ref_file();
                if (expected_q.size() == 0) begin
                    `uvm_error("FFT_SB", "Received valid_out but expected queue is STILL empty after loading file!")
                    return;
                end
            end

            exp_data = expected_q.pop_front();
            
            // Dump DUT output to file
            $fdisplay(dut_out_fd, "%0d %0d", t.DOUT.re, t.DOUT.im);

            err_re = t.DOUT.re - exp_data.re;
            err_im = t.DOUT.im - exp_data.im;

            if (err_re >= -2 && err_re <= 2 && err_im >= -2 && err_im <= 2) begin
                if (err_re == 0 && err_im == 0) begin
                    `uvm_info("FFT_SB_MATCH", $sformatf("EXACT MATCH: DUT=(%0d,%0d) REF=(%0d,%0d)", 
                              t.DOUT.re, t.DOUT.im, exp_data.re, exp_data.im), UVM_MEDIUM)
                end else begin
                    `uvm_info("FFT_SB_MATCH", $sformatf("MATCH (within tolerance): DUT=(%0d,%0d) REF=(%0d,%0d) Diff=(%0d,%0d)", 
                              t.DOUT.re, t.DOUT.im, exp_data.re, exp_data.im, err_re, err_im), UVM_MEDIUM)
                end
                match_count++;
            end else begin
                `uvm_error("FFT_SB_MISMATCH", $sformatf("MISMATCH (outside tolerance): DUT=(%0d,%0d) REF=(%0d,%0d) Diff=(%0d,%0d)", 
                          t.DOUT.re, t.DOUT.im, exp_data.re, exp_data.im, err_re, err_im))
                mismatch_count++;
            end
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("FFT_SB_REPORT", $sformatf("Scoreboard Report: %0d MATCHES, %0d MISMATCHES", match_count, mismatch_count), UVM_NONE)
        if (expected_q.size() > 0) begin
            `uvm_error("FFT_SB_REPORT", $sformatf("Scoreboard left with %0d unchecked expected items!", expected_q.size()))
        end
    endfunction

endclass

`endif
