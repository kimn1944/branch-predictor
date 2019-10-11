`include "config.v"
/**************************************
* Module: Fetch
* Date:2018-10-24  
* Author: uday     
*
* Description: Master Instruction dummy3 Module
***************************************/
module  dummy3
(
    input CLK,
    input RESET, 
    //This should contain the fetched instruction
    output reg [31:0] Instr1_OUT,
    //This should contain the address of the fetched instruction [DEBUG purposes]
    output reg [31:0] Instr_PC_OUT,
    //This should contain the address of the instruction after the fetched instruction (used by ID)
    output reg [31:0] Instr_PC_Plus4,
    //Will be set to true if we need to just freeze the fetch stage.
    input STALL,
    //Address from which we want to fetch an instruction
    //Instruction received from IF 
    input [31:0]   Instr1_IF,
    input [31:0]   Instr_PC_IF,
    input [31:0]   Instr_PC_Plus4_IF
);

always @(posedge CLK or negedge RESET) begin
    if(!RESET) begin
        Instr1_OUT <= 0;
        Instr_PC_OUT <= 0;
        Instr_PC_Plus4 <= 0;
        $display(" DUMMY3 [RESET] Fetching @%x", Instr_PC_Plus4);
        
    end else if(CLK) begin
        if(!STALL) begin
                Instr1_OUT <= Instr1_IF;
                Instr_PC_OUT <= Instr_PC_IF;
                Instr_PC_Plus4 <= Instr_PC_Plus4_IF;
                $display("Dummy3:Instr@%x=%x;Next@%x",Instr_PC_IF,Instr1_IF,Instr_PC_Plus4_IF); 
        end else begin
              $display("Dummy3 stalling:Instr@%x=%x;Next@%x",Instr_PC_IF,Instr1_IF,Instr_PC_Plus4_IF);
          end 
    end
end
endmodule
