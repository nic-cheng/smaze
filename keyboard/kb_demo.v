module kb_demo(CLOCK_50, reset, PS2_CLK, PS2_DAT, LEDR);
    input wire CLOCK_50, reset;
    inout wire PS2_CLK, PS2_DAT;
    output wire [4:0] LEDR; // moving, W, A, S, D

    reg [1:0] direction;

    kb_interface kbi (
        .CLOCK_50   (CLOCK_50),
        .reset      (reset),
        .PS2_CLK    (PS2_CLK),
        .PS2_DAT    (PS2_DAT),
        .moving     (LEDR[4]),
        .direction  (direction)
    );

    assign LEDR[3:0] = 4'b0001 << direction;
endmodule
