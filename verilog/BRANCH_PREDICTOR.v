`include "config.v"

module BRANCH_PREDICTOR (
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

    // outputs
    output reg flush,
    output reg take,
    output reg [31:0] alt_address
    );

    wire GBP_pred;
    wire LBP_pred;
    wire BTB_hit;
    wire [31:0] BTB_alt_pc;

    GBP GBP(
        .CLK(CLK),
        .RESET(RESET),
        .Is_Branch(Is_Branch),
        .Is_Taken(Is_Taken),
        .pred(GBP_pred)
        );

    LBP LBP(
        .CLK(CLK),
        .RESET(RESET),
        .IF_PC(IF_PC),
        .ID_PC(ID_PC),
        .Is_Branch(Is_Branch),
        .Is_Taken(Is_Taken),
        .pred(LBP_pred)
        );

    BTB BTB(
        .CLK(CLK),
        .RESET(RESET),
        .STALL(STALL),
        .Instr_PC_IN_IF(IF_PC),
        .Instr_IF(IF_Instr),
        .Instr_PC_IN_ID(ID_PC),
        .is_Branch_IN_ID(Is_Branch),
        .is_Taken_IN_ID(Is_Taken),
        .Alt_PC_IN_ID(Alt_PC_ID),
        .hit_BTB(BTB_hit),
        .take_Alt_PC_OUT_IF(BTB_alt_pc)
        );

    META META(
        .CLK(CLK),
        .RESET(RESET),
        .IF_PC(IF_PC),
        .IF_Instr(IF_Instr),
        .ID_PC(ID_PC),
        .Alt_PC_ID(Alt_PC_ID),
        .Is_Jump_Link(Is_Jump_Link),
        .Is_Branch(Is_Branch),
        .Is_Taken(Is_Taken),
        .Pred_L(LBP_pred),
        .Pred_G(GBP_pred),
        .Hit_BTB(BTB_hit),
        .Alt_PC_BTB(BTB_alt_pc),
        .flush(flush),
        .request_alt_pc(take),
        .alt_address(alt_address)
        );
endmodule
