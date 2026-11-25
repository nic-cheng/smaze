add wave -divider {Testbench}
add wave sim:/testbench/game_clk
add wave sim:/testbench/resetn
add wave sim:/testbench/enable
add wave -radix unsigned sim:/testbench/direction
add wave sim:/testbench/maze
add wave -radix hexadecimal sim:/testbench/start_pos
add wave -radix hexadecimal sim:/testbench/pos_list
add wave sim:/testbench/passed
add wave -divider {DUT movement logic}
add wave -radix unsigned sim:/testbench/dut/next_pos
add wave sim:/testbench/dut/can_move
