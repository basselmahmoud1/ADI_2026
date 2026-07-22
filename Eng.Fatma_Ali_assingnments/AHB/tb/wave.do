onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {System Clocks & Reset}
add wave -noupdate /tb_AHB/hclk
add wave -noupdate /tb_AHB/hresetn

add wave -noupdate -divider {Master Lite Interface}
add wave -noupdate /tb_AHB/u_master/valid
add wave -noupdate /tb_AHB/u_master/write
add wave -noupdate -radix hexadecimal /tb_AHB/u_master/addr_in
add wave -noupdate -radix hexadecimal /tb_AHB/u_master/w_data
add wave -noupdate /tb_AHB/u_master/burst
add wave -noupdate /tb_AHB/u_master/size
add wave -noupdate /tb_AHB/u_master/ready
add wave -noupdate -radix hexadecimal /tb_AHB/u_master/r_data
add wave -noupdate /tb_AHB/u_master/cs

add wave -noupdate -divider {AHB Bus Signals}
add wave -noupdate /tb_AHB/htrans
add wave -noupdate -radix hexadecimal /tb_AHB/haddr
add wave -noupdate /tb_AHB/hwrite
add wave -noupdate -radix hexadecimal /tb_AHB/hwdata
add wave -noupdate /tb_AHB/hsize
add wave -noupdate /tb_AHB/hburst
add wave -noupdate -radix hexadecimal /tb_AHB/hrdata
add wave -noupdate /tb_AHB/hready
add wave -noupdate /tb_AHB/hresp

add wave -noupdate -divider {Interconnect <-> Slaves}
add wave -noupdate -radix binary /tb_AHB/hsel
add wave -noupdate -radix hexadecimal /tb_AHB/hrdata_s
add wave -noupdate -radix binary /tb_AHB/hreadyout_s
add wave -noupdate -radix binary /tb_AHB/hresp_s

add wave -noupdate -divider {Mock Slaves TB Controls}
add wave -noupdate -radix binary /tb_AHB/hreadyout_ctrl
add wave -noupdate -radix binary /tb_AHB/hresp_ctrl

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 250
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
WaveRestoreZoom {0 ps} {200 ns}
