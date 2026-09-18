% test_delay.m
D = 4; % Delay length
state = zeros(1, D);

disp(['Testing delay line of length ', num2str(D)]);
disp('Cycle | Input | Output | Internal State (Oldest -> Newest)');
disp('---------------------------------------------------------');

for cycle = 1:8
    input_data = cycle * 10; % Input data (10, 20, 30...)
    [output_data, state] = delay_x(input_data, state, D);
    
    % Displaying the flow cycle-by-cycle
    state_str = sprintf('%d ', state);
    fprintf('  %d   |  %2d   |   %2d   | [%s]\n', cycle, input_data, output_data, strtrim(state_str));
end
