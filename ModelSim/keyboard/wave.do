add wave -divider Stimulus
add wave sim:/testbench/CLOCK_50 sim:/testbench/resetn sim:/testbench/key_action
add wave -radix hexadecimal sim:/testbench/scan_code
add wave -radix unsigned sim:/testbench/snake_dir
add wave -divider {PS/2 bus}
add wave sim:/testbench/ps2_clk sim:/testbench/ps2_dat
add wave -radix unsigned sim:/testbench/keyboard/FIFO_depth
add wave -divider {Keyboard interface}
add wave sim:/testbench/received_data_en
add wave -radix hexadecimal sim:/testbench/received_data
add wave sim:/testbench/dut/break_code_received
add wave sim:/testbench/moving sim:/testbench/spacebar
add wave -radix unsigned sim:/testbench/kb_dir
add wave sim:/testbench/passed
