# stop any simulation that is currently running
quit -sim

# copy any files in the MIF folder
if {[file exists MIF]} {
	file delete -force MIF
    file copy ../MIF .
} else {
    file copy ../MIF .
}

# create the default "work" library
vlib work;

# compile the Verilog source code in the parent folder
vlog -nolock ../milestone_1.v ../vga_adapter/*.v
# compile the Verilog code of the testbench
vlog -nolock *.v
# start the Simulator, including some libraries that may be needed
vsim work.testbench -Lf 220model -Lf altera_mf_ver -Lf verilog
# show waveforms specified in wave.do
do wave.do

#ADDED
# show waveforms specified in wave.do
do wave.do
# clear the old box signals, then add the maze signals
delete wave *
add wave -label CLOCK_50 /testbench/CLOCK_50
add wave -label KEY /testbench/KEY
add wave -label VGA_SYNC /testbench/U1/VGA_SYNC
add wave -label x -radix unsigned /testbench/U1/m1/x
add wave -label y -radix unsigned /testbench/U1/m1/y
add wave -label write /testbench/U1/m1/write
add wave -label done /testbench/U1/m1/done
add wave -label colour /testbench/U1/m1/colour
# The testbench calls $stop at 3.3 ms
run -all

# advance the simulation the desired amount of time
# run 800 ns
