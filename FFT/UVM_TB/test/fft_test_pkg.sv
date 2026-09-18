`ifndef FFT_TEST_PKG_SV
`define FFT_TEST_PKG_SV

package fft_test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import fft_env_pkg::*;
    import fft_agent_pkg::*;

    `include "fft_test_base.svh"
    `include "specific_tests/fft_test_matlab.svh"
    `include "specific_tests/fft_test_sanity.svh"
    `include "specific_tests/fft_test_sin.svh"
    `include "specific_tests/fft_test_all_zeros.svh"
    `include "specific_tests/fft_test_alternating.svh"
    `include "specific_tests/fft_test_real_ramp.svh"
    `include "specific_tests/fft_test_deterministic_complex.svh"
    `include "specific_tests/fft_test_impulse_n0.svh"
    `include "specific_tests/fft_test_impulse_n3.svh"
    `include "specific_tests/fft_test_dc_pos.svh"
    `include "specific_tests/fft_test_dc_neg.svh"
    `include "specific_tests/fft_test_cos_bin1.svh"
    `include "specific_tests/fft_test_complex_sinusoid_bin1.svh"
    `include "specific_tests/fft_test_lsb_pattern.svh"
    `include "specific_tests/fft_test_max_positive_impulse.svh"
    `include "specific_tests/fft_test_min_negative_impulse.svh"
    `include "specific_tests/fft_test_maxmin_pair.svh"
    `include "specific_tests/fft_test_mixed_corners.svh"

endpackage

`endif
