module kb_interface(CLOCK_50, resetn, PS2_CLK, PS2_DAT, snake_dir, moving, kb_dir, spacebar);
    input wire CLOCK_50, resetn;
    inout wire PS2_CLK, PS2_DAT;
    input wire [1:0] snake_dir; // the snake's actual movement direction from snake module
    output reg moving; // should the snake move?
    output reg [1:0] kb_dir; // up, left, down, right (WASD order)
    output reg spacebar; // One CLOCK_50 tick pulse when spacebar is pressed (ignores release)

    wire [7:0] received_data;
    wire received_data_en;
    reg  break_code_received;

    PS2_Controller kb (
        .CLOCK_50                           (CLOCK_50),
        .reset                              (~resetn),
        .the_command                        (8'h00), // No commands            
        .send_command                       (1'b0),  // No commands
        .PS2_CLK                            (PS2_CLK),
        .PS2_DAT                            (PS2_DAT),
        .command_was_sent                   (),
        .error_communication_timed_out      (),
        .received_data                      (received_data),
        .received_data_en                   (received_data_en)
    );

    parameter [7:0] BREAK = 8'hF0, KEY_W = 8'h1D, KEY_A = 8'h1C, KEY_S = 8'h1B, KEY_D = 8'h23, KEY_SPACE = 8'h29;
    parameter [1:0] D_UP = 2'd0, D_LEFT = 2'd1, D_DOWN = 2'd2, D_RIGHT = 2'd3;

    always @(posedge CLOCK_50) begin
        spacebar <= 1'b0;
        if (!resetn) begin
            moving <= 1'b0; // stop
            kb_dir <= 2'd0;
            break_code_received <= 1'b0;
        end
        else if (received_data_en) begin
            if (received_data == BREAK) break_code_received <= 1;
            else begin
                if (!break_code_received) begin
                    if (received_data == KEY_W || received_data == KEY_A ||
                        received_data == KEY_S || received_data == KEY_D)
                        moving <= 1'b1;
                    case (received_data)
                        KEY_W: if (snake_dir != D_DOWN)  kb_dir <= 2'd0;
                        KEY_A: if (snake_dir != D_RIGHT) kb_dir <= 2'd1;
                        KEY_S: if (snake_dir != D_UP)    kb_dir <= 2'd2;
                        KEY_D: if (snake_dir != D_LEFT)  kb_dir <= 2'd3;
                        KEY_SPACE: begin
                            spacebar <= 1'b1;
                            moving <= 1'b0;
                        end
                        default: ;
                    endcase
                end
                break_code_received <= 1'b0;
            end
        end
    end
endmodule
