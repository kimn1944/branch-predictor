module BTB (
    // general inputs
    input CLK,
    input RESET,

    // IF inputs
    input [31:0] Instr_PC_IN_IF,

    // ID inputs
    input [31:0] Instr_PC_IN_ID,
    input is_Branch_IN_ID,
    input is_Taken_IN_ID,
    input [31:0] Alt_PC_IN_ID,

    // outputs
    output FLUSH,
    output reg take_Branch_OUT_IF,
    output reg [31:0] take_Alt_PC_OUT_IF
);
    // cache structure
    reg [106:0] cache[511:0];
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
    wire valid1_IF;
    wire [20:0] tag1_IF;
    wire [29:0] address1_IF;
    wire pred1_IF;
    wire valid2_IF;
    wire [20:0] tag2_IF;
    wire [29:0] address2_IF;
    wire pred2_IF;
    assign valid1_IF = cache[index_IF][105];
    assign tag1_IF = cache[index_IF][104:84];
    assign address1_IF = cache[index_IF][83:54];
    assign pred1_IF = pred[pred_index_IF];          // cache[index_IF][53];
    assign valid2_IF = cache[index_IF][52];
    assign tag2_IF = cache[index_IF][51:31];
    assign address2_IF = cache[index_IF][30:1];
    assign pred2_IF = pred[pred_index_IF];          // cache[index_IF][0];
    // IF wiring for prediction
    wire [31:0] new_pred_inst_IF;
    wire tag1_IF_match;
    wire tag2_IF_match;
    wire [31:0] Instr_PC_IN_IF_Plus4;
    assign tag1_IF_match = (tag1_IF == tag_IF) && valid1_IF;
    assign tag2_IF_match = (tag2_IF == tag_IF) && valid2_IF;
    assign Instr_PC_IN_IF_Plus4 = Instr_PC_IN_IF+ 32'd4;
    assign new_pred_inst_IF = tag1_IF_match ? (pred1_IF ? {address1_IF, 2'b0} : Instr_PC_IN_IF_Plus4) : (tag2_IF_match ? (pred2_IF ? {address2_IF, 2'b0} : (Instr_PC_IN_IF_Plus4)) : (Instr_PC_IN_IF_Plus4));

    // ID wiring
    // getting the index, tag and prediction index from ID instr and
    // indexing into the cache with this info
    wire [8:0] index_ID;                // index from the ID
    wire [20:0] tag_ID;                 // tag from the ID
    wire [9:0] pred_index_ID;                 // index from ID to FSM
    assign index_ID = Instr_PC_IN_ID[10:2];
    assign tag_ID = Instr_PC_IN_ID[31:11];
    assign pred_index_ID = Instr_PC_IN_ID[11:2];
    // getting the info from cache using the ID instruction
    wire last_recently_used;
    wire valid1_ID;
    wire [20:0] tag1_ID;
    wire [29:0] address1_ID;
    wire pred1_ID;
    wire valid2_ID;
    wire [20:0] tag2_ID;
    wire [29:0] address2_ID;
    wire pred2_ID;
    assign last_recently_used = cache[index_ID][106];
    assign valid1_ID = cache[index_ID][105];
    assign tag1_ID = cache[index_ID][104:84];
    assign address1_ID = cache[index_ID][83:54];
    assign pred1_ID = pred[pred_index_ID];          // cache[index_ID][53];
    assign valid2_ID = cache[index_ID][52];
    assign tag2_ID = cache[index_ID][51:31];
    assign address2_ID = cache[index_ID][30:1];
    assign pred2_ID = pred[pred_index_ID];          // cache[index_ID][0];
    // updating stuff for ID
    reg past_pred_ID;
    reg [31:0] past_pred_inst_ID;
    wire tag1_ID_match;
    wire tag2_ID_match;
    wire [31:0] Instr_PC_IN_ID_Plus4;
    assign tag1_ID_match = (tag1_ID == tag_ID) && valid1_ID;
    assign tag2_ID_match = (tag2_ID == tag_ID) && valid2_ID;
    assign Instr_PC_IN_ID_Plus4 = Instr_PC_IN_ID + 32'd4;

    always begin
        $display("____________Take the branch? %x Where to? %x", take_Branch_OUT_IF, take_Alt_PC_OUT_IF);
    end

    // updating BTB with values from the ID
    // TODO Predictor and BTB have separate isBranch. BTB is updated is only taken when branch is taken
    // No need to check address.
    always @(posedge is_Branch_IN_ID) begin
        if(RESET) begin
            past_pred_ID <= pred[pred_index_ID];
            past_pred_inst_ID <= tag1_ID_match ? (past_pred_ID ? {address1_ID, 2'b0} : Instr_PC_IN_ID_Plus4) : (tag2_ID_match ? (past_pred_ID ? {address2_ID, 2'b0} : (Instr_PC_IN_ID_Plus4)) : (Instr_PC_IN_ID_Plus4));
            if(tag1_ID_match) begin
                cache[index_ID][83:54] <= Alt_PC_IN_ID[31:2];
                cache[index_ID][106] <= 0;
            end else if(tag2_ID_match) begin
                cache[index_ID][30:1] <= Alt_PC_IN_ID[31:2];
                cache[index_ID][106] <= 1;
            end else begin
                if(last_recently_used) begin
                    cache[index_ID][105] <= 1;
                    cache[index_ID][104:84] <= tag_ID;
                    cache[index_ID][83:54] <= Alt_PC_IN_ID[31:2];
                    cache[index_ID][106] <= 0;
                end else begin
                    cache[index_ID][52] <= 1;
                    cache[index_ID][51:31] <= tag_ID;
                    cache[index_ID][30:1] <= Alt_PC_IN_ID[31:2];
                    cache[index_ID][106] <= 1;
                end
            end
        end
    end

    // resetting or updating the output values of the BTB on clock cycle
    integer i;
    always @(posedge CLK or negedge RESET) begin
        if(!RESET) begin
            FLUSH <= 0;
            take_Branch_OUT_IF <= 0;
            take_Alt_PC_OUT_IF <= 0;
            for (i = 0; i < 512; i = i + 1) begin
                cache[i][105] = 0;
                cache[i][52] = 0;
            end
        end else begin
            // if a branch is coming from ID
            if(is_Branch_IN_ID) begin
                if(past_pred_ID) begin
                    if(is_Taken_IN_ID) begin
                        if(past_pred_inst_ID == Alt_PC_IN_ID) begin
                            // we good, supply IFprediction
                            take_Branch_OUT_IF <= pred1_IF && (tag1_IF_match || tag2_IF_match);
                            take_Alt_PC_OUT_IF <= new_pred_inst_IF;
                            FLUSH <= 0;
                        end else begin
                            // TODO FLUSH and supply AltPC
                            take_Branch_OUT_IF <= is_Taken_IN_ID;
                            take_Alt_PC_OUT_IF <= Alt_PC_IN_ID;
                            FLUSH <= 1;
                        end
                    end else begin
                        // TODO FLUSH and supply Instr_PC_IN_ID_Plus4
                        take_Branch_OUT_IF <= !is_Taken_IN_ID;
                        take_Alt_PC_OUT_IF <= Instr_PC_IN_ID_Plus4;
                        FLUSH <= 1;
                    end
                end else begin
                    if(is_Taken_IN_ID) begin
                        // TODO FLUSH and supply AltPC
                        take_Branch_OUT_IF <= is_Taken_IN_ID;
                        take_Alt_PC_OUT_IF <= Alt_PC_IN_ID;
                        FLUSH <= 1;
                    end else begin
                        // we good, supply IFPrediction
                        take_Branch_OUT_IF <= pred1_IF && (tag1_IF_match || tag2_IF_match);
                        take_Alt_PC_OUT_IF <= new_pred_inst_IF;
                        FLUSH <= 0;
                    end
                end
            // otherwise do this
            end else begin
                take_Branch_OUT_IF <= pred1_IF && (tag1_IF_match || tag2_IF_match);
                take_Alt_PC_OUT_IF <= new_pred_inst_IF;
                FLUSH <= 0;
            end
        end
    end
endmodule
