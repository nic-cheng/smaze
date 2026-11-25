`timescale 1ns / 1ns
`default_nettype none

module testbench;
    parameter CLOCK_PERIOD = 20;

    localparam [1:0] D_UP = 2'd0,
                     D_LEFT = 2'd1,
                     D_DOWN = 2'd2,
                     D_RIGHT = 2'd3;

    reg game_clk = 1'b0;
    reg resetn = 1'b1;
    reg enable = 1'b0;
    reg [1199:0] maze = 1200'b0;
    reg [32:0] start_pos;
    reg [1:0] direction = D_RIGHT;
    wire [32:0] pos_list;
    reg passed = 1'b0;

    localparam [10:0] INITIAL_HEAD = {6'd10, 5'd10};
    localparam [10:0] INITIAL_MID  = {6'd9,  5'd10};
    localparam [10:0] INITIAL_TAIL = {6'd8,  5'd10};

    always #(CLOCK_PERIOD / 2) game_clk = ~game_clk;

    snake dut (
        .game_clk(game_clk), .resetn(resetn), .enable(enable),
        .maze(maze), .start_pos(start_pos), .direction(direction),
        .pos_list(pos_list)
    );

    task check_pos;
        input [32:0] expected;
        input [8*40-1:0] description;
        begin
            if (pos_list !== expected)
                $fatal(1, "%0t: %0s expected pos_list=%09h, got %09h",
                       $time, description, expected, pos_list);
        end
    endtask

    task tick;
        begin
            @(posedge game_clk);
            #1;
        end
    endtask

    initial begin
        start_pos = {INITIAL_HEAD, INITIAL_MID, INITIAL_TAIL};

        // Synchronous active-low reset loads the initial three-segment snake.
        resetn = 1'b0;
        tick;
        check_pos(start_pos, "reset loads start_pos");
        resetn = 1'b1;

        // Move one cell in each direction and verify the body shifts behind it.
        enable = 1'b1;
        direction = D_RIGHT;
        tick;
        check_pos({{6'd11, 5'd10}, INITIAL_HEAD, INITIAL_MID}, "move right");

        direction = D_UP;
        tick;
        check_pos({{6'd11, 5'd9}, {6'd11, 5'd10}, INITIAL_HEAD}, "move up");

        direction = D_LEFT;
        tick;
        check_pos({{6'd10, 5'd9}, {6'd11, 5'd9}, {6'd11, 5'd10}}, "move left");

        direction = D_DOWN;
        tick;
        check_pos({{6'd10, 5'd10}, {6'd10, 5'd9}, {6'd11, 5'd9}}, "move down");

        // Disabled movement holds the entire body position.
        enable = 1'b0;
        direction = D_RIGHT;
        tick;
        check_pos({{6'd10, 5'd10}, {6'd10, 5'd9}, {6'd11, 5'd9}}, "disabled holds position");

        // A wall in the destination cell blocks movement and body shifting.
        maze[10 * 40 + 11] = 1'b1;
        enable = 1'b1;
        tick;
        check_pos({{6'd10, 5'd10}, {6'd10, 5'd9}, {6'd11, 5'd9}}, "wall blocks movement");

        passed = 1'b1;
        $display("PASS: snake movement, reset, enable, and wall checks");
        $finish;
    end
endmodule

`default_nettype wire
