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
TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 120
configure wave -valuecolwidth 80
configure wave -justifyvalue left
update
