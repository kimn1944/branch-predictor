`include "config.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:09:45 10/18/2013 
// Design Name: 
// Module Name:    EXE2 
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
module EXE(
    input CLK,
    input RESET,
	 //Current instruction [debug]
    input [31:0] Instr1_IN,
    //Current instruction's PC [debug]
    input [31:0] Instr1_PC_IN,
`ifdef HAS_FORWARDING
    //Register A (needed for forwarding)
    input [4:0] RegisterA1_IN,
`endif
    //Operand A (if already known)
    input [31:0] OperandA1_IN,
`ifdef HAS_FORWARDING
    //Register B (needed for forwarding)
    input [4:0] RegisterB1_IN,
`endif
    //Operand B (if already known)
    input [31:0] OperandB1_IN,
    input [31:0] Alt_PC,
    input Request_Alt_PC,
    //Destination register
    input [4:0] WriteRegister1_IN,
    //Data in MemWrite1 register
    input [31:0] MemWriteData1_IN,
    //We do a register write
    input RegWrite1_IN,
    //ALU Control signal
    input [5:0] ALU_Control1_IN,
    //We read from memory (passed to MEM)
    input MemRead1_IN,
    //We write to memory (passed to MEM)
    input MemWrite1_IN,
    //Shift amount (needed for shift operations)
    input [4:0] ShiftAmount1_IN,
    //Instruction [debug] to MEM
    output reg [31:0] Instr1_OUT,
    //PC [debug] to MEM
    output reg [31:0] Instr1_PC_OUT,
    //Our ALU results to MEM
    output reg [31:0] ALU_result1_OUT,
    output Request_Alt_PC1,
    output [31:0]  Alt_PC1,
    //What register gets the data (or store from) to MEM
    output reg [4:0] WriteRegister1_OUT,
    //Data in WriteRegister1 (if known) to MEM
    output reg [31:0] MemWriteData1_OUT,
    //Whether we will write to a register
    output reg RegWrite1_OUT,
    //ALU Control (actually used by MEM)
    output reg [5:0] ALU_Control1_OUT,
    //We need to read from MEM (passed to MEM)
    output reg MemRead1_OUT,
    //We need to write to MEM (passed to MEM)
    output reg MemWrite1_OUT
    
`ifdef HAS_FORWARDING
    ,
        
    //Bypass inputs for calculations that have completed MEM
	 input[4:0] BypassReg1_MEMEXE,
	 input[31:0] BypassData1_MEMEXE,
	 input BypassValid1_MEMEXE,
	 
    //Bypass outputs for calculations that have completed EXE
	 output [31:0] ALU_result_async1,
	 output ALU_result_async_valid1
`endif
    );
	 

	 wire [31:0] A1;
	 wire [31:0] B1;
	 wire[31:0]ALU_result1;
	 wire comment1;
	 assign comment1 = 1;
	 
`ifdef HAS_FORWARDING
RegValue2 RegAValue(
    .ReadRegister1(RegisterA1_IN), 
    .RegisterData1(OperandA1_IN), 
    .WriteRegister1stPri1(WriteRegister1_OUT), 
    .WriteData1stPri1(ALU_result1_OUT), 
    .Valid1stPri1(RegWrite1_OUT && !(MemRead1_OUT || MemWrite1_OUT)), 
    .WriteRegister2ndPri1(BypassReg1_MEMEXE), 
    .WriteData2ndPri1(BypassData1_MEMEXE),
    .Valid2ndPri1(BypassValid1_MEMEXE),
    .Output1(A1),
	 .comment(1'b0)
    );

RegValue2 RegBValue(
    .ReadRegister1(RegisterB1_IN), 
    .RegisterData1(OperandB1_IN), 
    .WriteRegister1stPri1(WriteRegister1_OUT), 
    .WriteData1stPri1(ALU_result1_OUT), 
    .Valid1stPri1(RegWrite1_OUT && !(MemRead1_OUT || MemWrite1_OUT)), 
    .WriteRegister2ndPri1(BypassReg1_MEMEXE), 
    .WriteData2ndPri1(BypassData1_MEMEXE),
    .Valid2ndPri1(BypassValid1_MEMEXE), 
    .Output1(B1),
	 .comment(1'b0)
    );
`else
assign A1 = OperandA1_IN;
assign B1 = OperandB1_IN;
`endif

reg [31:0] HI/*verilator public*/;
reg [31:0] LO/*verilator public*/;
wire [31:0] HI_new1;
wire [31:0] LO_new1;
wire [31:0] new_HI;
wire [31:0] new_LO;

assign new_HI=HI_new1;
assign new_LO=LO_new1;


ALU ALU1(
    .aluResult(ALU_result1),
    .HI_OUT(HI_new1),
    .LO_OUT(LO_new1),
    .HI_IN(HI),
    .LO_IN(LO),
    .A(A1), 
    .B(B1), 
    .ALU_control(ALU_Control1_IN), 
    .shiftAmount(ShiftAmount1_IN), 
    .CLK(!CLK)
    );


wire [31:0] MemWriteData1;

`ifdef HAS_FORWARDING
RegValue2 MemoryDataValue(
    .ReadRegister1(WriteRegister1_IN), 
    .RegisterData1(MemWriteData1_IN), 
    .WriteRegister1stPri1(WriteRegister1_OUT), 
    .WriteData1stPri1(ALU_result1_OUT), 
    .Valid1stPri1(RegWrite1_OUT && !(MemRead1_OUT || MemWrite1_OUT)), 
    .WriteRegister2ndPri1(BypassReg1_MEMEXE), 
    .WriteData2ndPri1(BypassData1_MEMEXE),
    .Valid2ndPri1(BypassValid1_MEMEXE), 
    .Output1(MemWriteData1),
	 .comment(1'b0)
    );

	assign ALU_result_async1 = ALU_result1;
	assign ALU_result_async_valid1 = RegWrite1_IN && !(MemRead1_IN || MemWrite1_IN);
`else
assign MemWriteData1 = MemWriteData1_IN;
`endif

always @(posedge CLK or negedge RESET) begin
	if(!RESET) begin
		Instr1_OUT <= 0;
		Instr1_PC_OUT <= 0;
		ALU_result1_OUT <= 0;
		WriteRegister1_OUT <= 0;
		MemWriteData1_OUT <= 0;
		RegWrite1_OUT <= 0;
		ALU_Control1_OUT <= 0;
		MemRead1_OUT <= 0;
		MemWrite1_OUT <= 0;
                Request_Alt_PC1 <=0;
                Alt_PC1 <=0;
		$display("EXE:RESET");
	end else if(CLK) begin
       HI <= new_HI;
       LO <= new_LO;
            Instr1_OUT <= Instr1_IN;
            Instr1_PC_OUT <= Instr1_PC_IN;
            ALU_result1_OUT <= ALU_result1;
            WriteRegister1_OUT <= WriteRegister1_IN;
            MemWriteData1_OUT <= MemWriteData1;
            RegWrite1_OUT <= RegWrite1_IN;
            ALU_Control1_OUT <= ALU_Control1_IN;
            MemRead1_OUT <= MemRead1_IN;
            MemWrite1_OUT <= MemWrite1_IN;
            Request_Alt_PC1 <= Request_Alt_PC;
            Alt_PC1 <= Alt_PC;
			if(comment1) begin
                $display("EXE:Instr1=%x,Instr1_PC=%x,ALU_result1=%x; Write?%d to %d",Instr1_IN,Instr1_PC_IN,ALU_result1, RegWrite1_IN, WriteRegister1_IN);
                //$display("EXE:ALU_Control1=%x; MemRead1=%d; MemWrite1=%d (Data:%x)",ALU_Control1_IN, MemRead1_IN, MemWrite1_IN, MemWriteData1);
                //$display("EXE:OpA1=%x; OpB1=%x; HI=%x; LO=%x", A1, B1, new_HI,new_LO);
			end
	end
end

endmodule
