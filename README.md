# Digital-Clock-Design.
Designed and implemented a digital clock (HH:MM:SS) using Verilog HDL with modular and hierarchical design. The system uses cascaded counters to generate seconds, minutes, and hours, along with a multiplexed 7-segment display interface for visualization.
# Features
- 24-hour format
- Mod-10, Mod-6, Mod-24 counters
- Carry propagation between stages
- Asynchronous reset
- Multiplexed 7-segment display

# Files
- digital_clock.v → Main design
- testbench.v → Simulation

# Simulation
Verified using waveform analysis showing correct time progression.
