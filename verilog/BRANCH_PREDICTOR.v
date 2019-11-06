/*
* File: BRANCH_PREDICTOR.v
* Author: Nikita Kim
* Email: kimn1944@gmail.com
* Date: 11/4/2019
*/

`include "config.v"

module BRANCH_PREDICTOR
    #(parameter DELAY = 7)
    // general inputs
    (input clk,
    input reset,
    input stall,

    // IF inputs
    input [31:0] if_pc,
    input [31:0] if_instr,

    // ID inputs
    input [31:0] id_pc,
    input [31:0] alt_address,
    input is_link,
    input is_branch,
    input is_taken,

    // outputs
    output reg take,
    output reg flush,
    output reg [31:0] alt_pc);
    // end
    integer i;
    integer branch_count;
    integer miss_count;

    wire gbp_pred;
    wire lbp_pred;
    wire meta_pred;
    wire btb_hit;
    wire ras_hit;
    wire [31:0] btb_alt_pc;
    wire [31:0] ras_alt_pc;

    wire req_alt;
    wire [31:0] req_alt_pc;
    reg past_decisions [DELAY - 1:0];
    reg [31:0] past_pcs [DELAY - 1:0];
    wire mispred;

    assign req_alt      = (btb_hit & meta_pred) | ras_hit;
    assign req_alt_pc   = ras_hit ? ras_alt_pc : btb_alt_pc;
    assign mispred      = is_branch ? (is_taken ? ~(past_pcs[0] == alt_address) : ~(past_pcs[0] == id_pc + 32'd4)) : 0;

    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            for(i = 0; i < DELAY; i = i + 1) begin
                past_decisions[i] <= 0;
                past_pcs[i]       <= 0;
            end
        end
        else if(!stall) begin
            if(!flush) begin
                past_decisions[DELAY - 1]   <= req_alt | mispred;
                past_decisions[DELAY - 2:0] <= past_decisions[DELAY - 1:1];
                past_pcs[DELAY - 1]         <= mispred ? (is_taken ? alt_address : id_pc + 32'd8) : (req_alt ? req_alt_pc : if_pc + 32'd4);
                past_pcs[DELAY - 2:0]       <= past_pcs[DELAY - 1:1];
                take    <= req_alt | mispred;
                flush   <= mispred;
                alt_pc  <= mispred ? (is_taken ? alt_address : id_pc + 32'd8) : (req_alt ? req_alt_pc : if_pc + 32'd4);
                branch_count <= is_branch ? branch_count + 1'd1 : branch_count;
                miss_count   <= mispred ? miss_count + 1'd1 : miss_count;
            end
            else begin
                take    <= 0;
                flush   <= mispred;
                alt_pc  <= 0;
            end
        end
        `ifdef BP_PRINT
            $display("\t\t\t\t\tBP Output");
            $display("IF PC: %x, IF Instr: %x, Take: %x, Alt PC: %x, Flush: %x", if_pc, if_instr, req_alt | mispred, mispred ? (is_taken ? alt_address : id_pc + 32'd8) : (req_alt ? req_alt_pc : if_pc + 32'd4), mispred);
            $display("RAS Hit: %x, RAS PC: %x, BTB Hit: %x, BTB PC: %x", ras_hit, ras_alt_pc, btb_hit, btb_alt_pc);
            $display("ID PC: %x, Alt Addr: %x, Is Branch: %x, Is Taken: %x, Is Link: %x", id_pc, alt_address, is_branch, is_taken, is_link);
            $display("Past Dec: %x, Past Addr: %x", past_decisions[0], past_pcs[0]);
            $display("\t\t\t\t\tBP End");
        `endif
        `ifdef BP_STAT
            $display("Miss Count: %d", miss_count);
            $display("Branch Count: %d", branch_count);
        `endif
    end

    META META(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .if_pc(if_pc),
        .id_pc(id_pc),
        .is_branch(is_branch),
        .is_taken(is_taken),
        .gbp_pred(gbp_pred),
        .lbp_pred(lbp_pred),
        .take(meta_pred));

    GBP GBP(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .if_pc(if_pc),
        .id_pc(id_pc),
        .is_branch(is_branch),
        .is_taken(is_taken),
        .pred(gbp_pred));

    LBP LBP(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .if_pc(if_pc),
        .id_pc(id_pc),
        .is_branch(is_branch),
        .is_taken(is_taken),
        .pred(lbp_pred));

    BTB BTB(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .if_pc(if_pc),
        .id_pc(id_pc),
        .alt_address(alt_address),
        .is_branch(is_branch),
        .is_taken(is_taken),
        .hit(btb_hit),
        .alt_pc(btb_alt_pc));

    RAS RAS(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .if_pc(if_pc),
        .if_instr(if_instr),
        .id_pc(id_pc),
        .is_link(is_link),
        .hit(ras_hit),
        .alt_pc(ras_alt_pc));

endmodule
