module BTB (
    // general inputs
    input CLK,
    input RESET,
    input STALL,

    // IF inputs
    input [31:0] Instr_PC_IN_IF,

    // ID inputs
    input [31:0] Instr_PC_IN_ID,
    input is_Branch_IN_ID,
    input is_Taken_IN_ID,
    input [31:0] Alt_PC_IN_ID,

    // outputs
    output reg FLUSH,
    output reg take_Branch_OUT_IF,
    output reg [31:0] take_Alt_PC_OUT_IF
);
    // cache structure
    reg [108:0] cache [511:0];
    // predictor structure, connecting the updowncounters to get predictions
    wire [1023:0] pred;
    FSM FSM (
        .CLK(CLK),
        .RESET(RESET),
        .isTaken(is_Taken_IN_ID),
        .isBranch(is_Branch_IN_ID),
        .InstrPC(Instr_PC_IN_ID),

        .Pred(pred)
    );

    // IF wiring
    // getting the index, tag and prediction index from IF instr and
    // indexing into the cache with this info
    wire [8:0] index_IF;                // index from the IF
    wire [20:0] tag_IF;                 // tag from the IF
    wire [9:0] pred_index_IF;                 // index from IF to FSM
    assign index_IF = Instr_PC_IN_IF[10:2];
    assign tag_IF = Instr_PC_IN_IF[31:11];
    assign pred_index_IF = Instr_PC_IN_IF[11:2];
    // getting info from cache using the IF instruction
    wire pred_IF;
    wire valid1_IF;
    wire [20:0] tag1_IF;
    wire [31:0] address1_IF;
    wire valid2_IF;
    wire [20:0] tag2_IF;
    wire [31:0] address2_IF;
    assign pred_IF = pred[pred_index_IF];
    assign valid1_IF = cache[index_IF][107];
    assign tag1_IF = cache[index_IF][106:86];
    assign address1_IF = cache[index_IF][85:54];
    assign valid2_IF = cache[index_IF][53];
    assign tag2_IF = cache[index_IF][52:32];
    assign address2_IF = cache[index_IF][31:0];
    // IF wiring for prediction
    wire [31:0] new_pred_inst_IF;
    wire tag1_IF_match;
    wire tag2_IF_match;
    wire [31:0] Instr_PC_IN_IF_Plus4;
    wire take_IF;
    assign tag1_IF_match = (tag1_IF == tag_IF) && valid1_IF;
    assign tag2_IF_match = (tag2_IF == tag_IF) && valid2_IF;
    assign Instr_PC_IN_IF_Plus4 = Instr_PC_IN_IF + 32'd4;
    assign take_IF = pred_IF && (tag1_IF_match || tag2_IF_match);
    assign new_pred_inst_IF = take_IF ? (tag1_IF_match ? address1_IF : address2_IF) : Instr_PC_IN_IF_Plus4;

    //
    reg [6:0] past_decisions;
    wire past_pred;
    wire mispred;
    assign past_pred = past_decisions[0];
    assign mispred = is_Branch_IN_ID ? ((past_pred == is_Taken_IN_ID) ? 0 : 1) : 0;


    // ID wiring
    // getting the index, tag and prediction index from ID instr and
    // indexing into the cache with this info
    wire [8:0] index_ID;                // index from the ID
    wire [20:0] tag_ID;                 // tag from the ID
    wire [9:0] pred_index_ID;
    assign index_ID = Instr_PC_IN_ID[10:2];
    assign tag_ID = Instr_PC_IN_ID[31:11];
    assign pred_index_ID = Instr_PC_IN_ID[11:2];
    // getting the info from cache using the ID instruction
    wire last_recently_used;
    wire valid1_ID;
    wire [20:0] tag1_ID;
    wire [31:0] address1_ID;
    wire valid2_ID;
    wire [20:0] tag2_ID;
    wire [31:0] address2_ID;
    assign last_recently_used = cache[index_ID][108];
    assign valid1_ID = cache[index_ID][107];
    assign tag1_ID = cache[index_ID][106:86];
    assign address1_ID = cache[index_ID][85:54];
    assign valid2_ID = cache[index_ID][53];
    assign tag2_ID = cache[index_ID][52:32];
    assign address2_ID = cache[index_ID][31:0];
    // updating stuff for ID
    wire tag1_ID_match;
    wire tag2_ID_match;
    assign tag1_ID_match = (tag1_ID == tag_ID) && valid1_ID;
    assign tag2_ID_match = (tag2_ID == tag_ID) && valid2_ID;
    //

    always @(posedge is_Taken_IN_ID) begin
        if(is_Branch_IN_ID) begin
            if(!tag1_ID_match && !tag2_ID_match) begin
                cache[index_ID][107:54] <= last_recently_used ? {1'b1, tag_ID, Alt_PC_IN_ID} : cache[index_ID][107:54];
                cache[index_ID][53:0] <= last_recently_used ? cache[index_ID][53:0] : {1'b1, tag_ID, Alt_PC_IN_ID};
                cache[index_ID][108] <= ~last_recently_used;
            end
        end
    end

    integer i;
    always @(posedge CLK or negedge RESET) begin
        if(!RESET) begin
            FLUSH <= 0;
            take_Branch_OUT_IF <= 0;
            take_Alt_PC_OUT_IF <= 0;
            past_decisions[6:0] <= 7'b0;
            for(i = 0; i < 512; i = i + 1) begin
                cache[i][107] = 0;
                cache[i][53] = 0;
            end
        end else begin
            cache[index_IF][108] <= (take_IF && ~mispred) ? (tag1_IF_match ? 0 : 1) : (cache[index_IF][108]);
            past_decisions[6:0] <= mispred ? {6'b0, past_decisions[0]} : ({take_IF, past_decisions[6:1]});
            FLUSH <= mispred;
            take_Branch_OUT_IF <= take_IF || mispred;
            take_Alt_PC_OUT_IF <= mispred ? (is_Taken_IN_ID ? Alt_PC_IN_ID : Instr_PC_IN_ID + 32'd8) : new_pred_inst_IF;
        end
    end
endmodule
