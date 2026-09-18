
import Complex_pack::*;

interface fft_interface (input clk);
    logic rstn;
    logic valid_in;
    complex_data_t DIN;
    logic valid_out;
    complex_data_t DOUT;

    modport DUT (
        input clk, rstn, valid_in, DIN,
        output valid_out, DOUT
    );

    clocking fft_cb_drv @(posedge clk);
        default input #1 output #1;
        output rstn, valid_in, DIN;
        input  valid_out, DOUT;
    endclocking

    clocking fft_cb_mon @(posedge clk);
        default input #1step;
        input  rstn, valid_in, DIN;
        input  valid_out, DOUT;
    endclocking

    modport MON (clocking fft_cb_mon);
    modport DRV (clocking fft_cb_drv);
endinterface

