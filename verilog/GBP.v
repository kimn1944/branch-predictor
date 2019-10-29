module GBP(
    // general inputs
    input CLK,
    input RESET,

    // ID inputs
    input Is_Branch,
    input Is_Taken,

    // outputs
    output reg pred
    );

    // history register
    reg [11:0]  history;
    wire        preds [4095:0];

    // FSM object
    GBP_FSM GBP_FMS(
        .CLK(CLK),
        .RESET(RESET),
        .Index(past_history),
        .Is_Taken(Is_Taken),
        .Update(Is_Branch),
        .preds(preds)
        );

    reg   [11:0]  past_histories [6:0];
    wire  [11:0]  past_history;

    assign past_history = past_histories[0];
    assign pred         = preds[history];
    integer i;

    // always @* begin
    //     pred <= preds[history];
    // end

    always @(posedge CLK or negedge RESET) begin
        if(!RESET) begin
            for(i = 0; i < 7; i = i + 1) begin
                past_histories[i] = 0;
            end
            history <= 0;
        end else begin
            past_histories[6]   <= history;
            past_histories[5:0] <= past_histories[6:1];
            history             <= Is_Branch ? {Is_Taken, history[11:1]} : history;
            // pred                <= preds[history];
        end
        // $display("GBP Prediction: %x", pred);
        // $display("GBP History: %b", history);
    end

endmodule
