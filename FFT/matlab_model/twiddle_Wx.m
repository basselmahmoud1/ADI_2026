function Wx_ROM = twiddle_Wx(N, T) %#codegen

Wx_ROM = cast(complex(zeros(1, N/2)), 'like', T.twiddle);
for indx = 1:N/2
    k = indx - 1;
    Wx_ROM(indx) = cast(exp(-1i * 2 * pi * k / N), 'like', T.twiddle);
end

end