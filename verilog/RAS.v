/*
* File: RAS.v
* Author: Nikita Kim
* Email: kimn1944@gmail.com
* Date: 11/3/2019
*/

`include "config.v"

module RAS
    #()
    // general inputs
    (input clk,
    input reset,
    input stall,

    // IF inputs
    input [31:0] if_pc,
    input [31:0] if_instr,

    // ID inputs
    input [31:0] id_pc,
    input is_link,

    // outputs
    output reg hit,
    output reg [31:0] alt_pc);
    // end

    STACK #() RAS_STACK(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .push(push),
        .pop(pop),
        .data(id_pc + 32'd8),
        .top(top));

   	wire [5:0] opcode;
    wire [5:0] funct;
    wire [4:0] rs;
    wire [31:0] top;
    wire push;
    wire pop;
    wire special;
    wire available;

    assign opcode   = if_instr[31:26];
	  assign funct    = if_instr[5:0];
    assign rs       = if_instr[25:21];
    assign special  = is_link & hit;          // special case when we push and pop at the same time
    assign push     = special ? 0 : is_link;
    assign pop      = special ? 0 : hit;
    assign available = top != 32'b0;

    always @(posedge clk or negedge reset) begin
        if(!reset) begin

        end
        else begin

        end
        `ifdef RAS_PRINT
            $display("RAS Output");
            $display("IF PC: %x, Hit: %x, Alt PC: %x", if_pc, hit, alt_pc);
            $display("ID PC: %x, Is Link: %x, Special: %x", id_pc, is_link, special);
            $display("Pop: %x, Push: %x, Data: %x", pop, push, id_pc + 32'd8);
            $display("RAS End");
        `endif
    end

    always @ * begin
        hit     <= (opcode == 6'b000000) & (funct == 6'b001000) & (rs == 5'b11111) & available;
        alt_pc  <= special ? id_pc + 32'd8 : top;
    end

endmodule
