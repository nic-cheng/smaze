`timescale 1ns / 1ns
`default_nettype none

module testbench;
    localparam [1:0] D_UP = 2'd0, D_LEFT = 2'd1,
                     D_DOWN = 2'd2, D_RIGHT = 2'd3;
    localparam [10:0] INITIAL_HEAD = {6'd10, 5'd10};
    localparam [10:0] INITIAL_MID  = {6'd9, 5'd10};
    localparam [10:0] INITIAL_TAIL = {6'd8, 5'd10};

    reg game_clk = 1'b0;
    reg resetn = 1'b1;
    reg enable = 1'b0;
    reg [32:0] start_pos = {INITIAL_HEAD, INITIAL_MID, INITIAL_TAIL};
    reg [1:0] start_dir = D_RIGHT;
    reg [1:0] kb_dir = D_RIGHT;
    wire [1:0] snake_dir;
    wire [32:0] pos_list;
    reg passed = 1'b0;

    always #10 game_clk = ~game_clk;

    snake dut (
        .game_clk(game_clk), .resetn(resetn), .enable(enable),
        .start_pos(start_pos), .start_dir(start_dir), .kb_dir(kb_dir),
        .pos_list(pos_list), .snake_dir(snake_dir)
    );

    task tick;
        begin @(posedge game_clk); #1; end
    endtask

    task check_state;
        input [32:0] expected_pos;
        input [1:0] expected_dir;
        input [8*48-1:0] description;
        begin
            if (pos_list !== expected_pos || snake_dir !== expected_dir)
                $fatal(1, "%0t: %0s expected pos=%09h dir=%0d, got pos=%09h dir=%0d",
                       $time, description, expected_pos, expected_dir, pos_list, snake_dir);
        end
    endtask

    initial begin
        resetn = 1'b0;
        tick;
        check_state(start_pos, start_dir, "reset loads start position and direction");
        resetn = 1'b1;
        enable = 1'b1;

        kb_dir = D_RIGHT;
        tick;
        check_state({{6'd11,5'd10}, INITIAL_HEAD, INITIAL_MID}, D_RIGHT, "move right");

        // Direction input changes between game clock edges; snake_dir must stay registered.
        kb_dir = D_UP;
        #3;
        if (snake_dir !== D_RIGHT)
            $fatal(1, "snake_dir changed without a game_clk edge");
        tick;
        check_state({{6'd11,5'd9}, {6'd11,5'd10}, INITIAL_HEAD}, D_UP, "move up and register direction");

        enable = 1'b0;
        kb_dir = D_LEFT;
        tick;
        check_state({{6'd11,5'd9}, {6'd11,5'd10}, INITIAL_HEAD}, D_UP, "disabled holds position and direction");

        enable = 1'b1;
        kb_dir = D_LEFT;
        tick;
        check_state({{6'd10,5'd9}, {6'd11,5'd9}, {6'd11,5'd10}}, D_LEFT, "move left");

        // Reset direction follows the supplied initial direction.
        start_dir = D_DOWN;
        resetn = 1'b0;
        tick;
        check_state(start_pos, D_DOWN, "reset restores configured start direction");

        passed = 1'b1;
        $display("PASS: snake position and game-clocked direction checks");
        $finish;
    end
endmodule

// Small open test map for snake.v, whose maze dependency is supplied by the project.
module maze(input wire [5:0] x, input wire [4:0] y, output wire wall);
    assign wall = (x >= 6'd40) || (y >= 5'd30);
endmodule

`default_nettype wire
