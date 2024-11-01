module top
#(
    parameter DIVIDE_BY = 17 // Clock division factor
)
(
    input [15:0] sw, // Switch inputs
    output [15:0] led, // LED outputs
    input btnC, // Operation button (rising clock edge)
    input btnU, // Reset button
    input clk, // 100 MHz board clock
    output [3:0] an, // 7-segment display anodes
    output [6:0] seg // 7-segment display segments
);

    `include "operations.v"

    // Register to hold the result of operations
    reg [7:0] Y;

    // Wire for the divided clock signal
    wire div_clock;

    // Clock divider instance
    clock_div #(.DIVIDE_BY(DIVIDE_BY)) cd(
        .clock(clk),
        .reset(btnU),
        .div_clock(div_clock)
    );

    // Register memories
    reg [7:0] memories[1:0];

    // Initialize registers
    registers regs(
        .data(sw[15:8]),
        .store(0),
        .address(sw[0]),
        .memories(memories)
    );

    // Define register memories for better readability
    `define A memories[0]
    `define B memories[1]

    // Reset all values on reset button press
    always @(posedge clk, posedge btnU) begin
        load(1'b0, 8'b00000000, memories); // Reset A
        load(1'b1, 8'b00000000, memories); // Reset B
        Y = 8'b00000000; // Reset Y
    end

    // Multiplexer to handle operation code
    always @(posedge clk, posedge btnC) begin
        case (sw[3:0]) // Case on operation code
            4'b0000: add(A, B, Y); // Add
            4'b0001: subtract(A, B, Y); // Subtract
            4'b0010: Y <= A << 1; // Shift left
            4'b0011: Y <= A >> 1; // Shift right
            4'b0100: Y <= A; // Compare
            4'b0101: Y <= A & B; // AND
            4'b0110: Y <= A | B; // OR
            4'b0111: Y <= A ^ B; // XOR
            4'b1000: Y <= ~(A & B); // NAND
            4'b1001: Y <= ~(A | B); // NOR
            4'b1010: Y <= ~(A ^ B); // XNOR
            4'b1011: Y <= ~A; // NOT
            4'b1100: Y <= -A; // Two's complement
            4'b1101: load(1'b0, Y, memories); // Store Y in A
            4'b1110: swap(1'b0, 1'b1, memories); // Swap A/B
            4'b1111: load(1'b0, sw[15:8], memories); // Store data in A
        endcase
    end

    // Display operation and 8-bit output (Y) on 7-segment display
    seven_seg_scanner sss(
        .div_clock(div_clock),
        .reset(btnC),
        .anode(an)
    );

    seven_seg_decoder ssd(
        .opCode(sw[3:0]),
        .lowerBits(Y[3:0]),
        .upperBits(Y[7:4]),
        .segs(seg),
        .anode(an)
    );

endmodule