onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLOCK_50 /testbench/CLOCK_50
add wave -noupdate -label KEY /testbench/KEY
add wave -noupdate -label LEDR -radix binary /testbench/LEDR
add wave -noupdate -label key_action /testbench/key_action
add wave -noupdate -label scan_code -radix hexadecimal /testbench/scan_code
add wave -noupdate -label PS2_CLK /testbench/PS2_CLK
add wave -noupdate -label PS2_DAT /testbench/PS2_DAT
add wave -noupdate -label direction -radix binary /testbench/DUT/direction
add wave -noupdate -label received_data -radix hexadecimal /testbench/DUT/kbi/received_data
add wave -noupdate -label received_data_en /testbench/DUT/kbi/received_data_en
add wave -noupdate -divider PS2_keyboard_transmitter
add wave -noupdate -label keyboard_state -radix hexadecimal /testbench/Keyboard/y_Q
add wave -noupdate -label keyboard_fifo_depth -radix hexadecimal /testbench/Keyboard/FIFO_depth
add wave -noupdate -label start_sending /testbench/Keyboard/start_sending
add wave -noupdate -label data_ready /testbench/Keyboard/data_out/data_ready
add wave -noupdate -label clk_ready /testbench/Keyboard/data_out/clk_ready
add wave -noupdate -label tx_counter -radix hexadecimal /testbench/Keyboard/data_out/counter
add wave -noupdate -label tx_clk_div -radix binary /testbench/Keyboard/data_out/clk_div
add wave -noupdate -divider PS2_controller_receiver
add wave -noupdate -label rx_state -radix hexadecimal /testbench/DUT/kbi/kb/s_ps2_transceiver
add wave -noupdate -label data_in_state -radix hexadecimal /testbench/DUT/kbi/kb/PS2_Data_In/s_ps2_receiver
add wave -noupdate -label rx_data_count -radix hexadecimal /testbench/DUT/kbi/kb/PS2_Data_In/data_count
add wave -noupdate -label rx_shift_reg -radix hexadecimal /testbench/DUT/kbi/kb/PS2_Data_In/data_shift_reg
add wave -noupdate -label ps2_clk_posedge /testbench/DUT/kbi/kb/ps2_clk_posedge
TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 120
configure wave -valuecolwidth 80
configure wave -justifyvalue left
update
