quit -sim
vlib work;

vlog -nolock ../vga_display.v
vlog -nolock tb_maze.v
vsim work.tb_maze

add wave -label clock /tb_maze/clock
add wave -label resetn /tb_maze/resetn
add wave -label x -radix unsigned /tb_maze/x
add wave -label y -radix unsigned /tb_maze/y
add wave -label x_ -radix unsigned /tb_maze/U1/x_
add wave -label y_ -radix unsigned /tb_maze/U1/y_
add wave -label write /tb_maze/write
add wave -label color /tb_maze/color
add wave -label snake /tb_maze/snake

# the testbench calls $stop after 1.7 ms
run -all