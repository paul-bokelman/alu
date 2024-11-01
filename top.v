module top
#(
    parameter DIVIDE_BY = 17 // nerf the fucker
)
(
    input [15:0] sw, 
    output [15:0] led
    input btnC, // send operation (rising clock edge)
    input btnU, // reset button
    input clk, // 100 MHz board clock
    output [3:0] an, // 7seg anodes
    output [6:0] seg // 7seg segments
);
    `include "operations.v"

    reg[7:0] Y;
    wire div_clock;

    clock_div #(.DIVIDE_BY(DIVIDE_BY)) cd(
        .clock(clk),
        .reset(btnU),
        .div_clock(div_clock)
    );

    // assign inputs to memory values
    reg [7:0] memories[1:0];

    // initialize registers
    registers regs(
        .data(sw[15:8]),
        .store(0),
        .address(sw),
        .memories(memories)
    );
    
    // define register memories for better readability
    `define A memories[0];
    `define B memories[1];

    // reset all values
    always @(posedge clk, posedge btnU) begin
        load(1'b0, 8'b00000000, memories); // reset a
        load(1'b1, 8'b00000000, memories); // reset b
        Y = 8'b00000000; // reset Y
    end

    // multiplexer to handle operation code
    always @(posedge clk, posedge btnC) begin
        case (sw[3:0]) // case on op code
            4'b0000: add(A, B, Y); // add
            4'b0001: subtract(A, B, Y); // subtract
            4'b0010: Y <= A<<1; // shift l
            4'b0011: Y <= A>>1; // shift r
            4'b0100: Y <= A; // compare
            4'b0101: Y <= A&B; // AND
            4'b0110: Y <= A|B; // OR
            4'b0111: Y <= A^B; // XOR
            4'b1000: Y <= ~(A & B); // NAND
            4'b1001: Y <= ~(A | B); // NOR
            4'b1010: Y <= ~(A ^ B); // XNOR
            4'b1011: Y <= ~A; // NOT
            4'b1100: Y <= -A; // Twos complement
            4'b1101: load(1'b0, Y, memories); // Store Y in A
            4'b1110: swap(1'b0, 1'b1, memories); // Swap A/B 
            4'b1111: load(1'b0, sw[15:8], memories); // Store data in A 
        endcase
    end

    // display operation and 8bit output (Y) on display
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