function data_out = top_fft(data_in, clk, T) %#codegen
    % TOP_FFT Top-level module connecting the 3 stages of an 8-point Radix-2 DIF SDF FFT

    % Stage 1 (Delay = 4)
    out_1 = sdf_stage_1(data_in, clk, T);

    % Stage 2 (Delay = 2)
    out_2 = sdf_stage_2(out_1, clk, T);

    % Stage 3 (Delay = 1)
    data_out = cast(sdf_stage_3(out_2, clk, T), 'like', T.data_out);
end
