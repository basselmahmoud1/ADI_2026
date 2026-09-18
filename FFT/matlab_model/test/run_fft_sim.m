function final_sdf = run_fft_sim(x, N, T) %#codegen
% RUN_FFT_SIM  Run one N-sample block through the SDF FFT pipeline.
%
%   final_sdf = run_fft_sim(x, N, T)
%
%   Inputs:
%     x  - 1×N input vector, already cast to the desired type via T.data_in
%     N  - FFT size (8)
%     T  - types table struct from top_fft_types()
%
%   Output:
%     final_sdf - 1×N complex FFT output in natural frequency order
%
%   NOTE: Clears all persistent delay-line state before running so that
%         two back-to-back calls with different T structs do not interfere.

% Clear persistent state in all pipeline stages
clear delay_x sdf_stage_1 sdf_stage_2 sdf_stage_3 top_fft

TOTAL_CYCLES = N + 7;          % pipeline latency = 4+2+1 = 7 cycles
bit_rev = bin2dec(fliplr(dec2bin(0:N-1, log2(N)))) + 1;

sdf_out = cast(complex(zeros(1, TOTAL_CYCLES)), 'like', T.data_out);

for clk = 0:(TOTAL_CYCLES - 1)
    in_val = cast(complex(0), 'like', T.data_in);
    if clk < N
        in_val = cast(x(clk + 1), 'like', T.data_in);
    end
    sdf_out(clk + 1) = top_fft(in_val, clk, T);
end

% Bit-reversal reorder → natural frequency order
final_sdf = cast(complex(zeros(1, N)), 'like', T.data_out);
final_sdf(bit_rev) = sdf_out(8:TOTAL_CYCLES);

end
