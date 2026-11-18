`timescale 1ns / 1ns
`default_nettype none

module testbench;
    localparam integer CLOCK_PERIOD = 20;

    reg CLOCK_50 = 1'b0;
    reg [0:0] KEY = 1'b0; // KEY[0] low asserts reset
    wire [9:0] LEDR;
    wire PS2_CLK;
    wire PS2_DAT;

    reg key_action = 1'b0;
    reg [7:0] scan_code = 8'h00;

    always #(CLOCK_PERIOD / 2) CLOCK_50 = ~CLOCK_50;

    // Device under test and PS/2 keyboard stimulus model.
    kb_demo DUT (CLOCK_50, KEY, PS2_CLK, PS2_DAT, LEDR);
    PS2_keyboard Keyboard (CLOCK_50, KEY[0], key_action, scan_code,
                           PS2_CLK, PS2_DAT);

    task send_scan_code;
        input [7:0] code;
        begin
            @(negedge CLOCK_50);
            scan_code = code;
            key_action = 1'b1;
            @(negedge CLOCK_50);
            key_action = 1'b0;
            // The model serializes each byte over the PS/2 wires.
            #5000;
        end
    endtask

    task check_leds;
        input [3:0] expected_direction;
        input [7:0] key_name;
        begin
            if (LEDR[9:5] !== 5'b10000)
                $fatal(1, "%0s: expected LEDR[9:5]=10000, got %b",
                       key_name, LEDR[9:5]);
            if (LEDR[4] !== 1'b1)
                $fatal(1, "%0s: expected moving LED LEDR[4] on", key_name);
            if (LEDR[3:0] !== expected_direction)
                $fatal(1, "%0s: expected LEDR[3:0]=%b, got %b",
                       key_name, expected_direction, LEDR[3:0]);
            $display("PASS %0s: LEDR=%b", key_name, LEDR);
        end
    endtask

    initial begin
        $display("Starting kb_demo PS/2 test");

        // Assert and release active-low reset.
        KEY[0] = 1'b0;
        #200;
        if (LEDR[9:5] !== 5'b10000)
            $fatal(1, "Reset: expected LEDR[9:5]=10000, got %b", LEDR[9:5]);
        if (LEDR[4] !== 1'b0)
            $fatal(1, "Reset: expected LEDR[4] off, got %b", LEDR[4]);
        if (LEDR[3:0] !== 4'b0001)
            $fatal(1, "Reset: expected default direction on LEDR[0], got %b",
                   LEDR[3:0]);

        KEY[0] = 1'b1;
        #200;

        // PS/2 Set 2 make codes: W=1D, A=1C, S=1B, D=23.
        send_scan_code(8'h1D);
        check_leds(4'b0001, "W");

        // A release is F0 followed by the released key's make code.
        send_scan_code(8'hF0);
        send_scan_code(8'h1D);
        if (LEDR[3:0] !== 4'b0001)
            $fatal(1, "W release changed direction unexpectedly: %b", LEDR[3:0]);

        send_scan_code(8'h1C);
        check_leds(4'b0010, "A");
        send_scan_code(8'h1B);
        check_leds(4'b0100, "S");
        send_scan_code(8'h23);
        check_leds(4'b1000, "D");

        $display("All kb_demo LED checks passed.");
        $finish;
    end
endmodule

`default_nettype wire
