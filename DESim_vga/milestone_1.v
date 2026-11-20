`default_nettype none

/* The code uses a "VGA adapter" to send pixel colors to the VGA window. (DESim)
 *  First, press KEY[0] to reset the circuit. It will display the contents of a video memory
 *  in the VGA adapter as a background image. LEDR[9] will be illuminated to indicate when 
 *  this process is completed. Then, the maze will be rendered onto the screen. Make sure to
 *  set the resolution to 320x240.
*/
module milestone_1(CLOCK_50, SW, KEY, LEDR, HEX2, HEX1, HEX0, VGA_X, VGA_Y, VGA_COLOR, plot);
	
    // default resolution. Specify a resolution in top.v
    parameter RESOLUTION = "320x240"; // "640x480" "320x240" "160x120"

    // default color depth. Specify a color in top.v
    parameter COLOR_DEPTH = 9; // 9 6 3

    // specify the number of bits needed for an X (column) pixel coordinate on the VGA display
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8);
    // specify the number of bits needed for a Y (row) pixel coordinate on the VGA display
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7);

	input wire CLOCK_50;	
	input wire [9:0] SW;
	input wire [3:0] KEY;
	input wire [9:0] LEDR;
    output wire [6:0] HEX2, HEX1, HEX0;
	output wire [nX-1:0] VGA_X;          // for DESim VGA
	output wire [nY-1:0] VGA_Y;          // for DESim VGA
	output wire [23:0] VGA_COLOR;        // for DESim VGA
	output wire plot;                    // for DESim VGA

    wire VGA_SYNC;  // used as start

    //added
    wire resetn = KEY[0];
    wire [8:0] x;
    wire [7:0] y;
    wire done;
    wire [8:0] colour;
    wire write;

    maze_draw m1(CLOCK_50, resetn, VGA_SYNC, x, y, colour, write, done);

    // instantiate the DESim VGA adapter
    `define VGA_MEMORY              // include a memory module in the VGA adapter
    vga_adapter VGA (
        .resetn(KEY[0]),
        .clock(CLOCK_50),
        .color(colour),             // used to draw pixels on top of background
        .x(x),                      // used to draw pixels on top of background
        .y(y),                      // used to draw pixels on top of background
        .write(write),              // used to draw pixels on top of background
        .VGA_X(VGA_X),              // the output VGA x coordinate (column)
        .VGA_Y(VGA_Y),              // the output VGA y coordinate (row)
        .VGA_COLOR(VGA_COLOR),      // the output VGA color
        .VGA_SYNC(VGA_SYNC),        // indicates when background MIF has been drawn
        .plot(plot));               // the output VGA plot signal
		defparam VGA.RESOLUTION = RESOLUTION;
        // choose background image according to resolution and color depth
		defparam VGA.BACKGROUND_IMAGE = 
            (RESOLUTION == "640x480") ?
                ((COLOR_DEPTH == 9) ? "./MIF/rainbow_640_9.mif" :
                ((COLOR_DEPTH == 6) ? "./MIF/rainbow_640_6.mif" :
                "./MIF/rainbow_640_3.mif")) : 
            ((RESOLUTION == "320x240") ?
                ((COLOR_DEPTH == 9) ? "./MIF/rainbow_320_9.mif" :
                ((COLOR_DEPTH == 6) ? "./MIF/rainbow_320_6.mif" :
                "./MIF/rainbow_320_3.mif")) : 
                    // 160x120
                    ((COLOR_DEPTH == 9) ? "./MIF/rainbow_160_9.mif" :
                    ((COLOR_DEPTH == 6) ? "./MIF/rainbow_160_6.mif" :
                    "./MIF/rainbow_160_3.mif")));
		defparam VGA.COLOR_DEPTH = COLOR_DEPTH;
        
        assign LEDR[9] = VGA_SYNC;      // turn on LED when background drawing is done
endmodule

//NEW: create maze, scan for 0s and 1s and tell the vga adapter what to draw
module maze_draw(clock, resetn, start, x, y, colour, write, done);
    input wire clock, resetn, start;
    output reg [8:0] x;
    output reg [7:0] y;
    output reg done;
    output wire [8:0] colour;
    output wire write;

    reg [19:0] maze [0:14];

    initial
    begin
        maze[0]  = 20'b11111_11111_11111_11111;
        maze[1]  = 20'b10000_00001_11111_00000;
        maze[2]  = 20'b10111_11101_11111_01111;
        maze[3]  = 20'b10100_00101_00000_01001;
        maze[4]  = 20'b11101_01101_01111_11011;
        maze[5]  = 20'b10001_01000_01000_00011;
        maze[6]  = 20'b10111_11101_11101_11111;
        maze[7]  = 20'b10000_00001_01001_00000;
        maze[8]  = 20'b11111_11011_01111_01111;
        maze[9]  = 20'b10000_01011_00000_01001;
        maze[10] = 20'b10110_01011_11110_11011;
        maze[11] = 20'b10111_01000_00010_00001;
        maze[12] = 20'b10000_01111_10111_11101;
        maze[13] = 20'b11111_00000_00000_00001;
        maze[14] = 20'b11111_11111_11111_11111; 
    end

    //always block to tell the vga adapter where to draw and what
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

    wire wall = maze[row][19-col];
    assign colour = (wall) ? 9'b000_000_000: 9'b 111_111_111;
    // assign colour = (row[0] ^ col[0]) ? 9'b111_111_111 : 9'b000_000_000; //test
    assign write = start & ~done;

endmodule

// // n-bit register with reset and enable
// module regn(R, Resetn, E, Clock, Q);
//     parameter n = 8;
//     input wire [n-1:0] R;
//     input wire Resetn, E, Clock;
//     output reg [n-1:0] Q;

//     always @(posedge Clock)
//         if (!Resetn)
//             Q <= {n{1'b0}};
//         else if (E)
//             Q <= R;
// endmodule

// // n-bit up-counter with reset, load, and enable
// module up_count (R, Clock, Resetn, L, E, Q);
//     parameter n = 8;
//     input wire [n-1:0] R;
//     input wire Clock, Resetn, E, L;
//     output reg [n-1:0] Q;

//     always @ (posedge Clock)
//         if (Resetn == 0)
//             Q <= {n{1'b0}};
//         else if (L == 1)
//             Q <= R;
//         else if (E)
//             Q <= Q + 1'b1;
// endmodule

// hex to 7-segment code converter
// module hex7seg (hex, display);
//     input wire [3:0] hex;
//     output reg [6:0] display;

//     /*
//      *       0  
//      *      ---  
//      *     |   |
//      *    5|   |1
//      *     | 6 |
//      *      ---  
//      *     |   |
//      *    4|   |2
//      *     |   |
//      *      ---  
//      *       3  
//      */
//     always @ (hex)
//         case (hex)
//             4'h0: display = 7'b1000000;
//             4'h1: display = 7'b1111001;
//             4'h2: display = 7'b0100100;
//             4'h3: display = 7'b0110000;
//             4'h4: display = 7'b0011001;
//             4'h5: display = 7'b0010010;
//             4'h6: display = 7'b0000010;
//             4'h7: display = 7'b1111000;
//             4'h8: display = 7'b0000000;
//             4'h9: display = 7'b0011000;
//             4'hA: display = 7'b0001000;
//             4'hB: display = 7'b0000011;
//             4'hC: display = 7'b1000110;
//             4'hD: display = 7'b0100001;
//             4'hE: display = 7'b0000110;
//             4'hF: display = 7'b0001110;
//         endcase
// endmodule
