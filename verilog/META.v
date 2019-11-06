/*
* File: META.v
* Author: Nikita Kim
* Email: kimn1944@gmail.com
* Date: 11/4/2019
*/

`include "config.v"

module META
    #(parameter DELAY = 7)
    // general inputs
    (input clk,
    input reset,
    input stall,

    // IF inputs
    input [31:0] if_pc,

    // ID inputs
    input [31:0] id_pc,
    input is_branch,
    input is_taken,

    // other inputs
    input gbp_pred,
    input lbp_pred,

    // outputs
    output reg take);
    // end
    integer i;

    FSM #(.WIDTH(1024), .INDEX(10)) META_FSM(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .pred_sel(if_pc[11:2]),
        .update_sel(past_instr[11:2]),
        .update(is_branch & update),
        .up_down(up_down),
        .pred(fsm_pred));

    wire fsm_pred;
    wire up_down;
    wire update;
    reg [31:0] instr_histories[DELAY - 1:0];
    wire [31:0] past_instr;
    reg gbp_histories[DELAY - 1:0];
    reg lbp_histories[DELAY - 1:0];
    wire past_gbp;
    wire past_lbp;

    assign past_instr = instr_histories[0];
    assign past_gbp   = gbp_histories[0];
    assign past_lbp   = lbp_histories[0];
    assign update     = past_gbp ^ past_lbp;
    assign up_down    = is_taken ? past_gbp : past_lbp;

    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            for(i = 0; i < DELAY; i = i + 1) begin
                instr_histories[i]  = 0;
                gbp_histories[i]    = 0;
                lbp_histories[i]    = 0;
            end
        end
        else if(!stall) begin
            instr_histories[DELAY - 1]   <= if_pc;
            instr_histories[DELAY - 2:0] <= instr_histories[DELAY - 1:1];
            gbp_histories[DELAY - 1]     <= gbp_pred;
            gbp_histories[DELAY - 2:0]   <= gbp_histories[DELAY - 1:1];
            lbp_histories[DELAY - 1]     <= lbp_pred;
            lbp_histories[DELAY - 2:0]   <= lbp_histories[DELAY - 1:1];
        end
        `ifdef META_PRINT
            $display("\t\t\t\t\tMETA Output");
            $display("Take: %x, GBP: %x, LBP: %x, IF PC: %x", take, gbp_pred, lbp_pred, if_pc);
            $display("ID PC: %x, Past PC: %x, Is Branch: %x, Is Taken: %x", id_pc, past_instr, is_branch, is_taken);
            $display("Past GBP: %x, Past LBP: %x", past_gbp, past_lbp);
            $display("Update: %x, UpDown: %x", update & is_branch, up_down);
            $display("\t\t\t\t\tMETA End");
        `endif
    end

    always @ * begin
        take <= fsm_pred ? gbp_pred : lbp_pred;
    end

endmodule
