// pos 40 x 30
// 6 bit x 5 bit
module snake (game_clk, resetn, enable, start_pos, direction, pos_list);
    input wire game_clk, resetn, enable;
    input wire [32:0] start_pos;
    input wire [1:0] direction;
    output reg [32:0] pos_list; // [32:22] head, [21:11] mid, [10:0] tail

    wire [10:0] head_pos = pos_list[32:22];
    wire [5:0] head_x = head_pos[10:5];
    wire [4:0] head_y = head_pos[4:0];

    parameter D_UP = 2'd0, D_LEFT = 2'd1, D_DOWN = 2'd2, D_RIGHT = 2'd3;

    // Movement vectors
    reg [10:0] next_pos;  // [10:5] x, [4:0] y

    // Out of bounds handled by walls
    always @(*) begin
        case (direction)
            D_UP:       next_pos = {head_x       , head_y - 5'b1}; // Assuming it's like array math in C, check VGA implem
            D_LEFT:     next_pos = {head_x - 6'b1, head_y       };
            D_DOWN:     next_pos = {head_x       , head_y + 5'b1};
            D_RIGHT:    next_pos = {head_x + 6'b1, head_y       };
            default:    next_pos = head_pos; // Shouldn't be possible
        endcase
    end
    
    // Instantiate maze and check for walls
    wire [5:0] next_x = next_pos[10:5];
    wire [4:0] next_y = next_pos[4:0];
    wire wall;
    maze m (next_pos[10:5], next_pos[4:0], wall);
    wire can_move = !wall;

    // Shift if enabled and not running into a wall
    always @(posedge game_clk) begin
        if (!resetn) pos_list <= start_pos;
        else if (enable && can_move) pos_list <= {next_pos, pos_list[32:11]};
    end
endmodule
