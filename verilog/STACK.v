/*
* File: STACK.v
* Author: Nikita Kim
* Email: kimn1944@gmail.com
* Date: 11/3/2019
*/

`include "config.v"

module STACK
    #(parameter SIZE = 32,
      parameter WIDTH = 32)
    // general inputs
    (input clk,
    input reset,
    input stall,

    // actions
    input pop,
    input push,
    input [WIDTH - 1:0] data,

    // general outputs
    output reg [WIDTH - 1:0] top);
    // end
    integer i;
    integer pointer;
    integer increment;
    reg [WIDTH - 1:0] stack [SIZE - 1:0];
    wire push_val;
    wire pop_val;

    assign push_val   = (pointer < SIZE) ? push : 0;
    assign pop_val    = (pointer > 0) ? (0 - pop) : 0;
    assign increment  = 0 + {31'b0, push_val} - {31'b0, pop_val};

    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            for(i = 0; i < SIZE; i = i + 1) begin
                stack[i]  <= 0;
            end
            pointer <= 0;
        end
        else if(!stall) begin
            pointer <= pointer + increment;
            if(push) begin
                if(pointer < SIZE) begin
                    stack[pointer] <= data;
                end
                else begin
                    stack[SIZE - 1]   <= data;
                    stack[SIZE - 2:0] <= stack[SIZE - 1:1];
                end
            end
        end
        `ifdef STACK_PRINT
            $display("STACK Output");
            $display("Pop: %x, Push: %x, Data: %x", pop, push, data);
            $display("Top: %x, Pointer: %d", top, pointer);
            $display("STACK End");
        `endif
    end

    always @ * begin
        top <= (pointer > 0) ? stack[pointer - 1] : 0;
    end

endmodule
