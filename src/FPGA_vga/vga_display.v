/* 
 * The code uses a "VGA adapter" to send pixel colors to the VGA window.
 *  The maze will be rendered onto the screen once compiled and ran. 
  * Make sure to set the resolution to 320x240.
*/
module vga_display(CLOCK_50, SW, KEY, LEDR, HEX2, HEX1, HEX0, VGA_R, VGA_G, VGA_B,
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

    // wire start = KEY[1]; //replace with space
    // wire y_D, game;
    // begin b1(start, y_D, game);

    wire game = 1'b1;

    wire resetn = KEY[0];
    wire [8:0] x;
    wire [7:0] y;
    wire done;
    wire [8:0] color;
    wire write;

    maze_draw m1(CLOCK_50, resetn, game, x, y, color, write, done);

        wire [1:0] direction = SW[1:0];
    wire tick;
    wire [32:0] pos_list;

    clock_counter c1(CLOCK_50, resetn, tick);
    snake_move sm1(CLOCK_50, resetn, direction, tick, pos_list);
    
    wire snake;

    snake_draw s1(x, y, pos_list, snake);

    wire [8:0] final_color = snake ? 9'b111_101_110 : color;

    vga_adapter VGA (
        .resetn(KEY[0]),
        .clock(CLOCK_50),
        .color(final_color),
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

// module begin(start, y_D, game);
//     input start; //replace with space
//     reg y_D;
//     output reg game;

//     always @(*)
//     case (start)
//         default: y_D = 1'b0;
//         1'b0: y_D = 1'b0;
//         1'b1: y_D = 1'b1;
//     endcase

//     always @ (posedge CLOCK_50)

//     wire [4:0] row = y_[7:3];
//     wire [5:0] col = x_[8:3]; //drop bottom three bits to scale it

//     wire [39:0] row_data;

//     start_rom rom1(CLOCK_50, row, row_data);
// endmodule

// module start_rom(clock, address, Q);
//     input wire clock;
//     input wire [4:0] address;
//     output reg [39:0] Q;

//     (* ram_init_file = "start.mif" *) reg [39:0] memory [0:29];

//     always @(posedge clock)
//         Q <= memory[address];
// endmodule

//create maze, tell the vga adapter what colour to draw at each pixel
module maze_draw(clock, resetn, start, x, y, color, write, done);
    input wire clock, resetn, start;
    output reg [8:0] x;
    output reg [7:0] y;
    output reg done;
    output wire [8:0] color;
    output reg write;

    // pixel counters (run ahead of the actual outputs by one clock)
    reg [8:0] x_;
    reg [7:0] y_;

    wire [4:0] row = y_[7:3];
    wire [5:0] col = x_[8:3]; //drop bottom three bits to scale it

    wire [39:0] row_data;
    maze_rom rom1(clock, row, row_data);   // address is just the row

    wire wall = row_data[39 - x[8:3]];     // leftmost character in the mif = column 0

    //move forward each pixel
    always @ (posedge clock)
    begin
        if (resetn == 1'b0)
        begin
            x_ <= 9'b0;
            y_ <= 8'b0;
            done <= 1'b0;
        end
        else if (start & ~done)
        begin
            if (x_ == 9'd319)
            begin
                if (y_ == 8'd239)
                begin
                    //change for milestone 2 - restart drawing to update
                    x_ <= 9'b0;
                    y_ <= 8'b0;
                end
                else
                begin
                    x_ <= 9'b0;
                    y_ <= y_ + 1'b1;
                end
            end
            else
                x_ <= x_ + 1'b1;
        end
    end

    always @(posedge clock)
    begin
        if (resetn == 1'b0)
        begin
            x <= 9'b0;
            y <= 8'b0;
            write <= 1'b0;
        end
        else
        begin
            x <= x_;
            y <= y_;
            write <= start & ~done;
        end
    end

    assign color = (wall) ? 9'b000_000_000: 9'b 111_111_111;

endmodule

//loads the mif file
module maze_rom(clock, address, Q);
    input wire clock;
    input wire [4:0] address;
    output reg [39:0] Q;

    (* ram_init_file = "maze1.mif" *) reg [39:0] memory [0:29];

    // initial $readmemb("maze1.txt", memory); // modelsim only

    always @(posedge clock)
        Q <= memory[address];
endmodule

//draw snake based on inputs
module snake_draw(x, y, pos_list, snake);
    input [8:0] x;
    input [7:0] y;
    input [32:0] pos_list; // [32:22] head, [21:11] mid, [10:0] tail, out of that - [10:5] x, [4:0] y
    output snake;

    wire [4:0] row = y[7:3];
    wire [5:0] col = x[8:3]; //drop bottom three bits to scale it
    wire [10:0] block = {col, row};

    assign snake = (block == pos_list[32:22]) | (block == pos_list[21:11]) | (block == pos_list[10:0]);

endmodule

//snake moving logic 
module snake_move(clock, resetn, direction, tick, pos_list);
    input clock, resetn;
    input [1:0] direction;
    input tick;
    output [32:0] pos_list; // [32:22] head, [21:11] mid, [10:0] tail

    reg [10:0] head, mid, tail; //each {x[5:0], y[4:0]}

    always @ (posedge clock)
    begin
        if (resetn == 1'b0)
        begin
            head <= {6'd3, 5'd1};
            mid  <= {6'd2, 5'd1};
            tail <= {6'd1, 5'd1};
        end
        else if (tick == 1'b1)
        begin
            tail <= mid;
            mid  <= head;
            case (direction)
                2'b00: head <= {head[10:5] + 1'b1, head[4:0]}; //right
                2'b01: head <= {head[10:5] - 1'b1, head[4:0]}; //left
                2'b10: head <= {head[10:5], head[4:0] - 1'b1}; //up
                2'b11: head <= {head[10:5], head[4:0] + 1'b1}; //down
            endcase
        end
    end

    assign pos_list = {head, mid, tail};
endmodule

module clock_counter(Clk, resetn, tick); //big counter

    input Clk, resetn;
    reg [23:0] Q; //24 bits fits 10,000,000
    output reg tick;

    always @ (*)
    begin
        if (Q == 24'd9_999_999)
            tick = 1'b1;
        else
            tick = 1'b0;
    end

    always @ (posedge Clk)
    begin
        if (resetn == 1'b0 || tick)
            Q <= 24'b0;
        else
            Q <= Q + 1'b1;
    end

endmodule
