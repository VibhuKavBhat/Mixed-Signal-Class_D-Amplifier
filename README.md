# Mixed-Signal Class-D Audio Amplifier

**Envision Project Expo 2026 — D04**

A mixed-signal Class-D audio amplifier combining an FPGA-based digital control stage with a MOSFET analog power stage. A 1kHz, 1V sine wave is sampled at 50kHz, stored as 8-bit values in FPGA BRAM, and compared against a 195kHz sawtooth waveform in Verilog to generate a PWM signal. This PWM drives an NMOS half-bridge power stage (via an IR2110 gate driver) that switches a 12V supply to produce an amplified PWM signal. A 2nd-order LC low-pass filter reconstructs the original sine wave before delivery to an 8Ω speaker.

The complete system was designed, simulated, and verified using Vivado (digital) and LTSpice (analog).

## Overview

Class-D amplifiers achieve high efficiency by rapidly switching transistors ON/OFF rather than operating them in a linear region, then using filtering to reconstruct a clean analog waveform from the switching pattern. This project builds one from scratch: an FPGA generates a high-speed PWM signal representing an audio waveform, a MOSFET half-bridge amplifies that PWM to full power, and an LC filter recovers smooth analog audio.

## System Architecture

The design is split into two subsystems, integrated in the final stage:

- **Digital block (FPGA):** PWM generation from a stored waveform
- **Analog block:** MOSFET power stage and output filtering

### Digital Block — PWM Generation

- A 1kHz sine wave is sampled at 50kHz and stored as 256 8-bit values in FPGA BRAM (`sine_rom`)
- A 195kHz sawtooth counter is compared against the sine LUT values each clock cycle to generate the raw PWM signal
- Two complementary outputs with 120ns dead-time are derived via a 20-cycle shift register and mapped to Pmod pins on the Nexys4 DDR board, ensuring the high-side and low-side MOSFETs are never ON simultaneously

**Digital implementation consists of four modules:**
1. **Sine LUT (`sine_rom`)** — 256-entry lookup table storing one sine cycle as 8-bit values
2. **Audio Sampling Counter** — divides the 100MHz onboard clock down to 50kHz to set the LUT read rate
3. **Sawtooth Generator** — 8-bit counter incrementing every 2 clock cycles, producing the 195kHz PWM carrier
4. **Comparator & Dead-Time** — compares sine vs. sawtooth each cycle to generate `pwm_raw`, then derives dead-time-protected complementary outputs

### Analog Block — Power Stage & Filter

- **NMOS half-bridge (M1, M2 — IRF540N):** switches a 12V supply according to the incoming PWM to produce an amplified 0–12V PWM signal. Two NMOS devices (rather than a PMOS high-side / NMOS low-side pair) were chosen for lower on-resistance and more symmetrical switching at high frequency.
- **IR2110 gate driver:** interfaces the 3.3V FPGA logic to the MOSFET gates, providing high-current drive for both switches. Handles the high-side "bootstrap problem" — since M1's source floats at the switching node, its gate must be driven above the 12V rail. A bootstrap capacitor (C8) and diode (D1) charge during the low-side ON phase and supply the above-rail voltage needed to turn M1 on.
- **2nd-order LC low-pass filter (L = 44.4 µH, C = 470 µF):** recovers the original sine wave from the amplified PWM, rolling off at 40dB/decade — a steeper, cleaner transition than a single-pole RC filter would provide. Yields a cutoff frequency of approximately **1.1 kHz**, sitting just above the target audio band and well below the 195kHz switching carrier, so the recovered sine wave passes cleanly while switching-frequency components are filtered out.
- **DC-blocking capacitor:** removes the ~6V DC offset before the signal reaches the 8Ω speaker.

## Hardware

- **Nexys4 DDR (Xilinx Artix-7)** — digital control, 100MHz onboard clock, BRAM-based waveform storage
- **IRF540N** — N-channel power MOSFETs (half-bridge)
- **IR2110** — high/low-side gate driver IC
- **1N4148 diodes** — bootstrap charging path (D1) and gate-line transient protection (D2, D3)
- **Passive components** — bootstrap capacitor (C8), decoupling capacitors (C6, C7), LC output filter (L, C)

## Verification & Testing

- **Digital block:** verified via Verilog testbench; PWM generation confirmed on hardware via oscilloscope
- **Analog block:** simulated in LTSpice — switching behavior, bootstrap charging, and LC filter recovery all confirmed in simulation

> **Note:** Due to component availability constraints, the analog power stage was not physically assembled on hardware and remains simulation-verified only. LTSpice simulation results closely model expected real-world behavior, and the design is considered ready for physical implementation.

## Limitations

- Analog power stage is simulation-only — not yet validated on physical hardware
- LTSpice simulation uses ideal behavioral sources to model the FPGA PWM output, which may not fully capture real-world signal integrity effects
- LC filter cutoff sits close to the target audio band, which could cause mild attenuation in a hardware implementation

## Future Work

- Assemble and test the analog stage on hardware to validate simulation results
- Extend the digital block to accept real audio input instead of a fixed sine wave
- Optimize LC filter values for wider audio bandwidth
- Explore a full H-bridge configuration for higher output power and true differential drive

## Team

Vibhu, Ekansh, Rahi, Vibha
