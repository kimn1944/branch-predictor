module META
(
    // general inputs
    input CLK,
    input RESET,
    input STALL,

    // IF inputs
    input [31:0] IF_PC,
    input [31:0] IF_Instr,

    // ID inputs
    input [31:0] ID_PC,
    input [31:0] Alt_PC_ID,
    input Is_Jump_Link,
    input Is_Branch,
    input Is_Taken,

    //predictor inputs
    input Pred_L,
    input Pred_G,
    input Hit_BTB,
    input [31:0] Alt_PC_BTB,

    // outputs
    output reg flush,
    output reg request_alt_pc,
    output reg [31:0] alt_address

);

    wire [31:0] IncrementAmount;
    assign IncrementAmount = 32'd4;

    reg [31:0] past_IF_PC [6:0];
    reg [6:0] past_decisions_L;
    reg [6:0] past_decisions_G;
    reg [6:0] past_decisions_M;
    reg [31:0] past_Alt_PC [6:0];
    wire up_down;
    wire update_meta;
    wire Hit_RAS;
    wire mispred;
    wire [31:0] Alt_PC_RAS;
    integer missnum;
    integer branch_count;
    wire [9:0] index_IF;
    wire pred [1023:0];
    wire pred_IF;
    wire [31:0] new_pred_inst_IF;
    wire alt_PC_valid;
    integer i;

    // the meta predictor is updated only when GBP and LBP make different predictions
    // otherwise it will note be trained
    assign up_down          = Is_Taken == past_decisions_G[0];
    assign update_meta      = past_decisions_G[0] ^ past_decisions_L[0];
    assign index_IF         = IF_PC[11:2];
    assign pred_IF          = mispred ? 1 : (Hit_RAS ? 1 : (Hit_BTB ? (pred[index_IF] ? Pred_G : Pred_L) : 0));
    assign alt_PC_valid     = Is_Taken ? past_Alt_PC[0] == Alt_PC_ID : past_Alt_PC[0] == ID_PC + IncrementAmount;    //Is_Branch && ((past_Alt_PC[0] == Alt_PC_ID) && (Is_Taken == past_decisions_M[0]));
    assign mispred          = Is_Branch ? (alt_PC_valid ? 0 : 1) : 0;
    assign new_pred_inst_IF = Hit_RAS ? Alt_PC_RAS : (pred_IF ? (Hit_BTB ? Alt_PC_BTB : IF_PC + IncrementAmount) : IF_PC + IncrementAmount);

    // debug
    wire [31:0] corr_add = Is_Taken ? Alt_PC_ID : ID_PC + 32'd8;

    FSM FSM (
        .CLK(CLK),
        .RESET(RESET),
        .isTaken(up_down),
        .isBranch(Is_Branch & update_meta),
        .InstrPC(ID_PC),

        .Pred(pred)
    );

    RAS RAS (
        .CLK(CLK),
        .RESET(RESET),
        .InstrPC_IF(IF_PC),
        .Instr_IF(IF_Instr),
        .IsJL(Is_Jump_Link),
        .InstrPC_ID(ID_PC),

        .hit(Hit_RAS),
        .alt_PC(Alt_PC_RAS)
    );


    always @(posedge CLK or negedge RESET) begin
        if(!RESET) begin
            flush            <= 0;
            request_alt_pc   <= 0;
            alt_address      <= 0;
            past_decisions_L <= 0;
            past_decisions_G <= 0;
            past_decisions_M <= 0;
            missnum          <= 0;
            branch_count     <= 0;
            for(i = 0; i < 7; i = i + 1) begin
                past_IF_PC[i] <= 0;
            end
        end else begin//if(!STALL) begin
            if(mispred) begin
                request_alt_pc <= 1;
                flush <= 1;
                //take_Alt_PC_OUT_IF <= past_take_ID ? Instr_PC_IN_ID + 32'd8 : Alt_PC_IN_ID;
                alt_address  <= Is_Taken ? Alt_PC_ID : ID_PC + 32'd8;
                past_decisions_L[6:0] <= {6'b0, past_decisions_L[1]};
                past_decisions_G[6:0] <= {6'b0, past_decisions_G[1]};
                past_decisions_M[6:0] <= {6'b0, past_decisions_M[1]};
                // past_Alt_PC[7]     <= 32'b0;
                past_Alt_PC[6]     <= 32'b0;
                past_Alt_PC[5]     <= 32'b0;
                past_Alt_PC[4]     <= 32'b0;
                past_Alt_PC[3]     <= 32'b0;
                past_Alt_PC[2]     <= 32'b0;
                past_Alt_PC[1]     <= 32'b0;
                past_Alt_PC[0]     <= past_Alt_PC[1];

                // past_IF_PC[7]      <= 32'b0;
                past_IF_PC[6]      <= 32'b0;
                past_IF_PC[5]      <= 32'b0;
                past_IF_PC[4]      <= 32'b0;
                past_IF_PC[3]      <= 32'b0;
                past_IF_PC[2]      <= 32'b0;
                past_IF_PC[1]      <= 32'b0;
                past_IF_PC[0]      <= past_IF_PC[1];
                missnum            <= missnum + 1;
            end else begin
                request_alt_pc <= pred_IF;
                alt_address    <= new_pred_inst_IF;
                flush          <= 0;
                past_decisions_L[6:0] <= {Pred_L, past_decisions_L[6:1]};
                past_decisions_G[6:0] <= {Pred_G, past_decisions_G[6:1]};
                past_decisions_M[6:0] <= {pred_IF, past_decisions_M[6:1]};
                past_Alt_PC[6]        <= new_pred_inst_IF;
                past_Alt_PC[5:0]      <= past_Alt_PC[6:1];
                past_IF_PC[6]         <= IF_PC;
                past_IF_PC[5:0]       <= past_IF_PC[6:1];

            end
            branch_count <= branch_count + Is_Branch;
            // $display("\n^^^^^^^^^^^^\n");
            // $display("____________Mispred %x Past Pred %x", mispred, past_take_ID);
            // $display("____________Take the branch_IF? %x Where to? %x", take_IF, new_pred_inst_IF);
            // $display("____________Take the branch_ID? %x Where to? %x", is_Taken_IN_ID, is_Taken_IN_ID ? Alt_PC_IN_ID : Instr_PC_IN_ID + 32'd8);
            // $display("____________Take IF %x", take_IF);
            // $display("____________Past decisions %b", past_decisions_M);
            $display("____________Number of Branch Misses %d", missnum);
            $display("____________Number of branches %d", branch_count);
            // $display(" BTB: past_IF: %x               INSTR_ID: %x\nvvvvvvvvvvv\n", past_IF, Instr_PC_IN_ID);

            $display("********************************");
            $display("Misprediction %x", mispred);
            $display("Take          %x. Past Take     %x. Correct decision  %x", pred_IF, past_decisions_M[0], Is_Taken);
            $display("Alt address   %x. Past Alt PC   %x. Correct address   %x", new_pred_inst_IF, past_Alt_PC[0], corr_add);
            $display("BTB hit       %x", Hit_BTB);
            $display("Global        %x, Local         %x", Pred_G, Pred_L);
            $display("********************************");
        end
    end

endmodule
