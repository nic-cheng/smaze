onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLOCK_50 -radix binary /testbench/CLOCK_50
add wave -noupdate -label KEY -radix binary /testbench/KEY
add wave -noupdate -label SW -radix binary /testbench/SW
add wave -noupdate -label VGA_X -radix hexadecimal /testbench/VGA_X
add wave -noupdate -label VGA_Y -radix hexadecimal /testbench/VGA_Y
add wave -noupdate -label VGA_COLOR -radix hexadecimal /testbench/VGA_COLOR
add wave -noupdate -label plot -radix binary /testbench/plot
add wave -noupdate -divider vga_demo
add wave -noupdate -label VGA_X -radix hexadecimal /testbench/U1/VGA_X
add wave -noupdate -label VGA_Y -radix hexadecimal /testbench/U1/VGA_Y
add wave -noupdate -label VGA_COLOR -radix hexadecimal /testbench/U1/VGA_COLOR
add wave -noupdate -label plot -radix binary /testbench/U1/plot
add wave -noupdate -label color -radix binary /testbench/U1/color
add wave -noupdate -divider vga_adapter
add wave -noupdate -label VGA_X -radix hexadecimal /testbench/U1/VGA/VGA_X
add wave -noupdate -label VGA_Y -radix hexadecimal /testbench/U1/VGA/VGA_Y
add wave -noupdate -label VGA_COLOR -radix hexadecimal /testbench/U1/VGA/VGA_COLOR
add wave -noupdate -label write -radix binary /testbench/U1/VGA/write
add wave -noupdate -label plot -radix binary /testbench/U1/VGA/plot
add wave -noupdate -label color -radix binary /testbench/U1/VGA/color
add wave -noupdate -label x -radix hexadecimal /testbench/U1/VGA/x
add wave -noupdate -label y -radix hexadecimal /testbench/U1/VGA/y
add wave -noupdate -label to_ctrl_color -radix hexadecimal /testbench/U1/VGA/to_ctrl_color
add wave -noupdate -label controller_to_video_memory_addr -radix hexadecimal /testbench/U1/VGA/controller_to_video_memory_addr
add wave -noupdate -divider controller
add wave -noupdate -label vga_clock -radix binary /testbench/U1/VGA/controller/vga_clock
add wave -noupdate -label resetn -radix binary /testbench/U1/VGA/controller/resetn
add wave -noupdate -label VGA_X -radix hexadecimal /testbench/U1/VGA/controller/VGA_X
add wave -noupdate -label VGA_Y -radix hexadecimal /testbench/U1/VGA/controller/VGA_Y
add wave -noupdate -label VGA_COLOR -radix hexadecimal /testbench/U1/VGA/controller/VGA_COLOR
add wave -noupdate -label plot -radix binary /testbench/U1/VGA/controller/plot
add wave -noupdate -label xCounter -radix hexadecimal /testbench/U1/VGA/controller/xCounter
add wave -noupdate -label yCounter -radix hexadecimal /testbench/U1/VGA/controller/yCounter
add wave -noupdate -label memory_address -radix hexadecimal /testbench/U1/VGA/controller/memory_address
add wave -noupdate -label pixel_color -radix hexadecimal /testbench/U1/VGA/controller/pixel_color
add wave -noupdate -label plot -radix binary /testbench/U1/VGA/controller/plot
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 80
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {120 ns}
