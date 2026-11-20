# Run "do testbench.tcl" from keyboard/Simulator or
# "do keyboard/Simulator/testbench.tcl" from the project root.
# ModelSim's "do" does not set Tcl's script filename like "source" does.
set script_path [info script]
if {[file tail $script_path] eq "testbench.tcl"} {
    set simulator_dir [file dirname [file normalize $script_path]]
} elseif {[file isfile [file join [pwd] .. tb PS2_keyboard.v]]} {
    set simulator_dir [pwd]
} else {
    set simulator_dir [file join [pwd] keyboard Simulator]
}
set keyboard_dir [file dirname $simulator_dir]
if {![file isfile [file join $keyboard_dir tb PS2_keyboard.v]]} {
    error "Keyboard sources not found. Run from keyboard/Simulator or the project root."
}

quit -sim
if {![file isdirectory work]} {
    vlib work
}

vlog -work work [file join $keyboard_dir tb PS2_keyboard.v] \
    [file join $keyboard_dir PS2_Controller Altera_UP_PS2_Data_In.v] \
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
