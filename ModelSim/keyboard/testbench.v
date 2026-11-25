`timescale 1ns / 1ns
`default_nettype none

module testbench;
    localparam CLOCK_PERIOD = 20;
    localparam [7:0] BREAK = 8'hF0, W = 8'h1D, A = 8'h1C,
                     S = 8'h1B, D = 8'h23, SPACE = 8'h29;
    localparam [1:0] D_UP = 2'd0, D_LEFT = 2'd1,
                     D_DOWN = 2'd2, D_RIGHT = 2'd3;

    reg CLOCK_50 = 1'b0;
    reg resetn = 1'b0;
    reg [1:0] snake_dir = D_RIGHT;
    wire [1:0] kb_dir;
    wire moving, spacebar;
    tri1 ps2_clk, ps2_dat;
    wire received_data_en = dut.received_data_en;
    wire [7:0] received_data = dut.received_data;
    reg passed = 1'b0;

    always #(CLOCK_PERIOD / 2) CLOCK_50 = ~CLOCK_50;

    kb_interface dut (
        .CLOCK_50(CLOCK_50), .resetn(resetn),
        .PS2_CLK(ps2_clk), .PS2_DAT(ps2_dat), .snake_dir(snake_dir),
        .moving(moving), .kb_dir(kb_dir), .spacebar(spacebar)
    );

    task check_state;
        input [1:0] expected_dir;
        input expected_moving;
        input expected_spacebar;
        input [8*40-1:0] description;
        begin
            if (kb_dir !== expected_dir || moving !== expected_moving ||
                spacebar !== expected_spacebar)
                $fatal(1, "%0t: %0s expected dir=%0d moving=%b space=%b, got dir=%0d moving=%b space=%b",
                       $time, description, expected_dir, expected_moving, expected_spacebar,
                       kb_dir, moving, spacebar);
        end
    endtask

    task send_code;
        input [7:0] code;
        begin
            // Isolate the keyboard scan-code parser from PS/2 wire timing.
            @(negedge CLOCK_50);
            force dut.received_data = code;
            force dut.received_data_en = 1'b1;
            @(negedge CLOCK_50);
            release dut.received_data_en;
            release dut.received_data; // outputs are settled by this negedge
        end
    endtask

    initial begin
        repeat (3) @(negedge CLOCK_50);
        check_state(D_UP, 1'b0, 1'b0, "reset defaults");
        resetn = 1'b1;

        send_code(SPACE);
        check_state(D_UP, 1'b0, 1'b0, "space does not start movement");

        // An A press is accepted when the snake is moving right.
        snake_dir = D_RIGHT;
        send_code(A);
        check_state(D_LEFT, 1'b1, 1'b0, "A selects left and starts movement");

        // Reject the reverse of the actual snake direction.
        snake_dir = D_DOWN;
        send_code(W);
        check_state(D_LEFT, 1'b1, 1'b0, "reject W while moving down");

        // Break prefix suppresses the released key; next make code is accepted.
        send_code(BREAK);
        check_state(D_LEFT, 1'b1, 1'b0, "break prefix preserves state");
        snake_dir = D_LEFT;
        send_code(W);
        check_state(D_UP, 1'b1, 1'b0, "W accepted while moving left");

        send_code(BREAK);
        send_code(SPACE);
        check_state(D_UP, 1'b1, 1'b1, "space produces a one-cycle press pulse");
        @(negedge CLOCK_50);
        check_state(D_UP, 1'b1, 1'b0, "space pulse clears next cycle");

        resetn = 1'b0;
        repeat (2) @(negedge CLOCK_50);
        check_state(D_UP, 1'b0, 1'b0, "reset clears movement and direction");

        passed = 1'b1;
        $display("PASS: PS/2 keyboard interface and reversal checks");
        $finish;
    end
endmodule

`default_nettype wire
