`ifndef FFT_TEST_BASE_SVH
`define FFT_TEST_BASE_SVH

class fft_test_base extends uvm_test;
    `uvm_component_utils(fft_test_base)

    fft_env env;

    function new(string name = "fft_test_base", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fft_env::type_id::create("env", this);
    endfunction

endclass

`endif