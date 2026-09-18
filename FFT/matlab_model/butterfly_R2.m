function [ADD, SUB] = butterfly_R2(in1, in2, T) %#codegen

ADD = cast(in1 + in2, 'like', T.bf_sum);
SUB = cast(in1 - in2, 'like', T.bf_sub);

end