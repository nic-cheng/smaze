module start_rom(clock, address, Q);
    input wire clock;
    input wire [4:0] address;
    output reg [39:0] Q;

    (* ram_init_file = "start.mif" *) reg [39:0] memory [0:29];

    always @(posedge clock)
        Q <= memory[address];
endmodule