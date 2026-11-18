# stop any simulation that is currently running
quit -sim

# create the default work library
vlib work

# compile the keyboard controller, demo, emulator, and testbench
vlog ../PS2_Controller/Altera_UP_PS2_Command_Out.v
vlog ../PS2_Controller/Altera_UP_PS2_Data_In.v
vlog ../PS2_Controller/PS2_Controller.v
vlog ../kb_interface.v
vlog ../kb_demo.v
vlog ../tb/PS2_keyboard.v
vlog -sv testbench.v

# start the simulation and show the test signals
vsim -voptargs=+acc work.testbench
do wave.do
run -all
