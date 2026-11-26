`timescale 1ns / 1ns
`default_nettype none

module testbench;
    localparam [1:0] D_UP = 2'd0, D_LEFT = 2'd1,
                     D_DOWN = 2'd2, D_RIGHT = 2'd3;
    localparam [10:0] INITIAL_HEAD = {6'd3, 5'd2};
    localparam [10:0] INITIAL_MID  = {6'd2, 5'd2};
    localparam [10:0] INITIAL_TAIL = {6'd1, 5'd2};
    localparam [10:0] RIGHT_HEAD = {6'd4, 5'd2};
    localparam [10:0] DOWN_HEAD  = {6'd4, 5'd3};
    localparam [10:0] LEFT_HEAD  = {6'd3, 5'd3};

    reg clock = 1'b0;
    reg resetn = 1'b0;
    reg move_enable = 1'b0;
    reg enable = 1'b0;
    reg [32:0] start_pos = {INITIAL_HEAD, INITIAL_MID, INITIAL_TAIL};
    reg [1:0] start_dir = D_RIGHT;
    reg [1:0] kb_dir = D_RIGHT;
    wire [1:0] snake_dir;
    wire [32:0] pos_list;
    reg passed = 1'b0;

    always #10 clock = ~clock;

    snake dut (
        .clock(clock), .resetn(resetn), .move_enable(move_enable), .enable(enable),
        .start_pos(start_pos), .start_dir(start_dir), .kb_dir(kb_dir),
        .pos_list(pos_list), .snake_dir(snake_dir)
    );

    task tick;
        begin @(posedge clock); #1; end
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
        tick;
        check_state(start_pos, start_dir, "reset loads start position and direction");
        resetn = 1'b1;
        enable = 1'b1;
        kb_dir = D_DOWN;
        tick;
        check_state(start_pos, D_RIGHT, "move_enable low holds position and direction");

        move_enable = 1'b1;
        enable = 1'b0;
        tick;
        check_state(start_pos, D_RIGHT, "enable low holds position and direction");

        enable = 1'b1;
        kb_dir = D_RIGHT;
        tick;
        check_state({RIGHT_HEAD, INITIAL_HEAD, INITIAL_MID}, D_RIGHT, "move right");

        // Row 1 is a wall above the snake.
        kb_dir = D_UP;
        tick;
        check_state({RIGHT_HEAD, INITIAL_HEAD, INITIAL_MID}, D_RIGHT, "wall holds position and direction");

        kb_dir = D_DOWN;
        #3;
        check_state({RIGHT_HEAD, INITIAL_HEAD, INITIAL_MID}, D_RIGHT, "hold between clock edges");
        tick;
        check_state({DOWN_HEAD, RIGHT_HEAD, INITIAL_HEAD}, D_DOWN, "move down");

        kb_dir = D_LEFT;
        tick;
        check_state({LEFT_HEAD, DOWN_HEAD, RIGHT_HEAD}, D_LEFT, "move left");

        kb_dir = D_UP;
        tick;
        check_state({INITIAL_HEAD, LEFT_HEAD, DOWN_HEAD}, D_UP, "move up");

        kb_dir = D_LEFT;
        start_dir = D_DOWN;
        start_pos = { {6'd5, 5'd2}, RIGHT_HEAD, INITIAL_HEAD };
        resetn = 1'b0;
        tick;
        check_state(start_pos, D_DOWN, "reset takes priority over an enabled move");

        passed = 1'b1;
        $display("PASS: snake movement, direction, enables, and wall checks");
        $finish;
    end
endmodule

`default_nettype wire
