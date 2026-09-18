`ifndef FFT_ENV_PKG_SV
`define FFT_ENV_PKG_SV

package fft_env_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*;

    import fft_agent_pkg::*;
    export fft_agent_pkg::*;

    `include "fft_scoreboard.svh"
    `include "fft_subscriber.svh"
    `include "fft_env.svh"

endpackage

`endif