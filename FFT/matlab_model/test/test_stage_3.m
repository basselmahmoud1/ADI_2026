% test_stage_3.m

% Create a simple input signal: 1 to 16 to observe behavior
input_signal = 1:16;
N = length(input_signal);
output_signal = zeros(1, N);

disp('Testing SDF Stage 3');
disp('Cycle | Input | Stage 3 Output');
disp('--------------------------------');

% We must clear the persistent variables so the delay memory is empty at start
clear delay_x sdf_stage_3

for clk = 0:(N-1)
    in_val = input_signal(clk + 1); % MATLAB arrays still need a 1-based index
    out_val = sdf_stage_3(in_val, clk);
    output_signal(clk + 1) = out_val;
    fprintf('  %d   |  %2d   |   %.2f + %.2fi\n', clk, in_val, real(out_val), imag(out_val));
end

disp(' ');
disp('Output Array:');
disp(output_signal);
