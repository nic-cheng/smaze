module main (CLOCK_50, SW, KEY, LEDR, PS2_CLK, PS2_DAT, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
    input wire CLOCK_50;
    input wire [9:0] SW;
    input wire [3:0] KEY;

    output wire [9:0] LEDR;
    assign LEDR = 10'b0;
    inout wire PS2_CLK;
    inout wire PS2_DAT;

    wire [1:0] kb_dir, snake_dir;
    wire [1:0] start_dir = 2'd3;
    wire moving, spacebar;

    output wire [7:0] VGA_R, VGA_G, VGA_B;
    output wire VGA_HS;
    output wire VGA_VS;
    output wire VGA_BLANK_N;
    output wire VGA_SYNC_N;
    output wire VGA_CLK;

    wire game, tick;
    clock_counter cc (CLOCK_50, KEY[0], tick);
    wire snake_enable = tick & game;

    wire [32:0] start_pos;
    wire [10:0] end_pos;
    wire [32:0] pos_list;
    wire [4:0] snake_maze_address, vga_maze_address;
    wire [39:0] snake_maze_row, vga_maze_row;

    maze_rom maze (
        .vga_address    (vga_maze_address),
        .snake_address  (snake_maze_address),
        .vga_row        (vga_maze_row),
        .snake_row      (snake_maze_row),
        .start_pos      (start_pos),
        .end_pos        (end_pos)
    );

    kb_interface kbi (
        .CLOCK_50   (CLOCK_50),
        .resetn     (KEY[0]),
        .PS2_CLK    (PS2_CLK),
        .PS2_DAT    (PS2_DAT),
        .snake_dir  (snake_dir),
        .moving     (moving),
        .kb_dir     (kb_dir),
        .spacebar   (spacebar)
    );

    snake s (
        .clock      (CLOCK_50),
        .resetn     (KEY[0]),
        .move_enable(snake_enable),
        .enable     (moving),
        .start_pos  (start_pos),
        .start_dir  (start_dir),
        .kb_dir     (kb_dir),
        .maze_row   (snake_maze_row),
        .maze_address(snake_maze_address),
        .pos_list   (pos_list),
        .snake_dir  (snake_dir)
    );

    vga_display vga(
        .CLOCK_50       (CLOCK_50),
        .KEY            (KEY),
        .pos_list       (pos_list),
        .spacebar       (spacebar),
        .maze_row_data  (vga_maze_row),
        .maze_address   (vga_maze_address),
        .VGA_R          (VGA_R),
        .VGA_G          (VGA_G),
        .VGA_B          (VGA_B),
        .VGA_HS         (VGA_HS),
        .VGA_VS         (VGA_VS),
        .VGA_BLANK_N    (VGA_BLANK_N),
        .VGA_SYNC_N     (VGA_SYNC_N),
        .VGA_CLK        (VGA_CLK),
        .game           (game)
    );

endmodule
