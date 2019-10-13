`include "config.v"
/**************************************
* Module: dummy1.v
* Date:2018-10-24
* Author: uday
*
* Description: Master Instruction dummy1 Module
***************************************/
module  dummy1
(
    input CLK,
    input RESET,
    input FLUSH,
    //This should contain the fetched instruction
    output reg [31:0] Instr1_OUT,
    //This should contain the address of the fetched instruction [DEBUG purposes]
    output reg [31:0] Instr_PC_OUT,
    //This should contain the address of the instruction after the fetched instruction (used by ID)
    output reg [31:0] Instr_PC_Plus4,
    //Will be set to true if we need to just freeze the fetch stage.
    input STALL,
    //Address from which we want to fetch an instruction
    //Instruction received from dummy
    input [31:0]   Instr1_IF,
    input [31:0]   Instr_PC_IF,
    input [31:0]   Instr_PC_Plus4_IF
);

always @(posedge CLK or negedge RESET) begin
    if(!RESET) begin
        Instr1_OUT <= 0;
        Instr_PC_OUT <= 0;
        Instr_PC_Plus4 <= 0;
        $display(" DUMMY1 [RESET] Fetching @%x", Instr_PC_Plus4);
    end else if(CLK) begin
        if(FLUSH) begin
            Instr1_OUT <= 0;
            Instr_PC_OUT <= 0;
            Instr_PC_Plus4 <= 0;
            $display(" DUMMY [FLUSH] Fetching @%x", Instr_PC_Plus4);
        end else if(!STALL) begin
                Instr1_OUT <= Instr1_IF;
                Instr_PC_OUT <= Instr_PC_IF;
                Instr_PC_Plus4 <= Instr_PC_Plus4_IF;
                $display("Dummy1:Instr@%x=%x;Next@%x",Instr_PC_IF,Instr1_IF,Instr_PC_Plus4_IF);
        end else begin
           $display("Dummy1 stalling:Instr@%x=%x;Next@%x",Instr_PC_IF,Instr1_IF,Instr_PC_Plus4_IF);
       end
    end
end
endmodule
