onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {Clock / Reset}
add wave -noupdate -color #00B7C3 /top/clk
add wave -noupdate -color #FFB000 /top/aluif/rst

add wave -noupdate -divider {ALU Inputs}
add wave -noupdate -color #4CAF50 -radix signed /top/aluif/a
add wave -noupdate -color #2196F3 -radix signed /top/aluif/b
add wave -noupdate -color #9C27B0 /top/aluif/op_code

add wave -noupdate -divider {ALU Outputs}
add wave -noupdate -color #E91E63 -radix signed /top/aluif/result
add wave -noupdate -color #FF5722 /top/aluif/z
add wave -noupdate -color #795548 /top/aluif/n
add wave -noupdate -color #607D8B /top/aluif/c
add wave -noupdate -color #3F51B5 /top/aluif/v

add wave -noupdate -divider {DUT Instance}
add wave -noupdate -expand /top/dut

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 180
configure wave -valuecolwidth 120
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
WaveRestoreZoom {0 ns} {200 ns}
