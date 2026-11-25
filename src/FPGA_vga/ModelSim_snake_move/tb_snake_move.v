`timescale 1ns / 1ps

module tb_snake_move ( );

	parameter CLOCK_PERIOD = 20;

	reg clock, resetn, tick;
	reg [1:0] direction;
	wire [32:0] pos_list;

	initial begin
		clock <= 1'b0;
	end
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) clock <= ~clock;
	end

	initial begin
		resetn <= 1'b0; tick <= 1'b0; direction <= 2'b00;
		#50 resetn <= 1'b1;

		#40;
		$display("reset: head=(%0d,%0d) mid=(%0d,%0d) tail=(%0d,%0d) - expect (3,1) (2,1) (1,1)",
			pos_list[32:27], pos_list[26:22], pos_list[21:16], pos_list[15:11], pos_list[10:5], pos_list[4:0]);

		// right
		direction <= 2'b00;
		#20 tick <= 1'b1;
		#20 tick <= 1'b0;
		#40;
		$display("right: head=(%0d,%0d) mid=(%0d,%0d) tail=(%0d,%0d) - expect (4,1) (3,1) (2,1)",
			pos_list[32:27], pos_list[26:22], pos_list[21:16], pos_list[15:11], pos_list[10:5], pos_list[4:0]);

		// up
		direction <= 2'b10;
		#20 tick <= 1'b1;
		#20 tick <= 1'b0;
		#40;
		$display("up:    head=(%0d,%0d) mid=(%0d,%0d) tail=(%0d,%0d) - expect (4,0) (4,1) (3,1)",
			pos_list[32:27], pos_list[26:22], pos_list[21:16], pos_list[15:11], pos_list[10:5], pos_list[4:0]);

		// left
		direction <= 2'b01;
		#20 tick <= 1'b1;
		#20 tick <= 1'b0;
		#40;
		$display("left:  head=(%0d,%0d) mid=(%0d,%0d) tail=(%0d,%0d) - expect (3,0) (4,0) (4,1)",
			pos_list[32:27], pos_list[26:22], pos_list[21:16], pos_list[15:11], pos_list[10:5], pos_list[4:0]);

		// down
		direction <= 2'b11;
		#20 tick <= 1'b1;
		#20 tick <= 1'b0;
		#40;
		$display("down:  head=(%0d,%0d) mid=(%0d,%0d) tail=(%0d,%0d) - expect (3,1) (3,0) (4,0)",
			pos_list[32:27], pos_list[26:22], pos_list[21:16], pos_list[15:11], pos_list[10:5], pos_list[4:0]);

		$stop;
	end

	snake_move U1 (clock, resetn, direction, tick, pos_list);

endmodule