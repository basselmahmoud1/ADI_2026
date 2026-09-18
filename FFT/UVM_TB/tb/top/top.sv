
module top ();
    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import fft_test_pkg::*;

    bit clk;

    initial begin
        forever begin
            #5; clk = ~clk;
        end
    end

    fft_interface fft_if (clk);
    FFT_WRAPPER dut (.fft_if(fft_if));

    initial begin
        fft_if.rstn = 1;
        @(posedge clk);
        fft_if.rstn = 0;

        repeat (5)
            @(posedge clk);

        fft_if.rstn = 1;
    end

    initial begin
        uvm_config_db#(virtual fft_interface)::set(null, "uvm_test_top.env.agent", "fft_vif", fft_if);
        run_test("fft_test_reg_access");
    end

endmodule 