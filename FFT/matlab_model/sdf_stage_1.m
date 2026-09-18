function data_out = sdf_stage_1(in_elem, clk, T) %#codegen
    DELAY_SIZE = 4;
    READ  = false;
    WRITE = true;

    persistent W8_ROM;
    if isempty(W8_ROM)
        W8_ROM = twiddle_Wx(8, T);
    end

    % Use 0-indexed counter for easier logic (0 to 7)
    counter = mod(clk, 8);

    % Cast incoming sample to pipeline type
    b = cast(in_elem, 'like', T.bf_B);

    % Always read from the delay line first
    delay_out = delay_x(cast(complex(0), 'like', T.reg4), DELAY_SIZE, READ, T);

    if counter < 4
        % Cycles 0, 1, 2, 3: Orange Path
        % 1. Multiply the delayed data by twiddle factor -> output it
        % 2. Store the incoming data into the delay line
        twiddle_idx = counter + 1;
        W = W8_ROM(twiddle_idx);

        mult_res = cast(delay_out * W, 'like', T.tw_prod);
        data_out = cast(mult_res, 'like', T.data_out);
        delay_x(b, DELAY_SIZE, WRITE, T);
    else
        % Cycles 4, 5, 6, 7: Blue Path
        % 1. Compute butterfly with delayed data (A) and incoming data (B)
        % 2. Output the SUM
        % 3. Store the SUB into the delay line
        a = cast(delay_out, 'like', T.bf_A);
        [SUM, SUB] = butterfly_R2(a, b, T);

        data_out = cast(SUM, 'like', T.data_out);
        delay_x(cast(SUB, 'like', T.bf_sub), DELAY_SIZE, WRITE, T);
    end
end