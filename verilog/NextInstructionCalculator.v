`include "config.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:35:30 10/20/2013 
// Design Name: 
// Module Name:    NextInstructionCalculator 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module NextInstructionCalculator(
    /* PC of the current instruction + 4*/
    input [31:0] Instr_PC_Plus4,
    /* The bits of the instruction (needed to extract the jump destination)*/
    input [31:0] Instruction,
    /* Whether this instruction is a jump */
    input Jump,
    /* Whether this is a jump register instruction */
    input JumpRegister,
    /* If this is a jump register instruction, the value of the register (jump destination)*/
    input [31:0] RegisterValue,
    /* Where we need to jump to */
    output [31:0] NextInstructionAddress,
    /* The register for the jr/jalr (used for debugging Jump Register) */
	 input [4:0] Register
    );

    /* A version of the immediate suitable for feeding to 32bit addition*/
    wire [31:0] signExtended_shifted_immediate;
	/* Where the jump would go (if this were a jump) */
	wire [31:0] jumpDestination_immediate;
	/* Where the branch would go (if this were a branch) */
	wire [31:0] branchDestination_immediate;
	

`ifdef INCLUDE_IF_CONTENT
    /* Low 16 bits of the instruction (the immediate; used by branches)*/
    wire [15:0] immediate;
    assign immediate = Instruction[15:0];

	assign signExtended_shifted_immediate = {{14{immediate[15]}},immediate,2'b00};

    assign jumpDestination_immediate = {Instr_PC_Plus4[31:28],Instruction[25:0],2'b00};
	assign branchDestination_immediate = Instr_PC_Plus4 + signExtended_shifted_immediate;
	 
	assign NextInstructionAddress = Jump?(JumpRegister?RegisterValue:jumpDestination_immediate):branchDestination_immediate;
`else
    /* You'll want to assign these items to more sensible values */

    assign signExtended_shifted_immediate = 32'd0;

     /* This one is actually correct. */
    assign jumpDestination_immediate = {Instr_PC_Plus4[31:28],Instruction[25:0],2'b00};
    
    /* but that was the only one. */
    assign branchDestination_immediate = 32'd0;
     
    /* This is wrong; the assignments are here to avoid "Signal is not used" compile warnings. */
    assign NextInstructionAddress = signExtended_shifted_immediate+jumpDestination_immediate+branchDestination_immediate;
`endif

always @(Jump or JumpRegister or RegisterValue or Instr_PC_Plus4 or Instruction) begin
	if(Jump) begin
	   /* Uncomment the line below */
		$display("Jump Analysis:jr=%d[%d]=%x; jd_imm=%x; branchd=%x => %x",JumpRegister, Register, RegisterValue, jumpDestination_immediate, branchDestination_immediate, NextInstructionAddress);
	end
end
	 

endmodule
