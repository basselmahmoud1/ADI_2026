% plot_regression.m
% Plots regression results for every test case under runs_outputs/.
%
% File format assumptions (must stay in sync with run_fft_model.m):
%   fft_in.txt      : Q4.8 stored integers  -> divide by 2^8 = 256 to display real values
%   fft_out_ref.txt : Q7.5 stored integers  -> divide by 2^5 =  32 to display real values
%   dut_out.txt     : Q7.5 stored integers  -> divide by 2^5 =  32 to display real values
%
% Error panel keeps raw integer difference (LSB units) so +-1 in the
% plot maps directly to +-1 LSB tolerance in the UVM scoreboard.

Q_IN  = 2^8;   % Q4.8 input  scale factor = 256
Q_OUT = 2^5;   % Q7.5 output scale factor =  32

disp('Starting MATLAB plotting script for regression runs...');

base_dir = 'runs_outputs';
if ~isfolder(base_dir)
    disp('runs_outputs directory not found. Exiting.');
    return;
end

items = dir(base_dir);
for i = 1:length(items)
    if items(i).isdir && ~strcmp(items(i).name, '.') && ~strcmp(items(i).name, '..')

        test_name = items(i).name;
        test_dir  = fullfile(base_dir, test_name);

        in_file  = fullfile(test_dir, 'fft_in.txt');
        ref_file = fullfile(test_dir, 'fft_out_ref.txt');
        dut_file = fullfile(test_dir, 'dut_out.txt');

        if isfile(in_file) && isfile(ref_file) && isfile(dut_file)
            try
                %% Load raw stored integers
                in_data  = load(in_file);    % Q4.8 integers
                ref_data = load(ref_file);   % Q7.5 integers
                dut_data = load(dut_file);   % Q7.5 integers

                N = min([size(in_data,1), size(ref_data,1), size(dut_data,1)]);
                if N == 0
                    disp(['Warning: empty data files for ', test_name]);
                    continue;
                end

                %% Convert to real values for display
                in_re  = in_data(1:N,1)  / Q_IN;
                in_im  = in_data(1:N,2)  / Q_IN;
                ref_re = ref_data(1:N,1) / Q_OUT;
                ref_im = ref_data(1:N,2) / Q_OUT;
                dut_re = dut_data(1:N,1) / Q_OUT;
                dut_im = dut_data(1:N,2) / Q_OUT;

                %% Error in LSB units (integer difference — no division)
                err_re  = dut_data(1:N,1) - ref_data(1:N,1);
                err_im  = dut_data(1:N,2) - ref_data(1:N,2);
                max_err = max(abs([err_re; err_im]));

                %% Build figure
                fig = figure('Visible', 'off', 'Position', [100, 100, 1100, 850]);
                title_base = strrep(test_name, '_', '\_');

                % Panel 1 - Input samples (real values)
                subplot(3,1,1);
                stem(in_re, 'filled', 'DisplayName', 'Real');
                hold on;
                stem(in_im, 'filled', 'DisplayName', 'Imag');
                title(['Input (Q4.8 real values): ', title_base]);
                xlabel('Sample index');
                ylabel('Amplitude');
                legend('Location', 'best');
                grid on;

                % Panel 2 - Output comparison (real values)
                % Panel 2 - Output magnitude comparison
                subplot(3,1,2);

                ref_mag = sqrt(ref_re.^2 + ref_im.^2);
                dut_mag = sqrt(dut_re.^2 + dut_im.^2);

                stem(ref_mag, '-o', 'LineWidth', 2, 'DisplayName', 'Ref Magnitude');
                hold on;
                stem(dut_mag, '--*', 'DisplayName', 'DUT Magnitude');

                title(['Output magnitude comparison (Q7.5): ', title_base]);
                xlabel('Frequency bin');
                ylabel('Magnitude');
                legend('Location', 'best');
                grid on;

                % Panel 3 - Error in LSB units
                subplot(3,1,3);
                stem(err_re, 'filled', 'DisplayName', 'Real error');
                hold on;
                stem(err_im, 'filled', 'DisplayName', 'Imag error');
                title(sprintf('DUT vs Ref error (Q7.5 LSBs)   max|err| = %d LSB', max_err));
                xlabel('Frequency bin');
                ylabel('Error (LSB)');
                legend('Location', 'best');
                grid on;

                %% Save and close
                out_img = fullfile(test_dir, 'plot.png');
                saveas(fig, out_img);
                close(fig);
                disp(['Generated plot for ', test_name, ...
                      sprintf('  (max error = %d LSB)', max_err)]);

            catch ME
                disp(['Error plotting ', test_name, ': ', ME.message]);
            end

        else
            disp(['Skipping ', test_name, ': missing data files.']);
        end
    end
end

disp('MATLAB plotting complete.');