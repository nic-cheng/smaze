# Run "do snake/testbench.tcl" from the repository's ModelSim directory.
set modelsim_dir [pwd]
if {[file tail [file normalize $modelsim_dir]] ne "ModelSim"} {
    error "Run this script with the working directory set to smaze/ModelSim."
}
set repo_dir [file normalize [file join $modelsim_dir ..]]
set simulator_dir [file join $modelsim_dir snake]
set game_logic_dir [file join $repo_dir src game_logic]
if {![file isfile [file join $simulator_dir testbench.v]] || ![file isfile [file join $game_logic_dir snake.v]]} {
    error "Snake testbench or source not found. Run from smaze/ModelSim."
}

quit -sim
if {![file isdirectory work]} {
    vlib work
}

vlog -sv -work work [file join $game_logic_dir snake.v] \
    [file join $repo_dir src FPGA_vga maze_rom.v] \
    [file join $simulator_dir testbench.v]

vsim -t 1ns -voptargs=+acc -onfinish stop work.testbench

# ModelSim does not initialize memory from Quartus's ram_init_file attribute.
quietly set maze_file [open [file join $repo_dir maze2.mif] r]
quietly set maze_contents [read $maze_file]
close $maze_file
quietly set maze_words [regexp -all -inline -line {^\s*([0-9]+)\s*:\s*([01]{40});} $maze_contents]
if {[llength $maze_words] != 34 * 3} {
    error "Expected 34 words in maze2.mif"
}
foreach {match address bits} $maze_words {
    mem load -filltype value -fillradix binary -filldata $bits \
        -startaddress $address -endaddress $address sim:/testbench/dut/m/memory
}

if {![batch_mode]} {
    do [file join $simulator_dir wave.do]
}
run -all
if {[examine -radix unsigned sim:/testbench/passed] ne "1"} {
    error "Snake movement checks failed"
}
