add wave -divider {Testbench}
add wave sim:/testbench/clock sim:/testbench/resetn sim:/testbench/move_enable sim:/testbench/enable
add wave -radix unsigned sim:/testbench/start_dir sim:/testbench/kb_dir sim:/testbench/snake_dir
add wave -radix hexadecimal sim:/testbench/start_pos sim:/testbench/pos_list
add wave sim:/testbench/passed
add wave -divider {DUT movement logic}
add wave -radix unsigned sim:/testbench/dut/next_pos
add wave sim:/testbench/dut/can_move
