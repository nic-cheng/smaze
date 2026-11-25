/* 
 * The code uses a "VGA adapter" to send pixel colors to the VGA window.
 *  The maze will be rendered onto the screen once compiled and ran. 
  * Make sure to set the resolution to 320x240.
*/
module vga_display(CLOCK_50, KEY, pos_list, spacebar, VGA_R, VGA_G, VGA_B,
                VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, game);

    input wire CLOCK_50;
    input wire [3:0] KEY;
    input wire [32:0] pos_list;
    input wire spacebar;            // active-high: 1 = pressed
    output wire [7:0] VGA_R;
    output wire [7:0] VGA_G;
    output wire [7:0] VGA_B;
    output wire VGA_HS;
    output wire VGA_VS;
    output wire VGA_BLANK_N;
    output wire VGA_SYNC_N;
    output wire VGA_CLK;
    output wire game; // 1 = game running

    wire resetn = KEY[0];

    wire [7:0] x;
    wire [6:0] y;
    wire [4:0] row;
    wire wall, write;

    maze_draw m1(CLOCK_50, resetn, x, y, row, wall, write);

    wire [39:0] start_data;
    starter b1(CLOCK_50, spacebar, resetn, row, game, start_data);

    wire lit = start_data[39 - x[7:2]];   // delayed x lines up with the ROM output

    wire snake;
    snake_draw s1(x, y, pos_list, snake);

    wire [8:0] final_color = ~game ? (lit ? 9'b101_000_111 : 9'b000_000_000) :
                             snake ? 9'b101_000_111 :
                             wall  ? 9'b000_000_000 : 9'b111_111_111;

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
        defparam VGA.RESOLUTION = "160x120";

endmodule

module starter(clock, space, resetn, row, y_Q, start_data);
    input clock, space, resetn;
    input [4:0] row;
    output reg y_Q;
    output [39:0] start_data;    // one row of the title screen

    wire y_D = space | y_Q;      // once set, stays set until reset

    always @ (posedge clock)
    begin
        if (resetn == 1'b0)
            y_Q <= 1'b0;
        else
            y_Q <= y_D;
    end

    start_rom rom1(clock, row, start_data);
endmodule

module start_rom(clock, address, Q);
    input wire clock;
    input wire [4:0] address;
    output reg [39:0] Q;

    (* ram_init_file = "start.mif" *) reg [39:0] memory [0:29];

    always @(posedge clock)
        Q <= memory[address];
endmodule

//create maze, tell the vga adapter what colour to draw at each pixel
module maze_draw(clock, resetn, x, y, row, wall, write);
    input wire clock, resetn;
    output reg [7:0] x;
    output reg [6:0] y;
    output wire [4:0] row;       // pre-delay row for the ROM addresses
    output wire wall;
    output reg write;

    reg [7:0] x_;
    reg [6:0] y_;

    assign row = y_[6:2];

    wire [39:0] row_data;
    maze_rom rom1(row, row_data);

    assign wall = row_data[39 - x[7:2]];

    always @ (posedge clock)
    begin
        if (resetn == 1'b0)
        begin
            x_ <= 8'b0;
            y_ <= 7'b0;
        end
        else if (x_ == 8'd159)
        begin
            x_ <= 8'b0;
            if (y_ == 7'd119)
                y_ <= 7'b0;
            else
                y_ <= y_ + 1'b1;
        end
        else
            x_ <= x_ + 1'b1;
    end

    always @(posedge clock)
    begin
        if (resetn == 1'b0)
        begin
            x <= 8'b0;
            y <= 7'b0;
            write <= 1'b0;
        end
        else
        begin
            x <= x_;
            y <= y_;
            write <= 1'b1;
        end
    end
endmodule

//loads the mif file
module maze_rom(address, Q);
    input wire [4:0] address;
    output wire [39:0] Q;

    (* ram_init_file = "maze1.mif" *) reg [39:0] memory [0:29];

    // initial $readmemb("maze1.txt", memory); // modelsim only

    assign Q = memory[address];
endmodule

//draw snake based on inputs
module snake_draw(x, y, pos_list, snake);
    input [7:0] x;
    input [6:0] y;
    input [32:0] pos_list; // [32:22] head, [21:11] mid, [10:0] tail, out of that - [10:5] x, [4:0] y
    output snake;

    wire [4:0] row = y[6:2];
    wire [5:0] col = x[7:2]; //drop bottom three bits to scale it
    wire [10:0] block = {col, row};

    assign snake = (block == pos_list[32:22]) | (block == pos_list[21:11]) | (block == pos_list[10:0]);

endmodule

//snake moving logic 
// module snake_move(clock, resetn, direction, tick, pos_list);
//     input clock, resetn;
//     input [1:0] direction;
//     input tick;
//     output [32:0] pos_list; // [32:22] head, [21:11] mid, [10:0] tail

//     reg [10:0] head, mid, tail; //each {x[5:0], y[4:0]}

//     always @ (posedge clock)
//     begin
//         if (resetn == 1'b0)
//         begin
//             head <= {6'd3, 5'd1};
//             mid  <= {6'd2, 5'd1};
//             tail <= {6'd1, 5'd1};
//         end
//         else if (tick == 1'b1)
//         begin
//             tail <= mid;
//             mid  <= head;
//             case (direction)
//                 2'b00: head <= {head[10:5] + 1'b1, head[4:0]}; //right
//                 2'b01: head <= {head[10:5] - 1'b1, head[4:0]}; //left
//                 2'b10: head <= {head[10:5], head[4:0] - 1'b1}; //up
//                 2'b11: head <= {head[10:5], head[4:0] + 1'b1}; //down
//             endcase
//         end
//     end

//     assign pos_list = {head, mid, tail};
// endmodule

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
