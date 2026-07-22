# ALU Verification — Class-Based SystemVerilog Testbench

> **Simulator:** ModelSim / QuestaSim  
> **Language:** SystemVerilog (IEEE 1800-2017)  
> **DUT:** 4-bit Parameterizable ALU (`ALU.sv`)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [DUT Description](#2-dut-description)
3. [Testbench Architecture](#3-testbench-architecture)
4. [File Structure](#4-file-structure)
5. [How to Run the Simulation](#5-how-to-run-the-simulation)
6. [Waveform Viewing](#6-waveform-viewing)
7. [Coverage Reports](#7-coverage-reports)
8. [Supported ALU Operations](#8-supported-alu-operations)

---

## 1. Project Overview

This project implements a **class-based, layered verification environment** for a 4-bit ALU written in SystemVerilog.  
The testbench follows a structured verification methodology with the following components:

- **Generator** — Produces randomized/constrained stimulus transactions
- **Driver** — Translates transactions to interface-level pin wiggling
- **Monitor** — Observes DUT outputs and packs them into transactions
- **Scoreboard** — Compares DUT output against a golden reference model
- **Subscriber** — Collects functional coverage
- **Environment** — Wires all components together
- **Test** — Top-level test that configures and launches the environment

---

## 2. DUT Description

**Module:** `ALU`  
**Parameter:** `WIDTH = 4` (data bus width, default 4-bit)

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | Input | 1 | System clock |
| `rst` | Input | 1 | Synchronous active-high reset |
| `a` | Input | 4 | Operand A (signed) |
| `b` | Input | 4 | Operand B (signed) |
| `op_code` | Input | 2 | Operation select (`alu_opcode_t`) |
| `result` | Output | 4 | ALU result (signed) |
| `z` | Output | 1 | Zero flag |
| `n` | Output | 1 | Negative flag |
| `c` | Output | 1 | Carry flag |
| `v` | Output | 1 | Overflow flag |

The ALU is **fully registered** — all outputs are updated on the positive clock edge.

---

## 3. Testbench Architecture

```
+------------------------------------------------------------------+
|                          TOP MODULE                              |
|                                                                  |
|   +-----------+  gen2drv_mb  +----------+                        |
|   | Generator |------------->|  Driver  |----------+             |
|   +-----------+              +----------+          |             |
|                                                    v             |
|                                             +----------+         |
|                                             |  ALU_IF  |         |
|                                             |(Interface)|        |
|                                             +----------+         |
|                                                    |             |
|   +-----------+  mon2subSb   +----------+          |             |
|   |Scoreboard |<-------------|  Monitor |<---------+             |
|   +-----------+              +----------+                        |
|                                   |                              |
|                             +----------+                         |
|                             |Subscriber|  (Functional Coverage)  |
|                             +----------+                         |
+------------------------------------------------------------------+
```

**Communication** between components uses **SystemVerilog Mailboxes** (`mailbox`) for type-safe, blocking message passing.

---

## 4. File Structure

```
ALU_Verification/
|
+-- ALU_pkg.sv                  # Package: ALU opcode enum (alu_opcode_t)
+-- ALU.sv                      # DUT: 4-bit parameterizable ALU
+-- interface.sv                # ALU_IF: SystemVerilog interface
+-- pack.sv                     # TB package: imports all .svh classes
|
+-- class_base.svh              # Base class for all TB components
+-- class_based_transaction.svh # Transaction data object
+-- class_based_generator.svh   # Constrained-random stimulus generator
+-- class_based_driver.svh      # Drives transactions onto the DUT interface
+-- class_based_monitor.svh     # Samples DUT outputs into transactions
+-- class_based_scoreboard.svh  # Golden model checker & error reporter
+-- class_based_subscriber.svh  # Functional coverage collector
+-- class_based_env.svh         # Environment: connects all components
+-- class_based_test.svh        # Top-level test entry point
|
+-- Top.sv                      # Simulation top-level module
|
+-- run.do                      # ModelSim automation script (compile + sim)
+-- wave.do                     # Waveform configuration script
+-- src_files.list              # Ordered list of source files
|
+-- coverage_report.txt         # Coverage report (generated after sim)
+-- sim_run.log                 # Simulation log (generated after sim)
```

---

## 5. How to Run the Simulation

### Prerequisites

- **ModelSim** or **QuestaSim** installed and available in your system `PATH`
- All source files present in the same directory

### Option A — Automated Script (Recommended)

Open **ModelSim**, navigate to the `ALU_Verification/` directory using the **Transcript** window, then run:

```tcl
do run.do
```

This single command performs all the following steps automatically:

| Step | Command in `run.do` | Description |
|------|---------------------|-------------|
| 1 | `vlib work` | Creates the simulation work library |
| 2 | `vlog ALU_pkg.sv interface.sv pack.sv` | Compiles TB infrastructure files |
| 3 | `vlog ALU.sv +cover=sbfec -coveropt 3` | Compiles DUT with full coverage instrumentation |
| 4 | `vlog Top.sv` | Compiles the simulation top module |
| 5 | `vsim -coverage work.top` | Starts simulation with coverage collection enabled |
| 6 | `do wave.do` | Loads and configures the waveform window |
| 7 | `run -all` | Runs the simulation until `$finish` |
| 8 | `coverage report -html ...` | Generates an HTML coverage report |
| 9 | `coverage report -output coverage_report.txt` | Generates a text coverage report |

---

### Option B — Manual Step-by-Step

If you prefer to run each step manually in the ModelSim transcript:

**Step 1: Create the work library**
```tcl
vlib work
```

**Step 2: Compile the package and interface**
```tcl
vlog ALU_pkg.sv interface.sv pack.sv -l sim.log
```

**Step 3: Compile the DUT with coverage**
```tcl
vlog ALU.sv +cover=sbfec -coveropt 3 -l sim.log
```

> `+cover=sbfec` enables: **s**tatement, **b**ranch, **f**SM, **e**xpression, **c**ondition coverage.

**Step 4: Compile the top module**
```tcl
vlog Top.sv -l sim.log
```

**Step 5: Load the simulation**
```tcl
vsim -coverage -voptargs=+acc work.top
```

**Step 6: Load the waveform configuration**
```tcl
do wave.do
```

**Step 7: Run the simulation**
```tcl
run -all
```

---

### Enable Debug Logging (Optional)

To enable verbose `$display` messages throughout all testbench components, compile with the `+define+DEBUG` flag:

```tcl
vlog ALU_pkg.sv interface.sv pack.sv +define+DEBUG -l sim.log
vlog ALU.sv +cover=sbfec -coveropt 3 +define+DEBUG -l sim.log
vlog Top.sv +define+DEBUG -l sim.log
```

---

## 6. Waveform Viewing

The `wave.do` script automatically sets up a color-coded, organized waveform view:

| Group | Signals | Color |
|-------|---------|-------|
| Clock / Reset | `clk`, `rst` | Cyan / Amber |
| ALU Inputs | `a`, `b`, `op_code` | Green / Blue / Purple |
| ALU Outputs | `result`, `z`, `n`, `c`, `v` | Pink / Orange / Brown / Teal / Indigo |
| DUT Instance | Full DUT hierarchy expanded | — |

All numeric signals (`a`, `b`, `result`) are displayed in **signed decimal** radix for readability.

**To zoom/navigate the waveform:**
- Use `Ctrl+Scroll` or the zoom toolbar to zoom in/out
- Press `F` to fit the full simulation time in the window
- Press `Ctrl+F` to search for a signal by name

---

## 7. Coverage Reports

After simulation, two coverage reports are automatically generated:

| Report | Location | Format |
|--------|----------|--------|
| HTML Report | `covhtmlreport/` | Interactive browser report |
| Text Report | `coverage_report.txt` | Plain-text, detailed |

To open the HTML report, open `covhtmlreport/index.html` in any browser.

**Coverage types instrumented on the DUT (`+cover=sbfec`):**
- **s — Statement:** every line of RTL code executed
- **b — Branch:** every conditional branch taken
- **f — FSM:** state machine transitions (if applicable)
- **e — Expression:** sub-expression evaluation
- **c — Condition:** individual conditions within expressions

---

## 8. Supported ALU Operations

Defined in `ALU_pkg.sv` as the `alu_opcode_t` enum:

| `op_code` | Mnemonic | Operation | Flags Updated |
|-----------|----------|-----------|---------------|
| `2'b00` | `ALU_ADD` | `result = A + B` | Z, N, C, V |
| `2'b01` | `ALU_SUB` | `result = A - B` | Z, N, C, V |
| `2'b10` | `ALU_AND` | `result = A & B` | Z, N |
| `2'b11` | `ALU_OR` | `result = A OR B` | Z, N |

**Flag Definitions:**
- **Z (Zero):** Set when `result == 0`
- **N (Negative):** Set when `result[3] == 1` (MSB is 1)
- **C (Carry):** Set on unsigned carry/borrow out of bit 3
- **V (Overflow):** Set on signed arithmetic overflow

---

*Author: Bassel Mahmoud | ADI Summer Internship 2026*

