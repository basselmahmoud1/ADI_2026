# FPGA Assignments & Designs

This repository contains the FPGA design projects implemented using **Xilinx Vivado** targeting the **ZedBoard Zynq Evaluation and Development Kit** (XC7Z020-CLG484).

---

## 📂 Project Structure

* **[`Assignment_1/`](./Assignment_1)**: 3-Bit Counter with PLL Clock Divider
  * [`top.v`](./Assignment_1/project_1/project_1.srcs/sources_1/new/top.v): Top-level wrapper module that connects the PLL, clock divider, and counter modules.
  * [`clk_div.v`](./Assignment_1/project_1/project_1.srcs/sources_1/new/clk_div.v): Clock divider module dividing the 8 MHz clock from the PLL to a 1 Hz clock.
  * [`counter.v`](./Assignment_1/project_1/project_1.srcs/sources_1/new/counter.v): 3-bit synchronous binary counter driven by the divided 1 Hz clock.
  * [`const.xdc`](./Assignment_1/project_1/project_1.srcs/constrs_1/new/const.xdc): Pin constraints mapping reset to switch `SW0`, system clock to `GCLK` (100 MHz oscillator), and the 3-bit counter to onboard LEDs `LD0`, `LD1`, and `LD2`.
* **[`Assignment_2/`](./Assignment_2)**: 2-Input AND Gate
  * [`and_gate.v`](./Assignment_2/and_gate.v): Simple Verilog module for a 2-input AND gate.
  * [`const.xdc`](./Assignment_2/const.xdc): Pin constraints mapping the inputs to slide switches `SW0` & `SW1`, and output to OLED DC pin (`U10`).
* **[`report.pdf`](./report.pdf)**: Detailed assignment documentation containing compilation, synthesis, implementation reports, and hardware verification screenshots.

---

## 🛠️ How to Open and Run in Vivado

### 1. Launch Xilinx Vivado

Open Vivado on your host machine.

### 2. Open the Project

* For **Assignment 1**: Go to *File ➔ Open Project* and select the project file:
    `./Assignment_1/project_1/project_1.xpr`
* For **Assignment 2**: Go to *File ➔ Open Project* and select the project file:
    `./Assignment_2/project_2/project_2.xpr`
