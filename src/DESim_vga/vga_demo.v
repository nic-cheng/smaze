`default_nettype none

/*  This code draws a maze and then renders a block onto the screen.
 *  The switches SW1 and SW0 can be used to set the direction of the block within the maze.
 *  Once the block reaches a wall, it stops moving in that direction.
 *  Press KEY[0] to reset.
*/

module vga_demo(CLOCK_50, SW, KEY, LEDR, VGA_X, VGA_Y, VGA_COLOR, plot);
	
    parameter RESOLUTION = "320x240";
    parameter COLOR_DEPTH = 9; // 9 6 3

    // specify the number of bits needed for a pixel coordinate on the VGA display
    parameter nX = 9;
    parameter nY = 8;

	input wire CLOCK_50;	
	input wire [9:0] SW;
	input wire [3:0] KEY;
	output wire [9:0] LEDR;
	output wire [nX-1:0] VGA_X;       // for DESim VGA
	output wire [nY-1:0] VGA_Y;       // for DESim VGA
	output wire [23:0] VGA_COLOR;     // for DESim VGA
	output wire plot;                 // for DESim VGA
    
	// maze signals
    wire [nX-1:0] maze_x;
    wire [nY-1:0] maze_y;
    wire [COLOR_DEPTH-1:0] maze_color;
    wire maze_write;

    // snake signals
    wire [nX-1:0] sn_x;
    wire [nY-1:0] sn_y;
    wire [COLOR_DEPTH-1:0] sn_color;
    wire sn_write;
    wire sn_req;                        // unused
    wire [4:0] new_col;
    wire [3:0] new_row;

    wire Resetn = KEY[0];
    wire done, draw_wall, snake_wall;
    wire [1:0] direction = SW[1:0];
    wire VGA_SYNC;      // 1 when background drawing is done

    // painter's lookup (its own cell: row = y[7:4], col = x[8:4])
    maze draw_lookup (maze_y[7:4], maze_x[8:4], draw_wall);
    maze_draw m1 (CLOCK_50, Resetn, VGA_SYNC, draw_wall, maze_x, maze_y, maze_color, maze_write, done);

    // snake's lookup (the cell it wants to enter)
    maze check (new_row, new_col, snake_wall);

    object snake (Resetn & VGA_SYNC & done, CLOCK_50, done, direction, snake_wall, new_col, new_row, sn_req, sn_x, sn_y, sn_color, sn_write);
        defparam snake.nX = nX;
        defparam snake.nY = nY;
        defparam snake.COLOR_DEPTH = COLOR_DEPTH;

    //draw maze until done, then snake
    wire [nX-1:0] MUX_x = done ? sn_x : maze_x;
    wire [nY-1:0] MUX_y = done ? sn_y : maze_y;
    wire [COLOR_DEPTH-1:0] MUX_color = done ? sn_color : maze_color;
    wire MUX_write = done ? sn_write : maze_write;

    // instantiate the DESim VGA adapter
    `define VGA_MEMORY
    vga_adapter VGA (
        .resetn(Resetn),
        .clock(CLOCK_50),
        .color(MUX_color),      
        .x(MUX_x),              
        .y(MUX_y),             
        .write(MUX_write),     
        .VGA_X(VGA_X),         
        .VGA_Y(VGA_Y),       
        .VGA_COLOR(VGA_COLOR), 
        .VGA_SYNC(VGA_SYNC),    
        .plot(plot));           // set to 1 to write a pixel color onto the VGA output
		defparam VGA.RESOLUTION = RESOLUTION;
		defparam VGA.COLOR_DEPTH = COLOR_DEPTH;

    assign LEDR[9] = VGA_SYNC;
    assign LEDR[1:0] = direction;

endmodule

//tells you if the maze is a 0 or 1 at this point
module maze(row, col, wall);

    input wire [3:0] row;
    input wire [4:0] col;
    output wire wall;

    reg [19:0] maze_row;

    always @(*) begin
    case (row)
        4'b0000: maze_row = 20'b11111_11111_11111_11111;
        4'b0001: maze_row = 20'b10000_00001_11111_00000;
        4'b0010: maze_row = 20'b10111_11101_11111_01111;
        4'b0011: maze_row = 20'b10100_00101_00000_01001;
        4'b0100: maze_row = 20'b11101_01101_01111_11011;
        4'b0101: maze_row = 20'b10001_01000_01000_00011;
        4'b0110: maze_row = 20'b10111_11101_11101_11111;
        4'b0111: maze_row = 20'b10000_00001_01001_00000;
        4'b1000: maze_row = 20'b11111_11011_01111_01111;
        4'b1001: maze_row = 20'b10000_01011_00000_01001;
        4'b1010: maze_row = 20'b10110_01011_11110_11011;
        4'b1011: maze_row = 20'b10111_01000_00010_00001;
        4'b1100: maze_row = 20'b10000_01111_10111_11101;
        4'b1101: maze_row = 20'b11111_00000_00000_00001;
        4'b1110: maze_row = 20'b11111_11111_11111_11111;
        default: maze_row = 20'b11111_11111_11111_11111;
    endcase
    end

    assign wall = maze_row[19-col];
endmodule

//scan for 0s and 1s and tell the vga adapter what to draw
module maze_draw(clock, resetn, start, wall, x, y, colour, write, done);
    input wire clock, resetn, start, wall;
    output reg [8:0] x;
    output reg [7:0] y;
    output reg done;
    output wire [8:0] colour;
    output wire write;

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

    assign colour = (wall) ? 9'b000_000_000: 9'b 111_111_111;
    assign write = start & ~done;

endmodule

// toggle flip-flop with reset
module ToggleFF(T, Resetn, Clock, Q);
    input wire T, Resetn, Clock;
    output reg Q;

    always @(posedge Clock)
        if (!Resetn)
            Q <= 'b0;
        else if (T)
            Q <= ~Q;
endmodule

// up/down counter with reset, enable, and load controls
module UpDn_count (R, Clock, Resetn, E, L, UpDn, Q);
    parameter n = 8;
    input wire [n-1:0] R;
    input wire Clock, Resetn, E, L, UpDn;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= 0;
        else if (L == 1)
            Q <= R;
        else if (E)
            if (UpDn == 1)
                Q <= Q + 1;
            else
                Q <= Q - 1;
endmodule

// counter
module Up_count (Clock, Resetn, Q);
    parameter n = 8;
    input wire Clock, Resetn;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= 'b0;
        else 
            Q <= Q + 1;
endmodule

// implements a moving colored object
module object (Resetn, Clock, gnt, direction, wall, new_col, new_row, req,  
               VGA_x, VGA_y, VGA_color, VGA_write);

    parameter nX = 9;
    parameter nY = 8;
    parameter COLOR_DEPTH = 9;

    parameter XDIM = 16, YDIM = 8; // object's width and height

    parameter COL_INIT = 5'b00001;
    parameter ROW_INIT = 4'b0001;

    parameter SNAKE_COLOR = 9'b000_111_000; //green
    parameter ALT = {COLOR_DEPTH{1'b1}}; //white

    parameter KK = 18; // controls animation speed (use 5 for ModelSim)

    // state codes
    parameter A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011,
              E = 4'b0100, F = 4'b0101, G = 4'b0110, H = 4'b0111,
              I = 4'b1000, J = 4'b1001, K = 4'b1010, L = 4'b1011;

    input wire Resetn, Clock;
    input wire gnt;                             // set to 1 when this object is selected for VGA display
    output reg req;                             // object sets this request to 1 when it wants to be displayed
	output wire [nX-1:0] VGA_x;                 // pixel x coordinate output
	output wire [nY-1:0] VGA_y;                 // pixel y coordinate ouput
	output wire [COLOR_DEPTH-1:0] VGA_color;    // pixel color output
    output wire VGA_write;                      // control output to write a pixel

    input wire [1:0] direction;
    input wire wall;
    output wire [4:0] new_col;
    output wire [3:0] new_row;

    wire [4:0] col;
    wire [3:0] row;

	wire [nX-1:0] XC;    // x offset
	wire [nY-1:0] YC;    // y offset
    wire [KK-1:0] slow;     // used to synchronize the object's speed using a counter
    reg Lpos, Ecol, Erow, Lxc, Lyc, Exc, Eyc, Ldir; //load and enable signals

    wire sync = &slow;
    reg erase;
    reg [3:0] y_Q, Y_D; // FSM for controlling drawing/erasing of the object
    reg write;          // used to write to a pixel

    parameter up = 2'b11, down = 2'b00, left = 2'b10, right = 2'b01;

    reg [1:0] dir;
    wire _right = (dir == right);
    wire _down = (dir == down);

    UpDn_count Ucol (COL_INIT, Clock, Resetn, Ecol, Lpos, _right, col);    // object's column location
        defparam Ucol.n = 5;

    UpDn_count Urow (ROW_INIT, Clock, Resetn, Erow, Lpos, _down, row);      // object's row location
        defparam Urow.n = 4;

    UpDn_count U3 ({nX{1'b0}}, Clock, Resetn, Exc, Lxc, 1'b1, XC); // object column counter
        defparam U3.n = nX;
    UpDn_count U4 ({nY{1'b0}}, Clock, Resetn, Eyc, Lyc, 1'b1, YC); // object row counter
        defparam U4.n = nY;

    Up_count U6 (Clock, Resetn, slow);  // counter to control the speed of moving
        defparam U6.n = KK;


    always @ (posedge Clock)
    begin
        if (Resetn == 1'b0)
            dir <= down;
        else if (Ldir && (dir != ~direction))
            dir <= direction;
    end

    assign new_col = (dir == right) ? col + 1'b1 : (dir == left) ? col - 1'b1 : col;
    assign new_row = (dir == down)  ? row + 1'b1 : (dir == up)   ? row - 1'b1 : row;

    //assign vga adapter parameters based on current values
    assign VGA_x = {col, 4'b0000} + XC;
    assign VGA_y = {row, 4'b0000} + YC;
    assign VGA_color = erase ? ALT : SNAKE_COLOR;
    assign VGA_write = write;

    // FSM Algorithm:
    // 1. draw object
    // 2. wait for object's delay time
    // 3. request to draw, wait for grant
    // 4. erase object, maintain request
    // 5. move object (check for boundary conditions), maintain request
    // 6. draw object, maintain request
    // 7. release request, goto 2.

    always @ (*)
        case (y_Q)
            A:  Y_D = B;                        // initialize counters, registers

            B:  if (XC != XDIM-1) Y_D = B;      // initial draw, done once
                else Y_D = C;
            C:  if (YC != YDIM-1) Y_D = B;
                else Y_D = D;

            D:  if (!sync) Y_D = D;             // wait for object's delay time
                else Y_D = E;
            E:  if (!gnt) Y_D = E;              // wait for VGA grant
                else Y_D = F;

            F:  if (XC != XDIM-1) Y_D = F;      // erase object
                else Y_D = G;
            G:  if (YC != YDIM-1) Y_D = F;
                else Y_D = H;

            H:  Y_D = I;                        // move the object
            I:  Y_D = J;

            J:  if (XC != XDIM-1) Y_D = J;      // draw the object
                else Y_D = K;
            K:  if (YC != YDIM-1) Y_D = J;
                else Y_D = L;
            L:  Y_D = D;
            default: Y_D = A;
        endcase

    always @ (*)
    begin
        Lpos = 1'b0; Ecol = 1'b0; Erow = 1'b0; Lxc = 1'b0; Lyc = 1'b0;
        Exc = 1'b0; Eyc = 1'b0; Ldir = 1'b0; erase = 1'b0; write = 1'b0; req = 1'b0;
        case (y_Q)
            A:  begin Lpos = 1'b1; Lxc = 1'b1; Lyc = 1'b1; end
            B:  begin Exc = 1'b1; write = 1'b1; end
            C:  begin Lxc = 1'b1; Eyc = 1'b1; end
            D:  Lyc = 1'b1;
            E:  req = 1'b1;
            F:  begin req = 1'b1; Exc = 1'b1; erase = 1'b1; write = 1'b1; end
            G:  begin req = 1'b1; Lxc = 1'b1; Eyc = 1'b1; end
            H:  begin req = 1'b1; Lyc = 1'b1; Ldir = 1'b1; end
            I:  begin
                    req = 1'b1;
                    if (!wall) begin
                        Ecol = (dir == left) || (dir == right);
                        Erow = (dir == up)   || (dir == down);
                    end
                end
            J:  begin req = 1'b1; Exc = 1'b1; write = 1'b1; end
            K:  begin req = 1'b1; Lxc = 1'b1; Eyc = 1'b1; end
            L:  Lyc = 1'b1;
        endcase
    end

    // FSM FFs 
    always @(posedge Clock)
        if (Resetn == 0)
            y_Q <= A;
        else
            y_Q <= Y_D;

endmodule
