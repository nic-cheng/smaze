`timescale 1ns / 1ps

module testbench ( );

	parameter CLOCK_PERIOD = 20;

    reg CLOCK_50;	
	reg [9:0] SW;
	reg [3:0] KEY;
	wire [9:0] LEDR;
    wire [6:0] HEX2, HEX1, HEX0;
	// replace desim outputs with this
	wire [7:0] VGA_R, VGA_G, VGA_B;
	wire VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;

	initial begin
        CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
        SW  <= 10'b0;
        KEY <= 4'b1110;
        #50 KEY <= 4'b1111; //release reset

        //wait 1.7 ms then stop
        #1_700_000;
        $stop;
	end // initial

	milestone_1 U1 (CLOCK_50, SW, KEY, LEDR, HEX2, HEX1, HEX0,
	                VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);

endmodule