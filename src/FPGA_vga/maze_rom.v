// One asynchronous row lookup per instance, initialized from the maze MIF.
module maze_rom(address, Q);
    input wire [4:0] address;
    output wire [39:0] Q;

    // Rows 0-29 are the maze; addresses 30-33 are head, mid, tail, and exit.
    (* ram_init_file = "maze2.mif" *) reg [39:0] memory [0:33];

    assign Q = memory[address];
endmodule