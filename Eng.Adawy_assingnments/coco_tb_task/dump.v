module dump;
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, ALU);
    end
endmodule