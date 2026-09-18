function data_out = sdf_stage_3(in_elem, clk, T) %#codegen
    DELAY_SIZE = 1;
    READ  = false;
    WRITE = true;

    % Use 0-indexed counter for easier logic (0 to 7)
    counter = mod(clk, 2);

    % Cast incoming sample to pipeline type
    b = cast(in_elem, 'like', T.bf_B);

    % Always read from the delay line first
    delay_out = delay_x(cast(complex(0), 'like', T.reg1), DELAY_SIZE, READ, T);

    if counter < 1
        % Cycle 0: Orange Path
        % Twiddle factor is always W_8^0 = 1, so no multiplication needed.
        data_out = cast(delay_out, 'like', T.data_out);
        delay_x(b, DELAY_SIZE, WRITE, T);
    else
        % Cycle 1: Blue Path
        % 1. Compute butterfly with delayed data (A) and incoming data (B)
        % 2. Output the SUM
        % 3. Store the SUB into the delay line
        a = cast(delay_out, 'like', T.bf_A);
        [SUM, SUB] = butterfly_R2(a, b, T);

        data_out = cast(SUM, 'like', T.data_out);
        delay_x(cast(SUB, 'like', T.bf_sub), DELAY_SIZE, WRITE, T);
    end
end