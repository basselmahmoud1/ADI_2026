function output = delay_x(input, delay_select, write_enable, T) %#codegen

persistent reg_4;
persistent reg_2;
persistent reg_1;

% Output initialised to correct type so codegen can infer it
output = cast(complex(0), 'like', T.reg4);

if delay_select == 4

    if isempty(reg_4)
        reg_4 = cast(complex(zeros(1, 4)), 'like', T.reg4);
    end

    % Always read the oldest data
    output = reg_4(1);

    % Update memory only when enabled
    if write_enable
        reg_4(1:end-1) = reg_4(2:end);
        reg_4(end) = cast(input, 'like', T.reg4);
    end
end

if delay_select == 2

    if isempty(reg_2)
        reg_2 = cast(complex(zeros(1, 2)), 'like', T.reg2);
    end

    % Always read the oldest data
    output = cast(reg_2(1), 'like', T.reg2);

    % Update memory only when enabled
    if write_enable
        reg_2(1:end-1) = reg_2(2:end);
        reg_2(end) = cast(input, 'like', T.reg2);
    end
end

if delay_select == 1

    if isempty(reg_1)
        reg_1 = cast(complex(zeros(1, 1)), 'like', T.reg1);
    end

    % Always read the oldest data
    output = cast(reg_1(1), 'like', T.reg1);

    % Update memory only when enabled
    if write_enable
        reg_1(1:end-1) = reg_1(2:end);
        reg_1(end) = cast(input, 'like', T.reg1);
    end
end

end