module FSM (
    input CLK,
    input RESET,
    input isTaken,
    input isBranch,
    input [31:0] InstrPC,

    output reg [1023:0] Pred
);
    reg [1023:0] A;
    reg [1023:0] B;
    wire [9:0] index;
    assign index = InstrPC[11:2];

    integer i;
    always @(posedge isBranch or negedge RESET) begin
        if(!RESET) begin
            for (i = 0; i < 1024; i = i + 1) begin
                A[i] <= 0;
                B[i] <= 0;
                Pred[i] <= 1;
            end
        end else begin
            A[index] <= A[index]&B[index] | A[index]&isTaken | B[index]&isTaken;
            B[index] <= A[index]&~B[index] | A[index]&isTaken | ~B[index]&isTaken;
            Pred[index] <= A[index]&B[index] | A[index]&isTaken | B[index]&isTaken;
        end
    end

    always begin
        $display("isBranch = %x, isTaken = %x", isBranch, isTaken);
        $display("AB = %x%x", A[index], B[index]);
        $display("Pred = %x for %x", Pred[index], InstrPC);
    end
endmodule
