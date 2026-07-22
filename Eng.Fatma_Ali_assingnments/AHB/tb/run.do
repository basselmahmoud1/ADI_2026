vlib work

# Compile source files (order matters for packages)
vlog -sv ../src/AHB_pkg.sv
vlog -sv ../src/AHB_master_lite.sv
vlog -sv ../src/AHB_interconnect.sv

# Compile testbench and mock slave
vlog -sv AHB_slave_mock.sv
vlog -sv tb_AHB.sv

# Load simulation without optimization (to see all signals)
vsim -voptargs=+acc work.tb_AHB

# Add waveforms
do wave.do

# Run the simulation
run -all
