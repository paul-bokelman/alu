module registers
#(
    parameter REGISTERS_COUNT = 2
)
(
    input [7:0] data,
    input store,
    input [$clog2(REGISTERS_COUNT)-1:0] address, // addresses
    output [7:0] memories[REGISTERS_COUNT-1:0] // store memory
);
    reg [1:0] stores;
    
    // assign store bits (one-hot)
    always @(*) begin
        stores = {REGISTERS_COUNT{1'b0}}; // reset all bits
        stores[address] = store; // update address with store value
    end
    // generate required registers
    genvar i;
    generate 
        for (i = 0; i < REGISTERS_COUNT; i = i + 1) begin : gen_regs
            register r (
                .data(data),
                .store(stores[i]),
                .memory(memories[i])
            );
        end
    endgenerate
endmodule