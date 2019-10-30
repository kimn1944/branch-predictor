module BTB (
    // general inputs
    input CLK,
    input RESET,
    input STALL,

    // IF inputs
    input [31:0] Instr_PC_IN_IF,
    input [31:0] Instr_IF,

    // ID inputs
    input [31:0] Instr_PC_IN_ID,
    input is_Branch_IN_ID,
    input is_Taken_IN_ID,
    input [31:0] Alt_PC_IN_ID,

    // outputs
    output reg hit_BTB,
    output reg [31:0] take_Alt_PC_OUT_IF
);
    // cache structure
    reg [106:0] cache [511:0];


    // IF wiring
    // getting the index, tag and prediction index from IF instr and
    // indexing into the cache with this info
    wire [8:0]      index_IF;                // index from the IF
    wire [20:0]     tag_IF;                  // tag from the IF
    wire            IsJR;


    assign index_IF         = Instr_PC_IN_IF[10:2];
    assign tag_IF           = Instr_PC_IN_IF[31:11];
    assign IsJR             = (Instr_IF[31:11] == 21'b000000111110000000000) && (Instr_IF[5:0] == 6'b001000);

    // getting info from cache using the IF instruction
    wire [20:0] tag1_IF;
    wire [31:0] address1_IF;
    wire [20:0] tag2_IF;
    wire [31:0] address2_IF;

    assign tag1_IF      = cache[index_IF][105:85];
    assign address1_IF  = cache[index_IF][84:53];
    assign tag2_IF      = cache[index_IF][52:32];
    assign address2_IF  = cache[index_IF][31:0];

    // IF wiring for prediction
    wire [31:0] new_pred_inst_IF;
    wire        tag1_IF_match;
    wire        tag2_IF_match;
    wire [31:0] Instr_PC_IN_IF_Plus4;
    wire        take_IF;

    assign tag1_IF_match        = (tag1_IF == tag_IF) && (Instr_PC_IN_IF != 32'b0);
    assign tag2_IF_match        = (tag2_IF == tag_IF) && (Instr_PC_IN_IF != 32'b0);
    assign Instr_PC_IN_IF_Plus4 = Instr_PC_IN_IF + 32'd4;
    assign take_IF              = tag1_IF_match || tag2_IF_match;
    assign new_pred_inst_IF     = take_IF ? (tag1_IF_match ? address1_IF : address2_IF) : (Instr_PC_IN_IF_Plus4);

    // ID wiring
    // getting the index, tag and prediction index from ID instr and
    // indexing into the cache with this info
    wire [8:0]  index_ID;                // index from the ID
    wire [20:0] tag_ID;                  // tag from the ID

    assign index_ID         = Instr_PC_IN_ID[10:2];
    assign tag_ID           = Instr_PC_IN_ID[31:11];


    // getting the info from cache using the ID instruction
    wire last_recently_used;
    wire [20:0] tag1_ID;
    wire [31:0] address1_ID;
    wire [20:0] tag2_ID;
    wire [31:0] address2_ID;

    assign last_recently_used   = cache[index_ID][106];
    assign tag1_ID              = cache[index_ID][105:85];
    assign address1_ID          = cache[index_ID][84:53];
    assign tag2_ID              = cache[index_ID][52:32];
    assign address2_ID          = cache[index_ID][31:0];

    // updating stuff for ID
    integer i;
    wire        tag1_ID_match;
    wire        tag2_ID_match;

    assign tag1_ID_match        = (tag1_ID == tag_ID) && (Instr_PC_IN_ID != 32'b0);
    assign tag2_ID_match        = (tag2_ID == tag_ID) && (Instr_PC_IN_ID != 32'b0);

    initial begin
        for (i = 0; i < 512; i = i + 1) begin
                cache[i] <= 107'b0;
        end
        hit_BTB = 0;
        take_Alt_PC_OUT_IF = 0;
    end

    // updating BTB with values from the ID
    // TODO Predictor and BTB have separate isBranch. BTB is updated is only taken when branch is taken
    // No need to check address.
    always @(posedge is_Taken_IN_ID) begin
        //if(!STALL) begin
        if(is_Branch_IN_ID) begin
            if(tag1_ID_match || tag2_ID_match) begin
                cache[index_ID][106]    <= tag1_ID_match;
            end else if (Instr_PC_IN_ID != 32'b0)begin
                cache[index_ID][105:53] <= last_recently_used ? {tag1_ID, address1_ID} : {tag_ID, Alt_PC_IN_ID};
                cache[index_ID][52:0]   <= last_recently_used ? {tag_ID, Alt_PC_IN_ID} : {tag2_ID, address2_ID};
                cache[index_ID][106]    <= ~last_recently_used;
            end
        end
        //end
    end

    assign hit_BTB  = take_IF;
    assign take_Alt_PC_OUT_IF  = new_pred_inst_IF;

    // resetting or updating the output values of the BTB on clock cycle
    // always @(posedge CLK or negedge RESET) begin
    //     if(!RESET) begin
    //         hit_BTB <= 0;
    //         take_Alt_PC_OUT_IF <= 0;
    //     end else begin//if(!STALL) begin
    //         

    //         // $display("\n^^^^^^^^^^^^\n");
    //         // $display("____________Mispred %x Past Pred %x", mispred, past_take_ID);
    //         // $display("____________Take the branch_IF? %x Where to? %x", take_IF, new_pred_inst_IF);
    //         // $display("____________Take the branch_ID? %x Where to? %x", is_Taken_IN_ID, is_Taken_IN_ID ? Alt_PC_IN_ID : Instr_PC_IN_ID + 32'd8);
    //         // $display("____________Take IF %x", take_IF);
    //         // $display("____________Past decisions %b", past_decisions);
    //         // $display(" BTB: past_IF: %x               INSTR_ID: %x\nvvvvvvvvvvv\n", past_IF, Instr_PC_IN_ID);
    //     end
    // end

    always @(posedge CLK)begin
        $display("BTB HIT           %x", take_IF);
        $display("BTB Alt address   %x", new_pred_inst_IF);
    end
endmodule
