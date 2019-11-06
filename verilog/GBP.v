/*
* File: GBP.v
* Author: Nikita Kim
* Email: kimn1944@gmail.com
* Date: 10/31/2019
*/

`include "config.v"

module GBP
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

    FSM #(.WIDTH(4096), .INDEX(12)) GBP_FSM (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .pred_sel(history),
        .update_sel(past_histories[0]),
        .update(is_branch),
        .up_down(is_taken),
        .pred(fsm_pred));

    reg   [11:0]  history;
    reg   [11:0]  past_histories [DELAY - 1:0];
    reg   [31:0]  instr_histories [DELAY - 1:0];
    wire          fsm_pred;

    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            history <= 0;
            for(i = 0; i < DELAY; i = i + 1) begin
                past_histories[i]   = 0;
                instr_histories[i]  = 0;
            end
        end
        else if(!stall) begin
            history <= is_branch ? {is_taken, history[11:1]} : history;
            past_histories[DELAY - 1]     <= history;
            past_histories[DELAY - 2:0]   <= past_histories[DELAY - 1:1];
            instr_histories[DELAY - 1]    <= if_pc;
            instr_histories[DELAY - 2:0]  <= instr_histories[DELAY - 1:1];
        end
        `ifdef GBP_PRINT
            $display("\t\t\t\t\tGBP Output");
            $display("History: %b, IF PC: %x, Pred: %x", history, if_pc, fsm_pred);
            $display("Past History: %b, Past PC: %x", past_histories[0], instr_histories[0]);
            $display("ID PC: %x, Is Branch: %x, Is Taken: %x", id_pc, is_branch, is_taken);
            $display("\t\t\t\t\tGBP end");
        `endif
    end

    always @ * begin
        pred = fsm_pred;
    end

endmodule
