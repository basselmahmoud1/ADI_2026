`ifndef FFT_AGENT_PKG_SV
`define FFT_AGENT_PKG_SV

package fft_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "fft_types.svh"
    `include "fft_seq_item.svh"
    `include "fft_sequencer.svh"
    `include "fft_agent_config.svh"
    `include "fft_driver.svh"
    `include "fft_monitor.svh"
    `include "fft_agent.svh"
    
    `include "sequences/fft_sequence_matlab_ref.svh"
    `include "sequences/fft_sequence_impulse.svh"
    `include "sequences/fft_sequence_sin.svh"
    `include "sequences/fft_sequence_vector_base.svh"
    `include "sequences/fft_sequence_all_zeros.svh"
    `include "sequences/fft_sequence_alternating.svh"
    `include "sequences/fft_sequence_real_ramp.svh"
    `include "sequences/fft_sequence_deterministic_complex.svh"
    `include "sequences/fft_sequence_impulse_n0.svh"
    `include "sequences/fft_sequence_impulse_n3.svh"
    `include "sequences/fft_sequence_dc_pos.svh"
    `include "sequences/fft_sequence_dc_neg.svh"
    `include "sequences/fft_sequence_cos_bin1.svh"
    `include "sequences/fft_sequence_complex_sinusoid_bin1.svh"
    `include "sequences/fft_sequence_lsb_pattern.svh"
    `include "sequences/fft_sequence_max_positive_impulse.svh"
    `include "sequences/fft_sequence_min_negative_impulse.svh"
    `include "sequences/fft_sequence_maxmin_pair.svh"
    `include "sequences/fft_sequence_mixed_corners.svh"

endpackage

`endif
