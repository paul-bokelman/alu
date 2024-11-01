module seven_seg_scanner(
    input div_clock,
    input reset,
    output [3:0] anode
);
    reg [1:0] count;
   
    always @ (posedge div_clock or posedge reset) begin
        if (reset) begin
            count <= 0;
        end
        else begin
           count <= count + 1;
        end
    end
    assign anode = ~(1 << count);
endmodule