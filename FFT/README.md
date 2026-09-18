# 8-Point Radix-2 DIF SDF FFT — RTL Design & UVM Verification

> **Group Project** — developed during the ADI Summer Internship 2026
> **Contributors:**
> - [Bassel Mahmoud](https://github.com/basselmahmoud1)
> - [Omar Hussein Mostafa](https://github.com/Omar-hussein-mostafa)

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Repository Structure](#repository-structure)
- [UVM Testbench Architecture](#uvm-testbench-architecture)
- [MATLAB Golden Reference Model](#matlab-golden-reference-model)
- [Test Suite](#test-suite)
- [How to Run](#how-to-run)
- [Coverage](#coverage)
- [Dependencies](#dependencies)

---

## Overview

This project implements and fully verifies an **8-point Radix-2 Decimation-In-Frequency (DIF) Serial Data-Flow (SDF) FFT** processor in SystemVerilog.

The design uses a **pipelined SDF architecture** with fixed-point arithmetic (Q4.8 input, Q7.5 output) and was verified using a complete **UVM-based testbench** with a **bit-accurate MATLAB reference model**.

Key highlights:
- 8-point complex FFT using 3-stage SDF pipeline
- Fixed-point arithmetic with bit-accurate RTL-MATLAB co-verification
- Full UVM testbench with scoreboard, subscriber, and functional coverage
- 15 directed test cases + regression suite with coverage merging
- Automatic plot generation per test using MATLAB

---

## Architecture

```
                        FFT_WRAPPER
                        |
                        +-- FFT_Top
                               |-- Control_unit   (FSM + MUX control signals + valid_out)
                               |-- ROM             (Twiddle factor LUT -- W8^0 to W8^3 in Q2.10)
                               +-- SDF_STAGE       (3-stage pipelined datapath)
                                      |-- BUTTERFLY     (radix-2 add/sub)
                                      |-- Complex_MULT  (complex multiplier)
                                      |-- DELAY         (shift register delays)
                                      +-- Counter        (timing sequencer)
```

### Signal Interface

| Signal      | Direction | Width  | Description                                      |
|-------------|-----------|--------|--------------------------------------------------|
| `clk`       | Input     | 1      | System clock                                     |
| `rstn`      | Input     | 1      | Active-low synchronous reset                     |
| `valid_in`  | Input     | 1      | Input data valid strobe                          |
| `DIN`       | Input     | 24-bit | Complex input `{re[11:0], im[11:0]}` in Q4.8    |
| `DOUT`      | Output    | 24-bit | Complex output `{re[11:0], im[11:0]}` in Q7.5   |
| `Valid_out` | Output    | 1      | Output data valid strobe                         |

---

## Repository Structure

```
FFT/
|-- README.md                    <- This file
|-- .gitignore                   <- Excludes build artifacts
|
|-- UVM_TB/
|   |-- sim/
|   |   |-- Makefile             <- Main build & simulation script (QuestaSim)
|   |   |-- filelist_rtl.f       <- RTL source file list
|   |   |-- filelist_tb.f        <- Testbench file list
|   |   +-- plot_regression.m    <- MATLAB regression plot generator
|   |
|   |-- src/                     <- RTL Design Sources (DUT)
|   |   |-- FFT_WRAPPER.sv       <- Top-level DUT wrapper
|   |   |-- FFT_Top.sv           <- FFT top-level structural module
|   |   |-- SDF_STAGE.sv         <- 3-stage SDF pipelined datapath
|   |   |-- BUTTERFLY.sv         <- Radix-2 butterfly (add/sub)
|   |   |-- Complex_MULT.sv      <- Fixed-point complex multiplier
|   |   |-- Complex_pack.sv      <- SV package (complex_data_t typedef)
|   |   |-- Control_unit.sv      <- FSM - generates MUX selects and valid_out
|   |   |-- Counter.sv           <- Timing counter
|   |   |-- DELAY.sv             <- Configurable shift-register delay
|   |   +-- ROM.sv               <- Twiddle factor ROM (W8^0 to W8^3)
|   |
|   |-- tb/
|   |   |-- agents/fft/          <- UVM Agent
|   |   |   |-- fft_agent.svh
|   |   |   |-- fft_agent_config.svh
|   |   |   |-- fft_driver.svh
|   |   |   |-- fft_monitor.svh
|   |   |   |-- fft_seq_item.svh
|   |   |   |-- fft_sequencer.svh
|   |   |   |-- fft_types.svh
|   |   |   +-- sequences/       <- All stimulus sequences
|   |   |-- env/
|   |   |   |-- fft_env.svh          <- UVM Environment
|   |   |   |-- fft_scoreboard.svh   <- Self-checking scoreboard
|   |   |   +-- fft_subscriber.svh   <- Functional coverage collector
|   |   |-- interfaces/
|   |   |   +-- fft_interface.sv     <- SystemVerilog interface
|   |   +-- top/
|   |       +-- top.sv               <- TB top module (clk gen, reset, DUT bind)
|   |
|   +-- test/
|       |-- fft_test_base.svh        <- Base test class
|       |-- fft_test_pkg.sv          <- Test package
|       +-- specific_tests/          <- 15 directed test classes
|
+-- matlab_model/                <- MATLAB Golden Reference Model
    |-- run_fft_model.m          <- Main entry point - generates fft_out_ref.txt
    |-- top_fft.m                <- Top-level FFT model
    |-- butterfly_R2.m           <- Radix-2 butterfly model
    |-- sdf_stage_1/2/3.m        <- Per-stage fixed-point models
    |-- twiddle_Wx.m             <- Twiddle factor generator
    |-- delay_x.m                <- Delay model
    +-- test/                    <- MATLAB standalone unit tests
```

---

## UVM Testbench Architecture

```
  +-------------------------------------------------------------+
  |                         fft_env                             |
  |                                                             |
  |  +------------------+    +------------------------------+   |
  |  |    fft_agent     |    |      fft_scoreboard          |   |
  |  |                  |    |                              |   |
  |  | fft_sequencer ---|--► | - Reads fft_out_ref.txt     |   |
  |  | fft_driver    ---|--► |   (MATLAB golden reference) |   |
  |  | fft_monitor   ---|--► | - Compares DUT DOUT output  |   |
  |  |                  |    | - Tolerance: +/-2 LSB       |   |
  |  +------------------+    +------------------------------+   |
  |                                                             |
  |                          +------------------------------+   |
  |                          |     fft_subscriber           |   |
  |                          |   (functional coverage)      |   |
  |                          +------------------------------+   |
  +-------------------------------------------------------------+
               |
          fft_interface
               |
          FFT_WRAPPER (DUT)
```

### Scoreboard Checking

The scoreboard compares DUT outputs against the MATLAB-generated reference with a **tolerance of +-2 LSB** to account for fixed-point rounding differences between the RTL implementation and the model.

---

## MATLAB Golden Reference Model

`matlab_model/run_fft_model.m` is a **bit-accurate** reference model that mirrors every operation in the RTL exactly:

- **Stage 1:** Floor division by 4 (ADD path), floor division by 2 (SUB path), complex multiply with Q2.10 twiddles via 11-bit arithmetic right-shift
- **Stage 2:** 12-bit wrapped add/sub, complex multiply with 10-bit arithmetic right-shift
- **Stage 3:** Floor division by 2 for both ADD and SUB paths, no twiddle (W8^0 = 1)

The model is called automatically from the UVM sequence (`fft_sequence_matlab_ref`) during simulation:

```
matlab -batch "cd ../../matlab_model; run_fft_model; exit"
```

It reads `fft_in.txt` (Q4.8 integer pairs) and writes `fft_out_ref.txt` (Q7.5 integer pairs), which are then consumed by the scoreboard.

---

## Test Suite

| Test Name                          | Input Pattern                         |
|------------------------------------|---------------------------------------|
| `fft_test_all_zeros`               | All-zero input                        |
| `fft_test_alternating`             | Alternating +max / -max               |
| `fft_test_real_ramp`               | Linear real ramp, zero imaginary      |
| `fft_test_deterministic_complex`   | Fixed complex pattern                 |
| `fft_test_impulse_n0`              | Unit impulse at sample 0              |
| `fft_test_impulse_n3`              | Unit impulse at sample 3              |
| `fft_test_dc_pos`                  | Positive DC (constant real input)     |
| `fft_test_dc_neg`                  | Negative DC (constant neg input)      |
| `fft_test_cos_bin1`                | Cosine at bin 1                       |
| `fft_test_complex_sinusoid_bin1`   | Complex sinusoid at bin 1             |
| `fft_test_lsb_pattern`             | LSB toggle stress pattern             |
| `fft_test_max_positive_impulse`    | Maximum positive value impulse        |
| `fft_test_min_negative_impulse`    | Minimum negative value impulse        |
| `fft_test_maxmin_pair`             | Max/min interleaved pair              |
| `fft_test_mixed_corners`           | Mix of corner cases                   |
| `fft_test_matlab`                  | Random input with MATLAB golden ref   |

---

## How to Run

> **Prerequisites:** QuestaSim / ModelSim installed, MATLAB on system PATH.

### Single test (batch mode)
```bash
cd FFT/UVM_TB/sim
make TEST=fft_test_impulse_n0
```

### Single test in GUI mode
```bash
make gui TEST=fft_test_dc_pos
```

### Full regression suite
```bash
make regression
```
This will:
1. Compile the RTL and testbench
2. Run all 15 tests sequentially
3. Merge all coverage databases into `regression.ucdb`
4. Generate an HTML coverage report in `cov_report/`
5. Generate per-test waveform plots via MATLAB (`plot_regression.m`)

### Generate coverage report only
```bash
make coverage_report
```

### Clean build artifacts
```bash
make clean      # removes work/, logs, ucdb files
make cleanall   # also removes runs_outputs/, cov_report/, reports/
```

---

## Coverage

The testbench collects both:

- **Code coverage** — statement, branch, condition, toggle, FSM
  (QuestaSim `+cover=bcesfx` flag)
- **Functional coverage** — collected in `fft_subscriber.svh`

Coverage is reported per DUT module: `FFT_WRAPPER`, `FFT_Top`, `BUTTERFLY`, `SDF_STAGE`.

---

## Dependencies

| Tool / Library | Version     | Purpose                        |
|----------------|-------------|--------------------------------|
| QuestaSim      | 2020+       | Simulation & coverage          |
| UVM            | 1.2         | Testbench framework            |
| MATLAB         | R2020+      | Golden reference model & plots |
| SystemVerilog  | IEEE 1800   | RTL & testbench language       |
