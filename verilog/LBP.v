/*
* File: LBP.v
* Author: Nikita Kim
* Email: kimn1944@gmail.com
* Date: 11/3/2019
*/

`include "config.v"

module LBP
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

    // outputs
    output reg pred);
    // end
    integer i;

    FSM #(.WIDTH(1024), .INDEX(10)) LBP_FSM(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .pred_sel(history),
        .update_sel(past_history),
        .update(is_branch),
        .up_down(is_taken),
        .pred(fsm_pred));

        wire fsm_pred;
        wire  [9:0] pred_idx;
        wire  [9:0] update_idx;
        reg   [9:0] branch_history [1023:0];
        wire  [9:0] history;
        reg   [9:0] past_histories [DELAY - 1:0];
        wire  [9:0] past_history;
        reg   [31:0] instr_histories [DELAY - 1:0];

        assign pred_idx = if_pc[11:2];
        assign update_idx = instr_histories[0][11:2];
        assign history = branch_history[pred_idx];
        assign past_history = past_histories[0];

    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            for(i = 0; i < 1024; i = i + 1) begin
                branch_history[i] = 0;
            end
            for(i = 0; i < DELAY; i = i + 1) begin
                past_histories[i]   = 0;
                instr_histories[i]  = 0;
            end
        end
        else if(!stall)begin
            instr_histories[DELAY - 1]    <= if_pc;
            instr_histories[DELAY - 2:0]  <= instr_histories[DELAY - 1:1];
            past_histories[DELAY - 1]     <= history;
            past_histories[DELAY - 2:0]   <= past_histories[DELAY - 1:1];
            branch_history[update_idx]    <= is_branch ? {is_taken, past_history[9:1]} : branch_history[update_idx];
        end
        `ifdef LBP_PRINT
            $display("\t\t\t\t\tLBP Output");
            $display("History: %b, IF PC: %x, Pred: %x", history, if_pc, fsm_pred);
            $display("Past History: %b, Past PC: %x", past_histories[0], instr_histories[0]);
            $display("ID PC: %x, Is Branch: %x, Is Taken: %x", id_pc, is_branch, is_taken);
            $display("\t\t\t\t\tLBP End");
        `endif
    end

    always @ * begin
        pred = fsm_pred;
    end

endmodule
