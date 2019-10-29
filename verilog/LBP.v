module LBP (
    // general inputs
    input CLK,
    input RESET,

    // IF inputs
    input [31:0] IF_PC,

    // ID inputs
    input [31:0] ID_PC,
    input Is_Branch,
    input Is_Taken,

    // outputs
    output reg pred
    );

    reg   [9:0] branch_history [1023:0];
    wire  [9:0] history;
    wire  [9:0] IF_index;
    wire  [9:0] ID_index;

    assign IF_index = IF_PC[11:2];
    assign ID_index = ID_PC[11:2];
    assign history  = branch_history[IF_index];

    wire preds [1023:0];

    FSM FSM(
        .CLK(CLK),
        .RESET(RESET),
        .isTaken(Is_Taken),
        .isBranch(Is_Branch),
        .InstrPC({20'd0, branch_history[ID_index], 2'd0}),
        .Pred(preds)
        );

    integer i;
    always @(posedge CLK or negedge RESET) begin
        if(!RESET) begin
            for(i = 0; i < 1024; i = i + 1) begin
                branch_history[i] = 0;
            end
            pred <= 0;
        end else begin
            pred                      <= preds[history];
            branch_history[ID_index]  <= Is_Branch ? {Is_Taken, branch_history[ID_index][9:1]} : branch_history[ID_index];
        end
        $display("History: %x%x%x%x%x%x%x%x%x%x", history[0], history[1], history[2], history[3], history[4], history[5], history[6], history[7], history[8], history[9]);
        $display("Prediction: %x", preds[history]);
    end

endmodule
