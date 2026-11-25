module main (CLOCK_50, SW, KEY, LEDR, PS2_CLK, PS2_DAT, VGA_X, VGA_Y, VGA_COLOR, plot);
    input wire CLOCK_50;
    input wire [9:0] SW;
    input wire [3:0] KEY;

    output wire [9:0] LEDR;
    inout wire PS2_CLK;
    inout wire PS2_DAT;

    output wire [9:0] VGA_X;
    output wire [8:0] VGA_Y;
    output wire [23:0] VGA_COLOR;
    output wire plot;

    wire [1:0] start_dir, kb_dir, snake_dir;
    wire moving, spacebar;
 
    vga_adapter VGA (
        .resetn     (KEY[0]),
        .clock      (CLOCK_50),
        .color      ()
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

endmodule
