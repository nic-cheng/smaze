module kb_demo(CLOCK_50, KEY, PS2_CLK, PS2_DAT, LEDR);
    input wire CLOCK_50;
    input wire [0:0] KEY;
    inout wire PS2_CLK, PS2_DAT;
    output wire [9:0] LEDR; // moving, W, A, S, D
    
    assign LEDR[9:5] = 5'b10000;
    wire resetn = KEY[0];

    wire [1:0] direction;
    wire moving;

    kb_interface kbi (
        .CLOCK_50   (CLOCK_50),
        .resetn     (resetn),
        .PS2_CLK    (PS2_CLK),
        .PS2_DAT    (PS2_DAT),
        .moving     (moving),
        .direction  (direction)
    );

    assign LEDR[4] = moving; 

    assign LEDR[3:0] = 4'b0001 << direction;
endmodule
