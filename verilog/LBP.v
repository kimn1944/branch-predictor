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

    // TODO FSM

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
    end

endmodule
