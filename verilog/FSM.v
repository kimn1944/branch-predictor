/*
* File: FSM.v
* Author: Nikita Kim
* Email: kimn1944@gmail.com
* Date: 10/31/2019
*/

`include "config.v"

module FSM
    // params
    #(parameter WIDTH = 1024,
      parameter INDEX = 10)
    // general inputs
    (input clk,
    input reset,
    input stall,

    // selector inputs
    input [INDEX - 1:0] pred_sel,

    // update inputs
    input [INDEX - 1:0] update_sel,
    input update,
    input up_down,

    // outputs
    output reg pred);
    // end
    integer i;
    reg                 A [WIDTH - 1:0];
    reg                 B [WIDTH - 1:0];

    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            for(i = 0; i < WIDTH; i = i + 1) begin
                A[i] = 0;
                B[i] = 0;
            end
        end
        else if(!stall) begin
            if (update) begin
                A[update_sel] <= (A[update_sel] & B[update_sel]) | (A[update_sel] & up_down) | (B[update_sel] & up_down);
                B[update_sel] <= (A[update_sel] & ~B[update_sel]) | (A[update_sel] & up_down) | (~B[update_sel] & up_down);
            end
        end
        `ifdef FSM_PRINT
            $display("FSM Output");
            $display("Update Sel: %x, Update Idx: %x, Update: %x, Up_Down: %x", update_sel, update_sel, update, up_down);
            $display("A: %x, B: %x, Pred: %x", A[update_sel], B[update_sel], A[update_sel]);
            $display("Pred Sel: %x, Pred Idx: %x, Pred %x", pred_sel, pred_sel, A[pred_sel]);
            $display("FSM End");
        `endif
    end

    always @ * begin
        pred = A[pred_sel];
    end

endmodule
