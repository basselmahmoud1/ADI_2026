% test_top_fft.m

N = 8;
input_signal = [1, 2, 3, 4, 5, 6, 7, 8]; % Simple ramp input
% input_signal = [1, 0, 0, 0, 0, 0, 0, 0]; % Try uncommenting this impulse later!

% 1. Calculate Golden Reference using MATLAB's built-in fft
golden_output = fft(input_signal, N);

disp('--- GOLDEN FFT OUTPUT ---');
disp(golden_output);

% 2. Run our hardware model
% Clear persistent variables in delay lines
clear delay_x sdf_stage_1 sdf_stage_2 sdf_stage_3 top_fft

% Total latency = Delay 4 + Delay 2 + Delay 1 = 7 cycles
% So the 8 valid outputs will emerge from cycle 7 to cycle 14
TOTAL_CYCLES = N + 7;
sdf_output = zeros(1, N);

disp('Clocking data through the SDF pipeline...');
for clk = 0:(TOTAL_CYCLES-1)
    if clk < N
        in_val = input_signal(clk + 1);
    else
        in_val = 0; % Flush the pipeline with zeros
    end
    
    out_val = top_fft(in_val, clk);
    
    % Capture output if it's valid (after the pipeline latency)
    if clk >= 7
        sdf_output((clk - 7) + 1) = out_val;
    end
end

% 3. Output Reordering
% Radix-2 DIF FFT outputs data in bit-reversed order.
% Natural indices: 0, 1, 2, 3, 4, 5, 6, 7
% Bit-reversed:    0, 4, 2, 6, 1, 5, 3, 7
bit_reversed_indices = bin2dec(fliplr(dec2bin(0:N-1, log2(N)))) + 1;

% Reorder the SDF output so it matches natural frequency order
final_sdf_output = zeros(1, N);
final_sdf_output(bit_reversed_indices) = sdf_output;

disp('--- OUR SDF FFT OUTPUT (Bit-Reversed Corrected) ---');
disp(final_sdf_output);

% 4. Compare
error = max(abs(golden_output - final_sdf_output));
disp(['Maximum Error: ', num2str(error)]);
if error < 1e-10
    disp('SUCCESS! The SDF architecture matches MATLABs fft() perfectly!');
else
    disp('ERROR! The outputs do not match.');
end
