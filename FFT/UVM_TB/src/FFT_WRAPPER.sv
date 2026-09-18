module FFT_WRAPPER (fft_interface.DUT fft_if);
    import Complex_pack::*;

    FFT_Top top_mod (
        .clk       (fft_if.clk),
        .rstn      (fft_if.rstn),
        .valid_in  (fft_if.valid_in),
        .DIN       (fft_if.DIN),
        .DOUT      (fft_if.DOUT),
        .Valid_out (fft_if.valid_out)
    );

endmodule