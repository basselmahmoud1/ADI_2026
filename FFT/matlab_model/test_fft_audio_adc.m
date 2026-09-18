% test_fft_audio_adc.m
% Fixed-point requirements test for 48kHz fractional audio on an N=8 SDF FFT.
%
% USAGE: Change 'dt' below to switch data type mode:
%   'double' -- Step 1: baseline golden reference (SQNR should be +Inf)
%   'single' -- Step 2: catch type-mismatch issues (SQNR should be >100 dB)
%   'fixed'  -- Step 3: fixed-point simulation   (target SQNR > 50 dB)

%% ---- Data Type Selection ----
dt = 'double';          % <-- change to 'single' or 'fixed' as needed

T      = top_fft_types(dt);         % type under test
% Golden reference is MATLAB's built-in fft() — exact, independent of any pipeline

%% ---- Design Parameters ----
N             = 8;
Fs            = 48000;
NUM_SEEDS     = 1000;
bit_rev       = bin2dec(fliplr(dec2bin(0:N-1, log2(N)))) + 1;

%% ---- Build / Rebuild Instrumented MEX (first run or type change) ----
mex_name = ['top_fft_mex_' dt];
if ~exist([mex_name '.mexw64'], 'file') && ~exist([mex_name '.mexa64'], 'file') && ...
   ~exist([mex_name '.mexmaci64'], 'file')

    fprintf('Building instrumented MEX for dt = ''%s'' ...\n', dt);
    data_in_proto = cast(complex(0), 'like', T.data_in);
    clk_proto     = int32(0);
    % Use function-call syntax so mex_name variable is evaluated (not treated as literal)
    buildInstrumentedMex('top_fft', ...
        '-args', {data_in_proto, clk_proto, T}, ...
        '-histogram', ...
        '-o', mex_name);
    fprintf('MEX build complete: %s\n\n', mex_name);
end

%% ---- Pre-allocate Error Metrics Storage ----
sqnr_dB      = zeros(1, NUM_SEEDS);   % SQNR per seed (dB)
max_err      = zeros(1, NUM_SEEDS);   % max |y_test - y_ref| per seed
rms_err      = zeros(1, NUM_SEEDS);   % RMS |y_test - y_ref| per seed

fprintf('=== Fractional Audio FFT Error Analysis: MATLAB fft()  vs  %s ===\n', dt);
fprintf('Normalized Audio [-1, 1], Fs = %d Hz, N = %d, Seeds = %d\n\n', ...
    Fs, N, NUM_SEEDS);
fprintf('%-6s  %10s  %14s  %14s\n', 'Seed', 'SQNR (dB)', 'Max Err', 'RMS Err');
fprintf('%s\n', repmat('-', 1, 50));

%% ---- Main Simulation Loop ----
for seed = 1:NUM_SEEDS
    rng(seed);

    % --- Generate multi-tone audio input ---
    num_tones = randi([1, 4]);
    freqs     = 100 + rand(1, num_tones) * 9900;
    amps      = 0.1 + rand(1, num_tones) * 0.7;
    % Normalize amplitude to fit within [-1.0, 1.0] for digital fractional audio
    amps      = (amps / sum(amps)) * (0.95 * rand() + 0.05);
    phases    = rand(1, num_tones) * 2 * pi;

    t = (0:N-1) / Fs;
    x = zeros(1, N);
    for k = 1:num_tones
        x = x + amps(k) * sin(2*pi*freqs(k)*t + phases(k));
    end
    % x is now a fractional value in range [-1.0, 1.0], no integer rounding applied
    x = max(min(x, 1.0), -1.0);  % safety clamp to exact boundaries

    % --- Golden reference: MATLAB built-in fft() ---
    y_ref  = fft(double(x), N);          % exact, bit-true MATLAB reference

    % --- Type under test: our SDF pipeline ---
    x_test = cast(x, 'like', T.data_in);
    y_test = double(run_fft_sim(x_test, N, T));

    % --- Per-seed error metrics ---
    err_vec      = abs(y_test - y_ref);   % error magnitude per bin
    signal_power = mean(abs(y_ref).^2);
    noise_power  = mean(err_vec.^2);

    if noise_power < eps
        sqnr_dB(seed) = Inf;             % identical → perfect
    else
        sqnr_dB(seed) = 10 * log10(signal_power / noise_power);
    end

    max_err(seed)       = max(err_vec);
    rms_err(seed)       = sqrt(noise_power);

    fprintf('%-6d  %10.2f  %14.4e  %14.4e\n', ...
        seed, sqnr_dB(seed), max_err(seed), rms_err(seed));
end

%% ---- Numerical Summary Table ----
finite_sqnr = sqnr_dB(isfinite(sqnr_dB));   % exclude Inf (zero-error seeds)

fprintf('\n%s\n', repmat('=', 1, 55));
fprintf('  NUMERICAL ERROR SUMMARY:  MATLAB fft()  vs  %s\n', dt);
fprintf('%s\n', repmat('=', 1, 55));
fprintf('  %-28s %10s\n', 'Metric', 'Value');
fprintf('  %s\n', repmat('-', 1, 42));

if isempty(finite_sqnr)
    fprintf('  %-28s %10s\n', 'SQNR min  (dB)',  '+Inf (identical)');
    fprintf('  %-28s %10s\n', 'SQNR mean (dB)', '+Inf (identical)');
    fprintf('  %-28s %10s\n', 'SQNR max  (dB)', '+Inf (identical)');
else
    fprintf('  %-28s %10.2f\n', 'SQNR min  (dB)',  min(finite_sqnr));
    fprintf('  %-28s %10.2f\n', 'SQNR mean (dB)', mean(finite_sqnr));
    fprintf('  %-28s %10.2f\n', 'SQNR max  (dB)',  max(finite_sqnr));
end
fprintf('  %-28s %10.4e\n', 'Max abs error (worst seed)', max(max_err));
fprintf('  %-28s %10.4e\n', 'Mean max abs error',        mean(max_err));
fprintf('  %-28s %10.4e\n', 'RMS error (worst seed)',    max(rms_err));
fprintf('  %-28s %10.4e\n', 'Mean RMS error',           mean(rms_err));
fprintf('  %-28s %10d\n',   'Seeds with zero error',    sum(~isfinite(sqnr_dB)));
fprintf('%s\n\n', repmat('=', 1, 55));

%% ---- 4-Panel Visual Report ----
fft_freqs = (0:N-1) * (Fs / N);   % frequency axis in Hz

fig = figure('Name', sprintf('FFT Type Error Report: double vs %s', dt), ...
             'NumberTitle', 'off', ...
             'Position', [100 80 1200 820], ...
             'Color', [0.12 0.12 0.16]);

% Shared style
ax_bg    = [0.16 0.16 0.22];
ax_fg    = [0.90 0.90 0.95];
col_ref  = [0.35 0.75 1.00];    % blue  → reference
col_test = [1.00 0.55 0.25];    % orange→ test
col_err  = [1.00 0.30 0.45];    % red   → error
col_grid = [0.30 0.30 0.38];

% ---- Panel 1: SQNR Histogram ----------------------------------------
ax1 = subplot(2, 2, 1);
plot_sqnr = sqnr_dB(isfinite(sqnr_dB));   % drop Inf bins for hist
if isempty(plot_sqnr)
    text(0.5, 0.5, 'SQNR = \infty for all seeds', ...
        'HorizontalAlignment','center','Color',ax_fg,'FontSize',13,...
        'Units','normalized');
else
    histogram(plot_sqnr, 30, ...
        'FaceColor', col_ref, 'EdgeColor', 'none', 'FaceAlpha', 0.85);
    xline(mean(plot_sqnr), '--', sprintf('mean = %.1f dB', mean(plot_sqnr)), ...
        'Color', col_test, 'LineWidth', 1.5, 'FontSize', 10, ...
        'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','right');
end
title('SQNR Distribution', 'Color', ax_fg, 'FontSize', 13);
xlabel('SQNR (dB)', 'Color', ax_fg);
ylabel('Count (seeds)', 'Color', ax_fg);
set(ax1, 'Color', ax_bg, 'XColor', ax_fg, 'YColor', ax_fg, ...
    'GridColor', col_grid, 'XGrid','on','YGrid','on');

% ---- Panel 2: Max Absolute Error CDF ----------------------------------
ax2 = subplot(2, 2, 2);
sorted_err = sort(max_err);
cdf_y      = (1:NUM_SEEDS) / NUM_SEEDS;
semilogy(sorted_err, cdf_y * 100, 'Color', col_err, 'LineWidth', 2);
hold on;
xline(mean(max_err), '--', sprintf('mean = %.2e', mean(max_err)), ...
    'Color', col_test, 'LineWidth', 1.5, 'FontSize', 10, ...
    'LabelVerticalAlignment','top');
hold off;
title('Max Absolute Error CDF', 'Color', ax_fg, 'FontSize', 13);
xlabel('Max |error| per seed', 'Color', ax_fg);
ylabel('Cumulative probability (%)', 'Color', ax_fg);
set(ax2, 'Color', ax_bg, 'XColor', ax_fg, 'YColor', ax_fg, ...
    'GridColor', col_grid, 'XGrid','on','YGrid','on');
ylim([0.1 110]);
yticks([1 10 50 90 99 100]);

% ---- Panel 3: SQNR per Seed (stem) ------------------------------------
ax3 = subplot(2, 2, 3);
plot_seeds = 1:NUM_SEEDS;
finite_mask = isfinite(sqnr_dB);
if any(~finite_mask)
    if all(~finite_mask)
        y_val_inf = 200; % Arbitrary high value for display when all are Inf
    else
        y_val_inf = max(sqnr_dB(finite_mask)) * 1.05;
    end
    
    scatter(plot_seeds(~finite_mask), ...
            repmat(y_val_inf, 1, sum(~finite_mask)), ...
            20, col_ref, 'filled', 'DisplayName', 'SQNR = \infty');
    hold on;
end
stem(plot_seeds(finite_mask), sqnr_dB(finite_mask), ...
    'Color', col_ref, 'MarkerFaceColor', col_ref, ...
    'MarkerSize', 2, 'LineWidth', 0.5);
if any(~finite_mask), hold off; end
title('SQNR per Seed', 'Color', ax_fg, 'FontSize', 13);
xlabel('Seed index', 'Color', ax_fg);
ylabel('SQNR (dB)', 'Color', ax_fg);
set(ax3, 'Color', ax_bg, 'XColor', ax_fg, 'YColor', ax_fg, ...
    'GridColor', col_grid, 'XGrid','on','YGrid','on');
xlim([1 NUM_SEEDS]);

% ---- Panel 4: RMS Error vs Seed (line plot, style matches reference image) ----
ax4 = subplot(2, 2, 4);

plot(1:NUM_SEEDS, rms_err, ...
    'Color', col_ref, 'LineWidth', 1.2);
hold on;
% Mean line annotation
yline(mean(rms_err), '--', ...
    sprintf('mean = %.2e', mean(rms_err)), ...
    'Color', col_test, 'LineWidth', 1.5, 'FontSize', 10, ...
    'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment', 'right');
hold off;

title(sprintf('RMS Error vs Seed  (%s  vs  MATLAB fft())', dt), ...
    'Color', ax_fg, 'FontSize', 13);
xlabel('Seed', 'Color', ax_fg);
ylabel('Error', 'Color', ax_fg);
xlim([1 NUM_SEEDS]);
set(ax4, 'Color', ax_bg, 'XColor', ax_fg, 'YColor', ax_fg, ...
    'GridColor', col_grid, 'XGrid', 'on', 'YGrid', 'on');

% Global title
sgtitle(sprintf('FFT Quantisation Error Report:  MATLAB fft()  →  %s  |  %d seeds', ...
    dt, NUM_SEEDS), 'Color', ax_fg, 'FontSize', 15, 'FontWeight', 'bold');

%% ---- Show Instrumentation (fixed-point run only) ----
if strcmp(dt, 'fixed')
    fprintf('\n=== FIXED-POINT INSTRUMENTATION ===\n');
    showInstrumentationResults(mex_name);
end