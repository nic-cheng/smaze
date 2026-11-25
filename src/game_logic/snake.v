// pos 40 x 30
// 6 bit x 5 bit
module snake (clock, resetn, move_enable, enable, start_pos, start_dir, kb_dir,
              maze_row, maze_address, pos_list, snake_dir);
    input wire clock, resetn, move_enable, enable;
    input wire [32:0] start_pos;
    input wire [1:0] start_dir, kb_dir;
    input wire [39:0] maze_row;
    output wire [4:0] maze_address;
    output reg [32:0] pos_list; // [32:22] head, [21:11] mid, [10:0] tail
    output reg [1:0] snake_dir;

    wire [10:0] head_pos = pos_list[32:22];
    wire [5:0] head_x = head_pos[10:5];
    wire [4:0] head_y = head_pos[4:0];

    parameter D_UP = 2'd0, D_LEFT = 2'd1, D_DOWN = 2'd2, D_RIGHT = 2'd3;

    // Movement vectors
    reg [10:0] next_pos;  // [10:5] x, [4:0] y

    // Out of bounds handled by walls
    always @(*) begin
        case (kb_dir)
            D_UP:       next_pos = {head_x       , head_y + 5'b1};
            D_LEFT:     next_pos = {head_x - 6'b1, head_y       };
            D_DOWN:     next_pos = {head_x       , head_y - 5'b1};
            D_RIGHT:    next_pos = {head_x + 6'b1, head_y       };
            default:    next_pos = head_pos; // Shouldn't be possible
        endcase
    end
    
    // Instantiate maze and check for walls
    wire [5:0] next_x = next_pos[10:5];
    assign maze_address = next_pos[4:0];
    wire can_move = !maze_row[39 - next_x];

    // Shift if enabled and not running into a wall
    always @(posedge clock) begin
        if (!resetn) begin
            pos_list <= start_pos;
            snake_dir <= start_dir;
        end
        else if (move_enable && enable && can_move) begin
            pos_list <= {next_pos, pos_list[32:11]};
            snake_dir <= kb_dir;
        end
    end
endmodule
