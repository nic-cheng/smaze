`timescale 1ns / 1ps

module testbench ( );

	parameter CLOCK_PERIOD = 20;
    parameter RESOLUTION = "320x240"; // "640x480", "320x240", "160x120"
    parameter n = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8);

    reg CLOCK_50;	
	reg [9:0] SW;
	reg [3:0] KEY;
	wire [9:0] LEDR;
    wire [6:0] HEX2, HEX1, HEX0;
	wire [n-1:0] VGA_X;
	wire [n-2:0] VGA_Y;
	wire [23:0] VGA_COLOR;
    wire plot;

	initial begin   
        CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
        SW  <= 10'b0;           // ADDED: switches are unused now, so give them a defined value
        KEY <= 4'b1110;         // reset
        #50 KEY <= 4'b1111;     // release reset

        #3_300_000;
        $stop;
	end // initial

	milestone_1 U1 (CLOCK_50, SW, KEY, LEDR, HEX2, HEX1, HEX0, VGA_X, VGA_Y, VGA_COLOR, plot);
        defparam U1.RESOLUTION = RESOLUTION;

endmodule
