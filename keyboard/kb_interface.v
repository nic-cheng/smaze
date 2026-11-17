module kb_interface(CLOCK_50, reset, PS2_CLK, PS2_DAT, moving, direction);
    input wire CLOCK_50, reset;
    inout wire PS2_CLK, PS2_DAT;
    output reg moving; // should the snake move?
    output reg [1:0] direction; // up, left, down, right (WASD order)

    wire [7:0] received_data;
    wire received_data_en;

    PS2_Controller kb (
        .CLOCK_50                           (CLOCK_50),
        .reset                              (reset),
        .the_command                        (8'h00), // No commands            
        .send_command                       (1'b0),  // No commands
        .PS2_CLK                            (PS2_CLK),
        .PS2_DAT                            (PS2_DAT),
        .command_was_sent                   (),
        .error_communication_timed_out      (),
        .received_data                      (received_data),
        .received_data_en                   (received_data_en)
    );

    parameter [7:0] KEY_W=8'h1D, KEY_A=8'h1C, KEY_S=8'h1B, KEY_D=8'h23;

    always @(posedge CLOCK_50) begin
        if (reset) moving <= 1'b0; // stop
        else if (received_data_en) begin
            moving <= 1'b1; // go
            case (received_data)
                KEY_W: direction <= 2'd0;
                KEY_A: direction <= 2'd1;
                KEY_S: direction <= 2'd2;
                KEY_D: direction <= 2'd3;
                default: direction <= direction;
            endcase
        end
    end
endmodule
