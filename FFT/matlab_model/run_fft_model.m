% run_fft_model.m
% UVM offline reference model — bit-accurate to SDF_STAGE.sv.
%
% Reads  : ../UVM_TB/sim/fft_in.txt      (Q4.8 stored integers, 8 lines of "re im")
% Writes : ../UVM_TB/sim/fft_out_ref.txt (Q7.5 stored integers, 8 lines of "re im")
%
% The reference is computed by fft8_rtl_fixed() which mirrors every RTL
% bit-slice, floor-truncation, and quantised ROM twiddle in SDF_STAGE.sv /
% Complex_MULT.sv / ROM.sv exactly.  No empirical scale factor is needed.

%% 1. Read input file
in_fid = fopen('../UVM_TB/sim/fft_in.txt', 'r');
if in_fid == -1
    error('Could not open fft_in.txt');
end
A = fscanf(in_fid, '%d %d', [2, 8]);   % 2 rows x 8 cols
fclose(in_fid);

x_re = double(A(1,:));   % Q4.8 stored integers — kept as integers
x_im = double(A(2,:));

%% 2. Compute bit-accurate reference
[exp_re, exp_im] = fft8_rtl_fixed(x_re, x_im);
% exp_re/exp_im are already Q7.5 stored integers in DUT serial output order:
% [bin0 bin4 bin2 bin6 bin1 bin5 bin3 bin7]

%% 3. Write output file
out_fid = fopen('../UVM_TB/sim/fft_out_ref.txt', 'w');
if out_fid == -1
    error('Could not create fft_out_ref.txt');
end
for i = 1:8
    fprintf(out_fid, '%d %d\n', exp_re(i), exp_im(i));
end
fclose(out_fid);

disp('MATLAB: fft_out_ref.txt generated successfully (bit-accurate RTL model).');
% exit;


% =========================================================================
function [o_re, o_im] = fft8_rtl_fixed(x_re, x_im)
% Bit-accurate model of SDF_STAGE.sv.
% Inputs  : x_re, x_im  — signed 12-bit Q4.8 stored integers
% Outputs : o_re, o_im  — signed 12-bit Q7.5 stored integers
%           in DUT serial DIF order: [bin0 bin4 bin2 bin6 bin1 bin5 bin3 bin7]

    % ROM.sv twiddles in Q2.10 (scale=1024): W8^0, W8^1, W8^2, W8^3
    tw_re = [1024,  724,     0, -724];
    tw_im = [   0, -724, -1024, -724];

    s1_re = zeros(1,8);  s1_im = zeros(1,8);
    s2_re = zeros(1,8);  s2_im = zeros(1,8);
    s3_re = zeros(1,8);  s3_im = zeros(1,8);

    % ---- Stage 1 ------------------------------------------------
    % Butterfly spacing = 4.
    % ADD path : temp_ADD1[12:2] with sign-ext = arithmetic >> 2  (floor /4)
    % SUB path : temp_SUB1[12:1]              = arithmetic >> 1  (floor /2)
    % CMULT1   : temp_mult[22:11]             = arithmetic >> 11
    for k = 1:4
        add_re = floor((x_re(k) + x_re(k+4)) / 4);
        add_im = floor((x_im(k) + x_im(k+4)) / 4);
        sub_re = floor((x_re(k) - x_re(k+4)) / 2);
        sub_im = floor((x_im(k) - x_im(k+4)) / 2);

        s1_re(k) = wrap12(add_re);
        s1_im(k) = wrap12(add_im);

        % SUB side goes through twiddle multiply before storage
        sub_re = wrap12(sub_re);
        sub_im = wrap12(sub_im);
        [s1_re(k+4), s1_im(k+4)] = cmult_slice( ...
            sub_re, sub_im, tw_re(k), tw_im(k), 11);
    end

    % ---- Stage 2 ------------------------------------------------
    % Butterfly spacing = 2 inside each 4-point group.
    % ADD/SUB : temp[11:0] = 12-bit wrap, no fractional drop
    % CMULT2  : temp_mult[21:10] = arithmetic >> 10
    % ROM_ADDR2 cycles 0,2,0,2 -> twiddle indices 1,3,1,3
    tw2_idx = [1, 3];   % W8^0, W8^2

    for g = 1:2                     % group 1 = samples 1-4, group 2 = samples 5-8
        base = (g-1)*4 + 1;
        for k = 0:1
            ia = base + k;
            ib = base + k + 2;

            add_re = wrap12(s1_re(ia) + s1_re(ib));
            add_im = wrap12(s1_im(ia) + s1_im(ib));
            sub_re = wrap12(s1_re(ia) - s1_re(ib));
            sub_im = wrap12(s1_im(ia) - s1_im(ib));

            s2_re(ia) = add_re;
            s2_im(ia) = add_im;

            ti = tw2_idx(k+1);
            [s2_re(ib), s2_im(ib)] = cmult_slice( ...
                sub_re, sub_im, tw_re(ti), tw_im(ti), 10);
        end
    end

    % ---- Stage 3 ------------------------------------------------
    % Butterfly spacing = 1.
    % ADD/SUB : temp[12:1] = arithmetic >> 1  (floor /2)  -> Q7.5
    % No twiddle (W8^0 = 1 always).
    for base = [1 3 5 7]
        ar = s2_re(base);    ai = s2_im(base);
        br = s2_re(base+1);  bi = s2_im(base+1);

        s3_re(base)   = wrap12(floor((ar + br) / 2));
        s3_im(base)   = wrap12(floor((ai + bi) / 2));
        s3_re(base+1) = wrap12(floor((ar - br) / 2));
        s3_im(base+1) = wrap12(floor((ai - bi) / 2));
    end

    % DIF radix-2 natural output order is already bit-reversed:
    % position 1->bin0, 2->bin4, 3->bin2, 4->bin6,
    %          5->bin1, 6->bin5, 7->bin3, 8->bin7
    o_re = s3_re;
    o_im = s3_im;
end


% =========================================================================
function [c_re, c_im] = cmult_slice(a_re, a_im, b_re, b_im, shift)
% Mirrors Complex_MULT.sv: full integer multiply then extract [shift+11:shift].
    prod_re = a_re*b_re - a_im*b_im;
    prod_im = a_re*b_im + a_im*b_re;
    c_re = wrap12(floor(prod_re / 2^shift));
    c_im = wrap12(floor(prod_im / 2^shift));
end


% =========================================================================
function y = wrap12(x)
% Signed 12-bit two's-complement wrap — matches logic signed [11:0].
    y = mod(x, 4096);
    y(y >= 2048) = y(y >= 2048) - 4096;
end