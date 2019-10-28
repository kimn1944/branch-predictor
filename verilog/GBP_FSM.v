module GBP_FSM (
    // general inputs
    input CLK,
    input RESET,

    // update inputs
    input [11:0] Index,
    input Is_Taken,
    input Update,

    // outputs
    output reg preds [4095:0]
    );
    integer i;

    reg     A [4095:0];
    reg     B [4095:0];
    wire    Q;
    assign  Q     = Is_Taken;
    assign  preds = A;

    always @(posedge CLK or negedge RESET) begin
        if (!RESET) begin
            for(i = 0; i < 4096; i = i + 1) begin
                A[i] = 0;
                B[i] = 0;
            end
        end else if(Update) begin
            A[Index] <= A[Index]&B[Index] | A[Index]&Q | B[Index]&Q;
            B[Index] <= A[Index]&~B[Index] | A[Index]&Q | ~B[Index]&Q;
        end
        // $display("UPDATE = %x, TAKEN = %x", Update, Is_Taken);
        // $display("AB = %x%x", A[Index], B[Index]);
        // $display("PREDICTION = %x", preds[Index]);
    end

endmodule
