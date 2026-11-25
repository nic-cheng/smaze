# Run "do keyboard/testbench.tcl" from the repository's ModelSim directory.
set modelsim_dir [pwd]
if {[file tail [file normalize $modelsim_dir]] ne "ModelSim"} {
    error "Run this script with the working directory set to smaze/ModelSim."
}
set repo_dir [file normalize [file join $modelsim_dir ..]]
set simulator_dir [file join $modelsim_dir keyboard]
set keyboard_dir [file join $repo_dir src keyboard]
if {![file isfile [file join $simulator_dir testbench.v]] || ![file isfile [file join $keyboard_dir top.v]]} {
    error "Keyboard testbench or sources not found. Run from smaze/ModelSim."
}

quit -sim
if {![file isdirectory work]} {
    vlib work
}

vlog -work work [file join $keyboard_dir PS2_Controller Altera_UP_PS2_Data_In.v] \
    [file join $keyboard_dir PS2_Controller Altera_UP_PS2_Command_Out.v] \
    [file join $keyboard_dir PS2_Controller PS2_Controller.v] \
    [file join $keyboard_dir kb_interface.v] \
    [file join $keyboard_dir kb_demo.v] \
    [file join $keyboard_dir top.v]
vlog -sv -work work [file join $simulator_dir testbench.v]

vsim -t 1ns -voptargs=+acc -onfinish stop work.testbench
if {![batch_mode]} {
    do [file join $simulator_dir wave.do]
}
run -all
if {[examine -radix unsigned sim:/testbench/passed] ne "1"} {
    error "PS/2 keyboard movement checks failed"
}
