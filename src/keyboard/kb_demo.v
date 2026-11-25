module kb_demo(CLOCK_50, KEY, PS2_CLK, PS2_DAT, LEDR);
    input wire CLOCK_50;
    input wire [0:0] KEY;
    inout wire PS2_CLK, PS2_DAT;
    output wire [9:0] LEDR; // moving, W, A, S, D
    
    
    wire resetn = KEY[0];

    wire [1:0] direction;
    wire moving, spacebar;

    kb_interface kbi (
        .CLOCK_50   (CLOCK_50),
        .resetn     (resetn),
        .PS2_CLK    (PS2_CLK),
        .PS2_DAT    (PS2_DAT),
        .moving     (moving),
        .direction  (direction),
        .spacebar   (spacebar)
    );

    assign LEDR = {4'b1000, spacebar, moving, 4'b0001 << direction};
endmodule
