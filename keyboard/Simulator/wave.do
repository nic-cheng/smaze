add wave -divider Stimulus
add wave sim:/testbench/CLOCK_50 sim:/testbench/KEY sim:/testbench/key_action
add wave -radix hexadecimal sim:/testbench/scan_code

add wave -divider {PS/2 bus}
add wave sim:/testbench/ps2_clk sim:/testbench/ps2_dat
add wave -radix unsigned sim:/testbench/keyboard/FIFO_depth

add wave -divider {Keyboard controller and LEDs}
add wave sim:/testbench/received_data_en
add wave -radix hexadecimal sim:/testbench/received_data
add wave sim:/testbench/dut/U1/kbi/break_code_received
add wave sim:/testbench/dut/U1/moving
add wave -radix unsigned sim:/testbench/dut/U1/direction
add wave -radix binary sim:/testbench/LEDR
