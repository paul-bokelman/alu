module dlatch(
    input D,
    input reset,
    input enabled,
    output reg Q,
    output NotQ
);
    assign NotQ = ~Q;

    always @(*) begin
        // Reset -> set value to 0
        if (reset) begin
            Q <= 0;
        // When enabled -> assign Q to D
        end else if (enabled) begin
            Q <= D;
        end
        // When not enabled, Q retains its value
    end
endmodule

