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
    wire game_clk = tick & game;

    wire [32:0] start_pos;
    wire [10:0] end_pos;
    wire [32:0] pos_list;

    maze_metadata_rom metadata (
        .start_pos (start_pos),
        .end_pos   (end_pos)
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
        .game_clk   (game_clk),
        .resetn     (KEY[0]),
        .enable     (moving),
        .start_pos  (start_pos),
        .start_dir  (start_dir),
        .kb_dir     (kb_dir),
        .pos_list   (pos_list),
        .snake_dir  (snake_dir)
    );

    vga_display vga(
        .CLOCK_50       (CLOCK_50),
        .KEY            (KEY),
        .pos_list       (pos_list),
        .spacebar       (spacebar),
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
