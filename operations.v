// load a given value into a register given its address
task load (input [0:0] address, input [7:0] V, output [7:0] memories[1:0]); // Use [0:0] for single-bit address
    begin
        registers regs(
            .data(V),
            .store(1),
            .address(address),
            .memories(memories)
        );
    end
endtask
// swap memories of given register addresses
task swap(input [0:0] a1, input [0:0] a2, output [7:0] memories[1:0]); 
    reg [7:0] tempMemories[1:0]; // declare temporary memory array
    begin
        // load the current values into the tempMemories
        tempMemories[0] = memories[a1]; 
        tempMemories[1] = memories[a2]; 
        // swap values between the addresses
        load(a1, tempMemories[1], memories); // load the value from tempMemories[1] into memories[a1]
        load(a2, tempMemories[0], memories); // load the value from tempMemories[0] into memories[a2]
    end
endtask
// assign y with sum of values
task add (input [7:0] A, B, output [7:0] Y); // Output should not be reg
    wire [7:0] carry;
    begin
        genvar i;
        generate 
            for (i = 0; i < 8; i = i + 1) begin 
                full_adder add(
                    .A(A[i]),
                    .B(B[i]),
                    .Cin((i == 0) ? 0 : carry[i-1]),
                    .Y(Y[i]),
                    .Cout(carry[i])
                );
            end
        endgenerate
    end
endtask
// assign y with difference of values
task subtract (input [7:0] A, B, output [7:0] Y); // Output should not be reg
    begin
        add(A, -B, Y); // use add module with twos complement of B
    end
endtask