# Synthesizable Parameterizable Smart Home Automation Controller on FPGA Fabric

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Language: Verilog-HDL](https://img.shields.io/badge/Language-Verilog--HDL-blue.svg)]()
[![Platform: Vivado_Ready](https://img.shields.io/badge/Platform-Vivado--Ready-orange.svg)]()

A high-reliability, zero-jitter, multi-mode home automation and environmental asset control core engineered in synthesizable Verilog-HDL. The architecture employs hardware-level determinism to handle real-time sensor fusion, multi-rate structural timing blocks, and dynamic PWM actuation matrices while guaranteeing immediate, single-cycle safety interlock isolation during critical system faults.

---

## 📌 Problem Statement & Architectural Motivation
Traditional home automation architectures that rely on high-level software stacks (e.g., microcontrollers executing RTOS loops, embedded Linux single-board computers) suffer from non-deterministic latency spikes, scheduler jitter, and software execution freezes. During blocking I/O calls (such as waiting for cloud or network handshakes), critical local operations like safety-trip isolation or intrusion tracking can stall.

**This Project Solves These Vulnerabilities By:**
1. **True Hardware Parallelism:** Executing multi-channel 8-bit Pulse Width Modulators (PWM), debouncers, and system finite state machines simultaneously on dedicated, independent logic matrices.
2. **Deterministic Response Timing:** Guaranteeing a fixed nanosecond-level input-to-output propagation path across critical execution lines.
3. **Synchronous Resilience:** Eradicating Clock Domain Crossing (CDC) metastability concerns via localized multi-rate timing strobe generators instead of derived clock dividers.

---

## 🛠️ VLSI & Digital Design Concepts Applied
This controller incorporates foundational digital VLSI engineering design criteria:
- **Synchronous Design Paradigm:** Implements single-clock domain boundaries driven by synchronous pulse strobes (`clk_en.v`) to maintain uniform timing parameters across slow operations.
- **Input Conditioning Matrix:** Integrates explicit double-stage Flip-Flop metastability synchronizers with counter-based physical noise/switch debounce processors (`debounce.v`).
- **Hazard-Free RTL Formulation:** Avoids inferred latches by completely covering case statements and using proactive combinational defaults.
- **Priority Logic Encoding:** Implements an asynchronous fault monitoring hierarchy where critical thermal or electrical exceptions instantly override user inputs or automatic modes.

---

## 🗺️ Functional System Architecture

+---------------------------------------+
                              |            SYSTEM MASTER CLOCK        |
                              +---------------------------------------+
                                                  |
                                                  v
+-----------------------+               +-----------------------+
|  Asynchronous Sensors  |               |  System Tick Dividers |
| (PIR, LDR, Temp, OC)  |               |       (clk_en.v)      |
+-----------------------+               +-----------------------+
|                                       |
v                                       v (10Hz / 1kHz)
+-----------------------+                           |
| Input Synchronization |                           |
|    & Debounce Core    | <-------------------------+
|     (debounce.v)      |                           |
+-----------------------+                           |
|                                       |
v (Stable Signals)                      |
+---------------------------------------+           |
|   Central System FSM Control Core    |           |
|             (ctrl_fsm.v)              |           |
+---------------------------------------+           |
|                                       |
v (Target Duty Registers)               |
+---------------------------------------+           |
|     8-Bit Actuator Modulators         | <---------+
|              (pwm8.v)                 |
+---------------------------------------+
|
v
+---------------------------------------+
| Physical Load Drivers & Alarms        |
|  (PWM Dimming, Relays, Alarm LED)     |
+---------------------------------------+


---
text```
## 🗂️ Project Directory Structure

Smart-Home-FPGA-Controller/
│
├── rtl/                        # Synthesizable Register Transfer Level Sources
│   ├── clk_en.v                # Synchronous multi-rate clock enable generator
│   ├── debounce.v              # Double-flop synchronizer and input debounce filter
│   ├── pwm8.v                  # 8-Bit high-precision load modulator
│   ├── scenes.v                # Hardcoded hardware environment preset lookup ROM
│   ├── ctrl_fsm.v              # Centralized Finite State Machine and priority encoder
│   └── top.v                   # Core structural top-level design wrapper
│
├── tb/                         # Verification Environment Metrics
│   └── home_tb.v               # Functional testbench simulation verification harness
│
├── constraints/                # Target Board Layout Assignments
│   └── physical_pins.xdc       # Xilinx Artix-7 target constraints configuration file
│
└── README.md                   # System design narrative and layout logs

```
---


## 📊 Verification & Waveform Analysis

The design can be instantly verified in a **zero-install, 100% cloud-hosted virtual environment** via EDA Playground. 

### Simulation Checklist & Milestones
When reviewing generated `.vcd` trace files using wave viewers (e.g., EPWave, GTKWave), check the following behavioral points:
1. **Manual Configuration Accuracy:** Verify that the `out_pwm_light_o` line matches changing `manual_light_val_i` metrics during the manual execution cycle.
2. **Autonomous Logic Shifting:** Confirm that transitioning `sw_auto_mode_i` high while setting sensory inputs (`sns_pir_motion_raw_i` and `sns_ldr_dark_raw_i`) drives the PWM channel directly to the preset automated load configuration.
3. **Critical Fault Interlock Assertion:** Verify that setting `flt_overcurrent_raw_i` to high instantly triggers `out_system_alarm_o` to a logical `1` on the following clock cycle, while dropping all operational relay paths (`out_relays_o`) directly to zero.

---

## 🏗️ FPGA Synthesis & Resource Utilization (Xilinx Vivado)
This codebase is completely hardware-synthesizable and maps efficiently to standard FPGA fabrics (e.g., Xilinx Artix-7, Intel Cyclone). 

### Target Metrics (Artix-7 XC7A35TCSG324-1 Baseline)
- **Clock Target:** 50 MHz (20ns Period)
- **Inferred Latches:** 0 (Completely Hazard-Free Synchronous Synthesis)
- **Estimated Logic Resources Consumed:** ~68 LUTs, ~42 Flip-Flops.

---

## ⚡ Quick-Start Verification (Command-Line Interface)
To run the verification workspace locally using an open-source Icarus Verilog toolchain, run the following commands in your terminal setup:

```bash
# 1. Compile all design files and testbench harness
iverilog -o home_sim.out rtl/clk_en.v rtl/debounce.v rtl/pwm8.v rtl/scenes.v rtl/ctrl_fsm.v rtl/top.v tb/home_tb.v

# 2. Run the simulation package to output system logs and a VCD trace file
vvp home_sim.out

# 3. Analyze the wave outputs visually
gtkwave dump.vcd
```
---