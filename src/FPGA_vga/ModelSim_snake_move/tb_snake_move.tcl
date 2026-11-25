quit -sim
vlib work;

vlog -nolock ../vga_display.v
vlog -nolock tb_snake_move.v
vsim work.tb_snake_move

add wave -label clock /tb_snake_move/clock
add wave -label resetn /tb_snake_move/resetn
add wave -label tick /tb_snake_move/tick
add wave -label direction /tb_snake_move/direction
add wave -label head -radix unsigned /tb_snake_move/U1/head
add wave -label mid -radix unsigned /tb_snake_move/U1/mid
add wave -label tail -radix unsigned /tb_snake_move/U1/tail

run -all