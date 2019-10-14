module FSM (
    input CLK,
    input RESET,
    input TAKEN,
    input UPDATE,

    output PREDICTION
);

    reg A;
    reg B;
    wire Q;
    assign Q = TAKEN;

    always @(posedge UPDATE or negedge RESET) begin
        if (!RESET) begin
            A <= 1;
            B <= 0;
        end
        // if (UPDATE) begin
        else begin
            A <= A&B | A&Q | B&Q;
            B <= A&~B | A&Q | ~B&Q;
        end
        // $display("UPDATE = %x, TAKEN = %x", UPDATE, TAKEN);
        // $display("AB = %x%x", A, B);
        // $display("PREDICTION = %x", PREDICTION);
    end

    assign PREDICTION = A;

endmodule
