module star_rom (
    input  wire [3:0] address,   // 0..15 for a 4x4 sprite
    output wire  [8:0] Q ); // 9-bit RGB (3:3:3) directly matching vga_adapter
    (* ram_init_file = "star.mif" *) reg [8:0] memory [0:15];
    assign Q = memory[address];
endmodule