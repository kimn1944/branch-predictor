`include "config.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:42:47 10/20/2013 
// Design Name: 
// Module Name:    Decoder 
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
module Decoder
    #(
    //If doing multi-issue or superscalar, you might want to change this.
    parameter TAG = "1"
)
(
    //Instruction to decode
    input [31:0] Instr,
    //PC of instruction (for debug output)
	 input [31:0] Instr_PC,
	 //Enable debug output
	 input comment1,
	 //This is a ...AndLink instruction
    output reg Link,
    //This instruction uses the RegDest register (Instr[15:11])
    output reg RegDest,
    //This instruction is a jump (unconditional)
    output reg Jump,
    //This instruction might branch (set for branches and jumps)
    output reg Branch,
    //This instruction reads from memory
    output reg MemRead,
    //This instruction writes to memory
    output reg MemWrite,
    //This instruction contains an immediate value (as source to the ALU)
    output reg ALUSrc,
    //This instruction writes to a register
    output reg RegWrite,
    //This instruction is a jump to a location specified in a register
    output reg JumpRegister,
    //If 1, the immediate in this instruction (16 bits) is sign-extended. If 0, it's always 0-extended.
    output reg SignOrZero,
    //This instruction is a system call
    output reg Syscall,
    //What operation the ALU/Memory should perform
    output reg [5:0] ALUControl,
    //This instruction accesses the multiplication registers (HI/LO)
    output reg [1:0] MultRegAccess
    );

	wire [5:0] opcode;
	wire [4:0] format;
	wire [4:0] rt;
	wire [5:0] funct;
	
	assign opcode = Instr[31:26];
	assign format = Instr[25:21];
	assign rt = Instr[20:16];
	assign funct = Instr[5:0];
        //wire dummy;
        

always begin
    //opcode1 = Instr_IN[31:26];  // first 6 bits (opcode)
    //format1 = Instr_IN[25:21];  // argument to instruction
    //rt1 = Instr_IN[20:16];  // destination register
    //funct1 = Instr_IN[5:0];  // last 6 bits (function code)
// ZOMG- so dirty.  Every var here is a bit except for the ALU_countrol1, which is the last 5 bits
    case(opcode) // main instruction decode case statement
        6'b000000: begin //SPECIAL
            case(funct)
                6'b000000: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100001001100; if (comment1)$display("[%s]sll,nop",TAG); end//SLL,NOP
                6'b000010: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100001101100; if (comment1)$display("[%s]srl",TAG); end//SRL
                6'b000011: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100001100100; if (comment1)$display("[%s]sra",TAG); end//SRA
                6'b000100: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100001010000; if (comment1)$display("[%s]sllv",TAG); end//SLLV
                6'b000110: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100001110000; if (comment1)$display("[%s]srlv",TAG); end//SRLV
                6'b000111: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100001101000; if (comment1)$display("[%s]srav",TAG); end//SRAV
				6'b001000: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0011000010011111000; if (comment1)$display("[%s]JR",TAG); end
				6'b001001: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b1111001110000000100; if (comment1)$display("[%s]JALR",TAG); end
                6'b001100: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000001101100001100; if (comment1)$display("[%s]Syscall",TAG); end//Syscall*
                6'b001101: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100001100001001100; if (comment1)$display("[%s]break",TAG); end//BREAK*
                6'b010000: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100000100110; if (comment1)$display("[%s]mfhi",TAG); end//MFHI
                6'b010001: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000000000000101110; if (comment1)$display("[%s]mthi",TAG); end//MTHI
                6'b010010: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100000101001; if (comment1)$display("[%s]mflo",TAG); end//MFLO
                6'b010011: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000000000000110001; if (comment1)$display("[%s]mtlo",TAG); end//MTLO
				6'b011000: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000000000110111; if (comment1)$display("[%s]MULT",TAG); end
				6'b011001: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000000000110111; if (comment1)$display("[%s]MULTU",TAG); end
				6'b011010: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000000000010111; if (comment1)$display("[%s]DIV",TAG); end
				6'b011011: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000000000011011; if (comment1)$display("[%s]DIVU",TAG); end
                6'b100000: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100000000000; if (comment1)$display("[%s]add",TAG); end//add
                6'b100001: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100011011100; if (comment1)$display("[%s]addu",TAG); end//addu
                6'b100010: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100001110100; if (comment1)$display("[%s]sub",TAG); end//sub
                6'b100011: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100001111000; if (comment1)$display("[%s]subu",TAG); end//subu
                6'b100100: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100000010000; if (comment1)$display("[%s]and",TAG); end//and
                6'b100101: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100001000000; if (comment1)$display("[%s]or",TAG); end//or
                6'b100110: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100001111100; if (comment1)$display("[%s]xor",TAG); end//Xor
                6'b100111: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100000111100; if (comment1)$display("[%s]nor",TAG); end//nor
                6'b101010: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100001010100; if (comment1)$display("[%s]slt",TAG); end//slt
                6'b101011: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000100011111100; if (comment1)$display("[%s]sltu",TAG); end//sltu
                default: $display("Not an Instruction!");
            endcase
        end
        6'b000001: begin
            case(rt)
                5'b00000: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0001000001010011100; if (comment1)$display("[%s]bltz",TAG); end//BLTZ
                5'b00001: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0001000001010001100; if (comment1)$display("[%s]bgez",TAG); end//BGEZ
                5'b10000: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b1001001101000000100; if (comment1)$display("[%s]bltzal",TAG); end//BLTZAL
                5'b10001: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b1001001101000000100; if (comment1)$display("[%s]bgezal",TAG); end//BGEZAL
                default: $display("Not an Instruction!");
            endcase
        end
		6'b000010: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0011000000000111000; if (comment1)$display("[%s]J",TAG); end
		6'b000011: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b1011001101000000100; if (comment1)$display("[%s]JAL",TAG); end
		6'b000100: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0101000001010001000; if (comment1)$display("[%s]BEQ",TAG); end
		6'b000101: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0101000001010100100; if (comment1)$display("[%s]BNE",TAG); end
        6'b000110: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0001000001010011000; if (comment1)$display("[%s]blez",TAG); end//BLEZ
        6'b000111: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0001000001010010100; if (comment1)$display("[%s]bgtz",TAG); end//BGTZ
        6'b001000: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000001101000000100; if (comment1)$display("[%s]addi",TAG); end//ADDI  
        6'b001001: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000001101000001000; if (comment1)$display("[%s]addiu",TAG); end//ADDIU
        6'b001010: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000001101001010100; if (comment1)$display("[%s]slti",TAG); end//SLTI
        6'b001011: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000001101011111100; if (comment1)$display("[%s]sltiu",TAG); end//SLTIU
        6'b001100: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000001100000010000; if (comment1)$display("[%s]andi",TAG); end//ANDI
        6'b001101: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000001100001000000; if (comment1)$display("[%s]ori",TAG); end//ORI
        6'b001110: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000001100010000000; if (comment1)$display("[%s]xori",TAG); end//XorI
		6'b001111: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000001101000100000; if (comment1)$display("[%s]LUI",TAG); end
        6'b010001: begin //COP1
				$display("UNHANDLED CASE - COP1");
            case(format)
                5'b00000: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000000101001110000; if (comment1)$display("[%s]mfc1",TAG); end//MFC1
                5'b00010: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000000101001101000; if (comment1)$display("[%s]cfc1",TAG); end//CFC1
                5'b00100: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000001011100000; if (comment1)$display("[%s]mtc1",TAG); end//MTC1
                5'b00110: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000001011010000; if (comment1)$display("[%s]ctc1",TAG); end//CTC1
                5'b01000: begin
                    case(Instr[16])
                        1'b1: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0001000001001110100; if (comment1)$display("[%s]bc1t",TAG); end//BC1T
                        1'b0: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0001000001000111100; if (comment1)$display("[%s]bc1f",TAG); end//BC1F
                    endcase
                end
                5'b10000: begin 
                    if (Instr[7:4] == 4'b0011) begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000000000001111100; if (comment1)$display("[%s]fp c.cond",TAG); end//fp c.cond
                    else begin
                        case(funct)
                            6'b000000: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000000001101100; if (comment1)$display("[%s]fp add",TAG); end//fp add
                            6'b000001: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000000000000000; if (comment1)$display("[%s]fp sub",TAG); end//fp sub
                            6'b000010: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000000000110100; if (comment1)$display("[%s]fp mul",TAG); end//fp mul
                            6'b000011: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000000000010100; if (comment1)$display("[%s]fp div",TAG); end//fp div
                            6'b000101: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000000011011100; if (comment1)$display("[%s]fp abs",TAG); end//fp abs
                            6'b000110: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000001000010000; if (comment1)$display("[%s]fp mov",TAG); end//MOV.FMT
                            6'b000111: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000000001000000; if (comment1)$display("[%s]fp neg",TAG); end//fp neg
                            default: $display("Not an Instruction!");
                        endcase
                    end
                end
                5'b10001: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0100000001000100000; if (comment1)$display("[%s]fp cvt.s",TAG); end//CVT.S.FMT
                default: $display("Not an Instruction!");
            endcase
        end
		  6'b100000: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000101101010000100; if (comment1)$display("[%s]LB",TAG); end
		  6'b100001: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000101101010101100; if (comment1)$display("[%s]LH",TAG); end
		  6'b100010: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000101101010110100; if (comment1)$display("[%s]LWL",TAG); end
		  6'b100011: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000101101011110100; if (comment1)$display("[%s]LW",TAG); end
		  6'b110000: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000101101110100000; if (comment1)$display("[%s]LL",TAG); end
		  6'b100100: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000101101010101000; if (comment1)$display("[%s]LBU",TAG); end
		  6'b100101: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000101101010110000; if (comment1)$display("[%s]LHU",TAG); end
		  6'b100110: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000101101010111000; if (comment1)$display("[%s]LWR",TAG); end
		  6'b101000: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000011001010111100; if (comment1)$display("[%s]SB",TAG); end
		  6'b101001: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000011001011000000; if (comment1)$display("[%s]SH",TAG); end
		  6'b101010: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000011001011001000; if (comment1)$display("[%s]SWL",TAG); end
		  6'b101011: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000011001011000100; if (comment1)$display("[%s]SW",TAG); end
		  6'b111000: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000011101111011000; if (comment1)$display("[%s]SC",TAG); end
		  6'b101110: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000011001011001100; if (comment1)$display("[%s]SWR",TAG); end
		  
        6'b110001: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000101001011010100; if (comment1)$display("[%s]lwc1",TAG); end//LWC1
        6'b111001: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0000011001011100100; if (comment1)$display("[%s]swc1",TAG); end//SWC1
        6'b010100: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0001000001011101000; if (comment1)$display("[%s]beql",TAG); end//BEQL
        6'b010110: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0001000001011101100; if (comment1)$display("[%s]blezl",TAG); end//BLEZL
        6'b010101: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'b0001000001011110000; if (comment1)$display("[%s]bnel",TAG); end//BNEL
        default: begin {Link,RegDest,Jump,Branch,MemRead,MemWrite,ALUSrc,RegWrite,JumpRegister,SignOrZero,Syscall,ALUControl,MultRegAccess} = 19'd0; $display("Not an Instruction!"); end//default
    endcase
    $display("Decode[%s]: Instr=%x Instr_PC=%x Link1=%d, RegDest=%d, Jump=%d, Branch=%d, MemRead=%d, MemWrite=%d, ALUSrc=%d, RegWrite=%d, JumpRegister=%d,SignOrZero=%d,Syscall=%d,ALUControl=%x",TAG, Instr, Instr_PC, Link, RegDest, Jump, Branch, MemRead, MemWrite, ALUSrc, RegWrite, JumpRegister, SignOrZero, Syscall, ALUControl);
end


endmodule
