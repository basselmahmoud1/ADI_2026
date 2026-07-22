# AMBA AHB-Lite Master, Interconnect & Mock Slave Implementation

This project implements a synthesizable **AMBA AHB-Lite** protocol architecture in SystemVerilog. It features a complete master controller, a multi-slave address-decoding interconnect, and a mock slave with configurable wait-states and error injection for robust verification.

---

## 📂 Project Structure

The project files are organized as follows:

* **`src/`** (Design Sources)
  * [`AHB_pkg.sv`](./src/AHB_pkg.sv): SystemVerilog package containing enum definitions for transfer types (`htrans`), burst modes (`hburst`), data size (`hsize`), and internal FSM states.
  * [`AHB_master_lite.sv`](./src/AHB_master_lite.sv): AHB-Lite Master Controller with support for single and burst operations, wait-state handling, and error response tracking.
  * [`AHB_interconnect.sv`](./src/AHB_interconnect.sv): Decoder and routing interconnect to multiplex signals between the master and multiple slave units.

* **`tb/`** (Verification / Testbench)
  * [`AHB_slave_mock.sv`](./tb/AHB_slave_mock.sv): Mock memory slave with parameters for base address, memory size, and control ports to simulate wait-states (`hreadyout`) and response errors (`hresp`).
  * [`tb_AHB.sv`](./tb/tb_AHB.sv): SystemVerilog testbench simulating various test scenarios (reads, writes, burst transfers, wait-states, and decode/response errors).
  * [`run.do`](./tb/run.do): ModelSim/QuestaSim automation script to compile files and launch simulation.
  * [`wave.do`](./tb/wave.do): Waveform window configuration for signal visualization.
* **Documentation**
  * `AHB_report.pdf`: Detailed design and verification report.
  * `IHI0033a.pdf`: ARM AMBA 3 AHB-Lite Protocol Specification (Reference Document).

---

## 🚀 Key Features

* **Bus Protocol**: AMBA AHB-Lite compliant.
* **Transfer Types**: Supports `IDLE`, `NONSEQ`, and `SEQ`.
* **Burst Modes**: Supports `SINGLE`, `INCR4`, `INCR8`, and `INCR16` burst lengths.
* **Interconnect**: Supports parameterized data/address widths, number of slaves (`SLAVE_NUM`), and slave memory footprint (`SLAVE_SIZE_KB`).
* **Robust Verification**: Testbench covers write/read back sequences, pipeline operations, slave busy states, and out-of-bounds address decoder errors.

---

## 🛠️ How to Run

Follow these steps to run the simulation using **ModelSim** or **QuestaSim**:

### 1. Launch ModelSim / QuestaSim

Open your ModelSim or QuestaSim GUI interface.

### 2. Set the Working Directory

In the ModelSim command console, navigate to the `tb` folder of this project:

```tcl
cd <path_to_project>/Eng.Fatma_Ali_assingnments/AHB/tb
```

*(Replace `<path_to_project>` with your local directory path, e.g., `d:/courses/Digital/ADI/ADI_Summer_intern_2026`)*

### 3. Run the Simulation Script

Execute the Tcl script:

```tcl
do run.do
```

### What `run.do` does

1. Creates the simulation workspace (`work` library).
2. Compiles design packages and source files in the correct order.
3. Compiles the mock slave and testbench.
4. Starts the simulator (`vsim`) with optimized visibility for all signals.
5. Loads the signal waveforms saved in `wave.do`.
6. Executes all testbench testcases using `run -all`.
