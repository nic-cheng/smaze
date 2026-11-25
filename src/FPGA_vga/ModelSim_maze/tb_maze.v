`timescale 1ns / 1ps

module tb_maze ( );

	parameter CLOCK_PERIOD = 20;

	reg clock, resetn;
	wire [8:0] x;
	wire [7:0] y;
	wire [8:0] color;
	wire write, done, snake;
	wire [32:0] pos_list = {6'd3,5'd1, 6'd2,5'd1, 6'd1,5'd1};

	integer snake_count = 0;

	initial begin
		clock <= 1'b0;
	end
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) clock <= ~clock;
	end

	initial begin
		resetn <= 1'b0;
		#50 resetn <= 1'b1;

		//wait 1.7 ms then stop
		#1_700_000;
		$stop;
	end

	always @ (posedge clock)
	begin
		if (write && snake)
			snake_count = snake_count + 1;

		if (write && x == 0 && y == 9)
			$display("at (0,9): color=%b (expect 000000000 since its wall)", color);
		if (write && x == 10 && y == 9)
			$display("at (10,9): color=%b (expect 111111111 since its a path)", color);
		if (write && x == 319 && y == 239)
			$display("frame done: %0d snake pixels (expect 192 because its 3 8x8 pixels)", snake_count);
	end

	maze_draw  U1 (clock, resetn, 1'b1, x, y, color, write, done);
	snake_draw U2 (x, y, pos_list, snake);

endmodule