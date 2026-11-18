/* 
 * The code uses a "VGA adapter" to send pixel colors to the VGA window.
 *  First, press KEY[0] to reset the circuit. It will display the contents of a video memory
 *  in the VGA adapter as a background image. Then, the maze will be rendered onto the screen. 
  * Make sure to set the resolution to 320x240.
*/
module milestone_1(CLOCK_50, SW, KEY, LEDR, HEX2, HEX1, HEX0, VGA_R, VGA_G, VGA_B,
                VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);

	input wire CLOCK_50;	
	input wire [9:0] SW;
	input wire [3:0] KEY;
    output wire [6:0] HEX2, HEX1, HEX0;
	output wire [7:0] VGA_R;
    output wire [7:0] VGA_G;
    output wire [7:0] VGA_B;
    output wire VGA_HS;
    output wire VGA_VS;
    output wire VGA_BLANK_N;
    output wire VGA_SYNC_N;
    output wire VGA_CLK;

    output wire [9:0] LEDR;
    assign LEDR = 10'b0;
    assign HEX2 = 7'b111_1111;
    assign HEX1 = 7'b111_1111;
    assign HEX0 = 7'b111_1111;

    wire VGA_SYNC = 1'b1;  // starts sync right away (in DESim it had a different purpose)

    //added
    wire resetn = KEY[0];
    wire [8:0] x;
    wire [7:0] y;
    wire done;
    wire [8:0] colour;
    wire write;

    maze_draw m1(CLOCK_50, resetn, VGA_SYNC, x, y, colour, write, done);

    vga_adapter VGA (
        .resetn(KEY[0]),
        .clock(CLOCK_50),
        .color(colour),
        .x(x),
        .y(y),
        .write(write),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK));
        defparam VGA.RESOLUTION = "320x240";

endmodule

//NEW: create maze, scan for 0s and 1s and tell the vga adapter what to draw
module maze_draw(clock, resetn, start, x, y, colour, write, done);
    input wire clock, resetn, start;
    output reg [8:0] x;
    output reg [7:0] y;
    output reg done;
    output wire [8:0] colour;
    output wire write;

//    reg [19:0] maze [0:14];
//
//    initial
//    begin
//        maze[0]  = 20'b11111_11111_11111_11111;
//        maze[1]  = 20'b10000_00001_11111_00000;
//        maze[2]  = 20'b10111_11101_11111_01111;
//        maze[3]  = 20'b10100_00101_00000_01001;
//        maze[4]  = 20'b11101_01101_01111_11011;
//        maze[5]  = 20'b10001_01000_01000_00011;
//        maze[6]  = 20'b10111_11101_11101_11111;
//        maze[7]  = 20'b10000_00001_01001_00000;
//        maze[8]  = 20'b11111_11011_01111_01111;
//        maze[9]  = 20'b10000_01011_00000_01001;
//        maze[10] = 20'b10110_01011_11110_11011;
//        maze[11] = 20'b10111_01000_00010_00001;
//        maze[12] = 20'b10000_01111_10111_11101;
//        maze[13] = 20'b11111_00000_00000_00001;
//        maze[14] = 20'b11111_11111_11111_11111; 
//    end

	reg [19:0] maze_rows;

    always @(*) begin
    case (row)
        4'b0000: maze_rows = 20'b11111_11111_11111_11111;
        4'b0001: maze_rows = 20'b10000_00001_11111_00000;
        4'b0010: maze_rows = 20'b10111_11101_11111_01111;
        4'b0011: maze_rows = 20'b10100_00101_00000_01001;
        4'b0100: maze_rows = 20'b11101_01101_01111_11011;
        4'b0101: maze_rows = 20'b10001_01000_01000_00011;
        4'b0110: maze_rows = 20'b10111_11101_11101_11111;
        4'b0111: maze_rows = 20'b10000_00001_01001_00000;
        4'b1000: maze_rows = 20'b11111_11011_01111_01111;
        4'b1001: maze_rows = 20'b10000_01011_00000_01001;
        4'b1010: maze_rows = 20'b10110_01011_11110_11011;
        4'b1011: maze_rows = 20'b10111_01000_00010_00001;
        4'b1100: maze_rows = 20'b10000_01111_10111_11101;
        4'b1101: maze_rows = 20'b11111_00000_00000_00001;
        4'b1110: maze_rows = 20'b11111_11111_11111_11111;
        default: maze_rows = 20'b11111_11111_11111_11111;
    endcase
    end

    always @ (posedge clock)
    begin
        if (resetn == 1'b0)
        begin
            x <= 9'b0;
            y <= 8'b0;
            done <= 1'b0;
        end
        else if (start & ~done)
        begin
            if (x == 9'd319)
            begin
                if (y == 8'd239)
                    done <= 1'b1;
                else
                begin
                    x <= 9'b0;
                    y <= y + 1'b1;
                end
            end
            else
                x <= x + 1'b1;
        end
    end

    wire [3:0] row = y[7:4];
    wire [4:0] col = x[8:4]; //drop bottom four bits to scale it

    wire wall = maze_rows[19-col];
    assign colour = (wall) ? 9'b000_000_000: 9'b 111_111_111;
    //assign colour = (row[0] ^ col[0]) ? 9'b111_111_111 : 9'b000_000_000; //test
    assign write = start & ~done;

endmodule