/*
* File: BTB.v
* Author: Nikita Kim
* Email: kimn1944@gmail.com
* Date: 11/3/2019
*/

`include "config.v"

module BTB
    #(parameter DELAY = 7)
    // general inputs
    (input clk,
    input reset,
    input stall,

    // IF inputs
    input [31:0] if_pc,

    // ID inputs
    input [31:0] id_pc,
    input [31:0] alt_address,
    input is_branch,
    input is_taken,

    // outputs
    output reg hit,
    output reg [31:0] alt_pc);
    // end
    integer i;

    reg   [108:0] cache [511:0];
    wire  [8:0]   if_idx;                            // 9 bit index from IF
    wire  [20:0]  if_tag;                            // 21 bit tag from IF
    reg   [31:0]  instr_histories [DELAY - 1:0];
    wire  [8:0]   past_idx;
    wire tag_1_match;
    wire tag_2_match;
    wire update;
    wire lru;

    assign past_idx     = instr_histories[0][10:2];
    assign lru          = cache[past_idx][108];
    assign if_idx       = if_pc[10:2];
    assign if_tag       = if_pc[31:11];
    assign tag_1_match  = (cache[if_idx][106:86] == if_tag) & cache[if_idx][107];
    assign tag_2_match  = (cache[if_idx][52:32]  == if_tag) & cache[if_idx][53];
    assign update       = is_branch & is_taken;

    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            for(i = 0; i < 512; i = i + 1) begin
                cache[i][108:107] = 2'b0;
                cache[i][53] = 0;
            end
            for(i = 0; i < DELAY; i = i + 1) begin
                instr_histories[i] = 0;
            end
        end
        else if(!stall) begin
            instr_histories[DELAY - 1]    <= if_pc;
            instr_histories[DELAY - 2:0]  <= instr_histories[DELAY - 1:1];
            cache[past_idx][107:54] <= update ? (lru ? cache[past_idx][107:54] : {1'b1, id_pc[31:11], alt_address}) : cache[past_idx][107:54];
            cache[past_idx][53:0]   <= update ? (lru ? {1'b1, id_pc[31:11], alt_address} : cache[past_idx][53:0]) : cache[past_idx][53:0];
            cache[past_idx][108]    <= ~lru;
            cache[if_idx][108] <= tag_1_match ? 1 : (tag_2_match ? 0 : cache[if_idx][108]);
        end
        `ifdef BTB_PRINT
            $display("BTB Output");
            $display("Hit: %x, Alt PC: %x, IF PC: %x", hit, alt_pc, if_pc);
            $display("ID PC: %x, Past PC: %x, Is Branch: %x, Is Taken: %x", id_pc, instr_histories[0], is_branch, is_taken);
            $display("BTB End");
        `endif
    end

    always @ * begin
        hit     <= tag_1_match || tag_2_match;
        alt_pc  <= tag_1_match ? cache[if_idx][85:54] : cache[if_idx][31:0];
    end
endmodule
