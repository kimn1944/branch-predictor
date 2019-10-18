module BTB (
    input CLK,
    input RESET,
    input [31:0] InstructionAddress,

    output [31:0] PredictedInstructionAddress
);
    wire [1023:0] PREDICTION;
    wire [1023:0] UPDATE;
    wire [1023:0] TAKEN;

    wire [31:0] PIAP4;
    wire [8:0] index;
    wire [20:0] tag;
    wire lru;
    wire valid1;
    wire valid2;
    wire tag1;
    wire tag2;
    wire address1;
    wire address2;
    wire pred1;
    wire pred2;
    reg [106:0] cache [511:0];

    assign PIAP4 = InstructionAddress + 32'd4;
    assign index = InstructionAddress[10:2];
    assign tag = InstructionAddress[31:11];
    assign lru = cache[index][106];
    assign valid1 = cache[index][105];
    assign tag1 = cache[index][104:84];
    assign address1 = cache[index][83:54];
    assign pred1 = cache[index][53];
    assign valid2 = cache[index][52];
    assign tag2 = cache[index][51:31];
    assign address2 = cache[index][30:1];
    assign pred2 = cache[index][0];

    FSM counters[1023:0] (.CLK(CLK), .RESET(RESET), .UPDATE(UPDATE), .PREDICTION(PREDICTION));


    always begin
        PredictedInstructionAddress <= (tag1 == tag && valid1) ? (pred1 ? {address1, 2'b0} : PIAP4) : (tag2 == tag && valid2) ? (pred2 ? {address2, 2'b0} : PIAP4) : PIAP4;
        cache[index][106] <= (tag1 == tag && valid1) ? (0) : (tag2 == tag && valid2) ? (1) : lru;
    end

    always @posedge(negedge RESET) begin
        if(!RESET) begin
        
        end
    end
endmodule
