vlib work
vlog -sv spi_types_pkg.sv spi_slave.sv spi_memory.sv spi_tb.sv
vsim -voptargs="+acc" work.spi_tb
do wave.do
run -all
