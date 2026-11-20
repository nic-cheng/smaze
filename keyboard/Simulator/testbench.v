`timescale 1ns / 1ns
`default_nettype none

module testbench;
    parameter CLOCK_PERIOD = 20;
    parameter [7:0] BREAK = 8'hF0, W = 8'h1D, A = 8'h1C, S = 8'h1B, D = 8'h23;
    parameter [7:0] SPACE = 8'h29; // arbitrary key
    parameter [4:0] STOPPED =       5'b0_0001,
                    MOVING_UP =     5'b1_0001,
                    MOVING_LEFT =   5'b1_0010,
                    MOVING_DOWN =   5'b1_0100,
                    MOVING_RIGHT =  5'b1_1000;

    reg CLOCK_50 = 1'b0;
    reg [3:0] KEY = 4'b1110;
    reg key_action = 1'b0;
    reg [7:0] scan_code = 8'h00;
    wire ps2_clk, ps2_dat, keyboard_dat;
    wire [9:0] LEDR;
    reg passed = 1'b0;

    always #(CLOCK_PERIOD / 2) CLOCK_50 = ~CLOCK_50;

    // FPGAcademy keyboard module 
    PS2_keyboard keyboard (
        .Clock(CLOCK_50), .Resetn(KEY[0]),
        .key_action(key_action), .scan_code(scan_code),
        .ps2_clk(ps2_clk), .ps2_dat(keyboard_dat)
    );

    // Timing fix (sample after rising edge write)
    assign #(CLOCK_PERIOD + CLOCK_PERIOD / 2) ps2_dat = keyboard_dat;

    top dut (
        .CLOCK_50(CLOCK_50), .SW(10'b0), .KEY(KEY),
        .HEX0(), .HEX1(), .HEX2(), .HEX3(), .HEX4(), .HEX5(),
        .LEDR(LEDR), .PS2_CLK(ps2_clk), .PS2_DAT(ps2_dat)
    );

    wire received_data_en = dut.U1.kbi.received_data_en;
    wire [7:0] received_data = dut.U1.kbi.received_data;

    // Confirm if LEDR is in the exact expected state
    task check_leds;
        input [4:0] expected;
        begin
            if (LEDR !== {5'b10000, expected})
                $fatal(1, "%0t: scan code %02h, expected LEDR=%010b, got %010b",
                       $time, scan_code, {5'b10000, expected}, LEDR);
        end
    endtask

    // Simulate a keyboard input and verify LEDs change to expected output
    task send_and_check;
        input [7:0] code;
        input [4:0] expected;
        integer cycles;
        begin
            @(negedge CLOCK_50);
            scan_code = code;
            key_action = 1'b1;
            @(negedge CLOCK_50);
            key_action = 1'b0;

            // Confirm delivery even when the byte should leave the LEDs unchanged.
            // ~70 CLOCK_ in the keyboard model.
            cycles = 0;
            while (received_data_en !== 1'b1 && cycles < 100) begin
                @(negedge CLOCK_50);
                cycles = cycles + 1;
            end
            if (received_data_en !== 1'b1)
                $fatal(1, "%0t: timed out receiving scan code %02h", $time, code);
            if (received_data !== code)
                $fatal(1, "%0t: sent scan code %02h, received %02h",
                       $time, code, received_data);

            // Sample after the movement logic has consumed the receive strobe.
            @(negedge CLOCK_50);
            check_leds(expected);
        end
    endtask

    initial begin
        repeat (3) @(negedge CLOCK_50);
        check_leds(STOPPED);
        KEY[0] = 1'b1;

        send_and_check(SPACE, STOPPED);
        send_and_check(W, MOVING_UP);
        send_and_check(A, MOVING_LEFT);
        send_and_check(BREAK, MOVING_LEFT);
        send_and_check(W, MOVING_LEFT); // Releasing W preserves the A direction.
        send_and_check(S, MOVING_DOWN);
        send_and_check(BREAK, MOVING_DOWN);
        send_and_check(S, MOVING_DOWN); // Releasing the active key keeps moving high.
        send_and_check(D, MOVING_RIGHT);
        send_and_check(SPACE, MOVING_RIGHT);

        // Reset clears movement, direction, and any pending break prefix.
        send_and_check(BREAK, MOVING_RIGHT);
        KEY[0] = 1'b0;
        repeat (3) @(negedge CLOCK_50);
        check_leds(STOPPED);
        KEY[0] = 1'b1;
        send_and_check(D, MOVING_RIGHT);

        passed = 1'b1;
        $display("PASS: PS/2 keyboard movement checks");
        $finish;
    end
endmodule

`default_nettype wire
