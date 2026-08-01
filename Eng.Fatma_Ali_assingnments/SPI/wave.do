onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider "System Signals"
add wave -noupdate /spi_tb/tb_clk
add wave -noupdate /spi_tb/rst_n
add wave -noupdate -divider "SPI Bus"
add wave -noupdate /spi_tb/csb
add wave -noupdate /spi_tb/sclk
add wave -noupdate /spi_tb/sdi
add wave -noupdate /spi_tb/sdo
add wave -noupdate -divider "Memory Interface"
add wave -noupdate -radix hex /spi_tb/addr
add wave -noupdate /spi_tb/wr_en
add wave -noupdate -radix hex /spi_tb/wr_data
add wave -noupdate -radix hex /spi_tb/rd_data
add wave -noupdate -divider "Slave Internal"
add wave -noupdate /spi_tb/u_slave/header
add wave -noupdate -radix unsigned /spi_tb/u_slave/counter
add wave -noupdate -radix hex /spi_tb/u_slave/rd_data_shift_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
