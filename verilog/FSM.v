module FSM (
    input CLK,
    input RESET,
    input isTaken,
    input isBranch,
    input [31:0] InstrPC,

    output reg Pred [1023:0]
);
    reg  A [1023:0];
    reg  B [1023:0];
    wire [9:0] index;
    assign index = InstrPC[11:2];

    integer i;
    always @(posedge CLK or negedge RESET) begin
        if(!RESET) begin
            for (i = 0; i < 1024; i = i + 1) begin
                A[i] = 0;
                B[i] = 0;
                Pred[i] = 0;
            end
        end else if (isBranch) begin
            A[index] <= A[index]&B[index] | A[index]&isTaken | B[index]&isTaken;
            B[index] <= A[index]&~B[index] | A[index]&isTaken | ~B[index]&isTaken;
            Pred[index] <= A[index]&B[index] | A[index]&isTaken | B[index]&isTaken;
        end
    end

    always begin
        // $display("isBranch = %x, isTaken = %x", isBranch, isTaken);
        // $display("AB = %x%x", A[index], B[index]);
        // $display("Pred = %x for %x", Pred[index], InstrPC);
    end
endmodule
