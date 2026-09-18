N = 8;
disp(['Generating twiddle factors for N = ', num2str(N)]);

W8 = twiddle_Wx(N);

for k = 0:(N/2)-1
    fprintf('W8^%d = %f + %fi\n', k, real(W8(k+1)), imag(W8(k+1)));
end
