module star_rom (
    input  wire       clock,
    input  wire [3:0] address,   // 0..15 for a 4x4 sprite
    output reg  [8:0] Q ); // 9-bit RGB (3:3:3) directly matching vga_adapter
    (* ram_init_file = "star.mif" *) reg [8:0] memory [0:15];

    always @(posedge clock) begin
        Q <= memory[address];
    end
endmodule