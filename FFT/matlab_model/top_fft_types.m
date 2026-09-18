function T = top_fft_types(dt)
% TOP_FFT_TYPES  Data type table for the 8-point Radix-2 DIF SDF FFT.
%
%  T = top_fft_types('double')  -- Step 1: baseline floating-point
%  T = top_fft_types('single')  -- Step 2: catch type-mismatch bugs
%  T = top_fft_types('fixed')   -- Step 3: fixed-point for hardware
%
%  Usage (in test bench):
%      T  = top_fft_types('double');
%      x  = cast(input_signal, 'like', T.data_in);
%
%  All signals are COMPLEX (real + imag parts share the same numerictype).

switch dt

    % ------------------------------------------------------------------ %
    case 'double'
    % ------------------------------------------------------------------ %
        % ---- Data path ----
        T.data_in   = complex(double([]));   % Serial input sample
        T.data_out  = complex(double([]));   % Serial output sample

        % ---- Delay-line registers ----
        T.reg4      = complex(double([]));   % 4-tap shift register (stage 1)
        T.reg2      = complex(double([]));   % 2-tap shift register (stage 2)
        T.reg1      = complex(double([]));   % 1-tap shift register (stage 3)

        % ---- Butterfly signals ----
        T.bf_A      = complex(double([]));   % Butterfly input A (from delay)
        T.bf_B      = complex(double([]));   % Butterfly input B (new sample)
        T.bf_sum    = complex(double([]));   % Butterfly output: A + B
        T.bf_sub    = complex(double([]));   % Butterfly output: A - B

        % ---- Twiddle factors (ROM) ----
        T.twiddle   = complex(double([]));   % W_N^k  coefficient
        T.tw_prod   = complex(double([]));   % Twiddle multiplication result

    % ------------------------------------------------------------------ %
    case 'single'
    % ------------------------------------------------------------------ %
        % ---- Data path ----
        T.data_in   = complex(single([]));
        T.data_out  = complex(single([]));

        % ---- Delay-line registers ----
        T.reg4      = complex(single([]));
        T.reg2      = complex(single([]));
        T.reg1      = complex(single([]));

        % ---- Butterfly signals ----
        T.bf_A      = complex(single([]));
        T.bf_B      = complex(single([]));
        T.bf_sum    = complex(single([]));
        T.bf_sub    = complex(single([]));

        % ---- Twiddle factors (ROM) ----
        T.twiddle   = complex(single([]));
        T.tw_prod   = complex(single([]));

    % ------------------------------------------------------------------ %
    case 'fixed'
    % ------------------------------------------------------------------ %
        %  Word-length / fraction-length design notes
        %  ------------------------------------------
        %  Input word length  : 12 bits  (1 sign + 1 integer + 14 fraction)
        %  After butterfly ADD: grows by 1 bit  -> 17 bits  (guard bit)
        %  After butterfly SUB: same growth      -> 17 bits
        %  After twiddle MUL : re-rounded back  -> 17 bits  (truncate LSBs)
        %  Twiddle ROM        : 12 bits (all fractional: range [-1, 1))
        %
        %  Signed, Round-to-nearest, Saturate on overflow.
        %  Adjust WL / FL as needed once instrumentation data is available.

        % ---- Data path (12-bit, s1.14) ----
        T.data_in  = fi(complex(0), 1, 12, 8 );
        T.data_out = fi(complex(0), 1, 12, 7 );

        % ---- Delay-line registers (12-bit, s1.14) ----
        T.reg4      = complex(single([]));
        T.reg2      = complex(single([]));
        T.reg1      = complex(single([]));

        % ---- Butterfly inputs (12-bit, s1.14) ----
        T.bf_A     = fi(complex(0), 1, 12, 14 );
        T.bf_B     = fi(complex(0), 1, 12, 14 );

        % ---- Butterfly outputs: +1 guard bit to prevent overflow ----
        %  ADD / SUB of two s1.14 values -> s2.14 (17-bit)
        T.bf_sum   = fi(complex(0), 1, 17, 14 );
        T.bf_sub   = fi(complex(0), 1, 17, 14 );

        % ---- Twiddle factor ROM (12-bit, s1.15) ----
        %  Values are in [-1, 1) so we use all 15 fraction bits.
        T.twiddle  = fi(complex(0), 1, 12, 15 );

        % ---- Twiddle multiplication result (re-rounded to s2.14) ----
        %  s2.14 * s1.15 full product = s3.29; we round back to 17-bit s2.14
        T.tw_prod  = fi(complex(0), 1, 17, 14 );

    otherwise
        error('top_fft_types: unknown data type ''%s''. Use ''double'', ''single'', or ''fixed''.', dt);
end
end
