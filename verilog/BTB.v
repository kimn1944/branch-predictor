module BTB (
    input CLK,
    input RESET


);
    wire [1023:0] PREDICTION;

    FSM counters[1023:0] (.CLK(CLK), .RESET(RESET), .UPDATE(UPDATE), .PREDICTION(PREDICTION));

endmodule
