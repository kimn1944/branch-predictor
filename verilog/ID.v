`include "config.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:49:08 10/16/2013 
// Design Name: 
// Module Name:    ID2 
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
module ID(
    input CLK,
    input RESET,
	 //Instruction from Fetch
    input[31:0]Instr_IN,
	 //PC of instruction fetched
    input[31:0]Instr1_PC_IN,
    //PC+4 of instruction fetched (needed for various things)
    input[31:0]Instr1_PC_Plus4_IN,
    //Writeback stage [register to write]
	 input[4:0]WriteRegister1_IN,
	 //Data to write to register file
	 input[31:0]WriteData1_IN,
	 //Actually write to register file?
	 input RegWrite1_IN,
	 
	 //Alternate PC for next fetch (branch/jump destination)
    output reg [31:0]Alt_PC,
    //Actually use alternate PC
    output reg Request_Alt_PC, 
    //Instruction being passed to EXE [debug]
     output reg [31:0]Instr1_OUT,
    //PC of instruction being passed to EXE [debug]
     output reg [31:0]Instr1_PC_OUT,
     //OperandA passed to EXE
    output reg [31:0]OperandA1_OUT,
     //OperandB passed to EXE
    output reg [31:0]OperandB1_OUT,
     //RegisterA passed to EXE
    output reg [4:0]ReadRegisterA1_OUT,
     //RegisterB passed to EXE
    output reg [4:0]ReadRegisterB1_OUT,
     //Destination Register passed to EXE
    output reg [4:0]WriteRegister1_OUT,
     //Data to write to memory passed to EXE [for store]
     output reg [31:0]MemWriteData1_OUT,
     //we'll be writing to a register... passed to EXE
    output reg RegWrite1_OUT,
    //ALU control passed to EXE
    output reg [5:0]ALU_Control1_OUT,
    //This is a memory read (passed to EXE)
    output reg MemRead1_OUT,
    //This is a memory write (passed to EXE)
    output reg MemWrite1_OUT,
    //Shift amount [for ALU functions] (passed to EXE)
    output reg [4:0]ShiftAmount1_OUT,
    
`ifdef HAS_FORWARDING
    //Bypass inputs for calculations that have completed EXE
    input [4:0]     BypassReg1_EXEID,
    input [31:0]    BypassData1_EXEID,
    input               BypassValid1_EXEID,
	
    //Bypass inputs for loads from memory (and previous-instruction EXE outputs)
    input [4:0]     BypassReg1_MEMID,
    input [31:0]    BypassData1_MEMID,
    input               BypassValid1_MEMID,
`endif
	 
	 //Tell the simulator to process a system call
	 output reg SYS,
	 //Tell fetch to stop advancing the PC, and wait.
	 output WANT_FREEZE
    );


         wire[31:0] Instr1_IN;  
	 wire[31:0] Instr_PC_IN;
         wire[31:0] Instr_PC_Plus4_IN;
	 wire [5:0]	ALU_control1;	//async. ALU_Control output
	 wire			link1;			//whether this is a "And Link" instruction
	 wire			RegDst1;			//whether this instruction uses the "rd" register (Instr[15:11])
	 wire			jump1;			//whether we unconditionally jump
	 wire			branch1;			//whether we are branching
	 wire			MemRead1;		//whether this instruction is a load
	 wire			MemWrite1;		//whether this instruction is a store
	 /*verilator lint_off UNUSED */
	 //We don't need this now.
	 wire			ALUSrc1;			//whether this instruction uses an immediate
	 /*verilator lint_on UNUSED */
	 wire			RegWrite1;		//whether we want to write to a register with this instruction (do_writeback)
	 wire			jumpRegister_Flag1;	//this is a Jump Register function (also set for other functions; vestige of previous code)
	 wire			sign_or_zero_Flag1;	//If 1, we use sign-extended immediate; otherwise, 0-extended immediate.
	 wire			syscal1;			//If this instruction is a syscall
	 wire			comment1;
	 assign		comment1 = 1;
	 
	 wire			Request_Alt_PC1;	//Do we want to branch/jump?
	 wire	[31:0]	Alt_PC1;	//address to which we branch/jump
	 
	 wire [4:0]		RegA1;		//Register A
	 wire [4:0]		RegB1;		//Register B
	 wire [4:0]		WriteRegister1;	//Register to write
	 wire [31:0]	WriteRegisterRawVal1;
	 wire [31:0]	MemWriteData1;		//Data to write to memory
	 wire	[31:0]	OpA1;		//Operand A
	 wire [31:0]	OpB1;		//Operand B
	 
     wire [4:0]     rs1;     //also format1
     wire [31:0]    rsRawVal1;
     wire   [31:0]  rsval1;
     wire   [4:0]       rt1;
     wire [31:0]    rtRawVal1;
     wire   [31:0]  rtval1;
     wire [4:0]     rd1;
     wire [4:0]     shiftAmount1;
     wire [15:0]    immediate1;

	reg [2:0]	syscall_bubble_counter;
	 
     assign Instr1_IN = Instr_IN;
     assign Instr_PC_IN = Instr1_PC_IN;
     assign Instr_PC_Plus4_IN = Instr1_PC_Plus4_IN; 
     assign rs1 = Instr1_IN[25:21];
     assign rt1 = Instr1_IN[20:16];
     assign rd1 = Instr1_IN[15:11];
     assign shiftAmount1 = Instr1_IN[10:6];
     assign immediate1 = Instr1_IN[15:0];

//Begin branch/jump calculation
	
	wire [31:0] rsval_jump1;
	
`ifdef HAS_FORWARDING
RegValue3 RegJumpValue1 (
    .ReadRegister1(rs1), 
    .RegisterData1(rsRawVal1), 
    .WriteRegister1stPri1(BypassReg1_EXEID), 
    .WriteData1stPri1(BypassData1_EXEID),
	 .Valid1stPri1(BypassValid1_EXEID),
    .WriteRegister2ndPri1(BypassReg1_MEMID), 
    .WriteData2ndPri1(BypassData1_MEMID),
	 .Valid2ndPri1(BypassValid1_MEMID),
    .WriteRegister3rdPri1(WriteRegister1_IN), 
    .WriteData3rdPri1(WriteData1_IN),
	 .Valid3rdPri1(RegWrite1_IN),
    .Output1(rsval_jump1),
	 .comment(1'b0)
    );
`else
    assign rsval_jump1 = rsRawVal1;
`endif

NextInstructionCalculator NIA1 (
    .Instr_PC_Plus4(Instr_PC_Plus4_IN),
    .Instruction(Instr1_IN), 
    .Jump(jump1), 
    .JumpRegister(jumpRegister_Flag1), 
    .RegisterValue(rsval_jump1), 
    .NextInstructionAddress(Alt_PC1),
	 .Register(rs1)
    );

     wire [31:0]    signExtended_immediate1;
     wire [31:0]    zeroExtended_immediate1;
     
     assign signExtended_immediate1 = {{16{immediate1[15]}},immediate1};
     assign zeroExtended_immediate1 = {{16{1'b0}},immediate1};

compare branch_compare1 (
    .Jump(jump1), 
    .OpA(OpA1),
    .OpB(OpB1),
    .Instr_input(Instr1_IN), 
    .taken(Request_Alt_PC1)
    );
//End branch/jump calculation

//Handle pipelining
`ifdef HAS_FORWARDING
RegValue3 RegAValue1 (
    .ReadRegister1(rs1), 
    .RegisterData1(rsRawVal1), 
    .WriteRegister1stPri1(BypassReg1_EXEID), 
    .WriteData1stPri1(BypassData1_EXEID),
	 .Valid1stPri1(BypassValid1_EXEID),
    .WriteRegister2ndPri1(BypassReg1_MEMID), 
    .WriteData2ndPri1(BypassData1_MEMID),
	 .Valid2ndPri1(BypassValid1_MEMID),
    .WriteRegister3rdPri1(WriteRegister1_IN), 
    .WriteData3rdPri1(WriteData1_IN),
	 .Valid3rdPri1(RegWrite1_IN),
    .Output1(rsval1),
	 .comment(1'b0)
    );
RegValue3 RegBValue1 (
    .ReadRegister1(rt1), 
    .RegisterData1(rtRawVal1), 
    .WriteRegister1stPri1(BypassReg1_EXEID), 
    .WriteData1stPri1(BypassData1_EXEID),
     .Valid1stPri1(BypassValid1_EXEID),
    .WriteRegister2ndPri1(BypassReg1_MEMID), 
    .WriteData2ndPri1(BypassData1_MEMID),
     .Valid2ndPri1(BypassValid1_MEMID),
    .WriteRegister3rdPri1(WriteRegister1_IN), 
    .WriteData3rdPri1(WriteData1_IN),
     .Valid3rdPri1(RegWrite1_IN),
    .Output1(rtval1),
	 .comment(1'b0)
    );
`else
assign rsval1 = rsRawVal1;
assign rtval1 = rtRawVal1;
`endif


	assign WriteRegister1 = RegDst1?rd1:(link1?5'd31:rt1);
	//assign MemWriteData1 = Reg[WriteRegister1];		//What will be written by MEM
`ifdef HAS_FORWARDING
RegValue3 RegWriteValue1 (
    .ReadRegister1(WriteRegister1), 
    .RegisterData1(WriteRegisterRawVal1), 
    .WriteRegister1stPri1(BypassReg1_EXEID), 
    .WriteData1stPri1(BypassData1_EXEID),
	 .Valid1stPri1(BypassValid1_EXEID),
    .WriteRegister2ndPri1(BypassReg1_MEMID), 
    .WriteData2ndPri1(BypassData1_MEMID),
	 .Valid2ndPri1(BypassValid1_MEMID),
    .WriteRegister3rdPri1(WriteRegister1_IN), 
    .WriteData3rdPri1(WriteData1_IN),
	 .Valid3rdPri1(RegWrite1_IN),
    .Output1(MemWriteData1),
	 .comment(1'b0)
    );
`else
    assign MemWriteData1 = WriteRegisterRawVal1;
`endif

	//OpA will always be rsval, although it might be unused.
	assign OpA1 = link1?0:rsval1;
	assign RegA1 = link1?5'b00000:rs1;
	//When we branch/jump and link, OpB needs to store return address
	//Otherwise, if we have writeregister==rd, then rt is used for OpB.
	//if writeregister!=rd, then writeregister ==rt, and we use immediate instead.
	assign OpB1 = branch1?(link1?(Instr_PC_Plus4_IN+4):rtval1):(RegDst1?rtval1:(sign_or_zero_Flag1?signExtended_immediate1:zeroExtended_immediate1));
	assign RegB1 = RegDst1?rt1:5'd0;
	

RegFile RegFile (
    .CLK(CLK), 
    .RESET(RESET), 
    .RegA1(rs1),
    .RegB1(rt1),
    .RegC1(WriteRegister1), 
    .DataA1(rsRawVal1),
    .DataB1(rtRawVal1),
    .DataC1(WriteRegisterRawVal1),
    .WriteReg1(WriteRegister1_IN),
    .WriteData1(WriteData1_IN),
    .Write1(RegWrite1_IN)
    );
	 
	 reg FORCE_FREEZE;
	 reg INHIBIT_FREEZE;
     assign WANT_FREEZE = ((FORCE_FREEZE | syscal1) && !INHIBIT_FREEZE);



always @(posedge CLK or negedge RESET) begin
	if(!RESET) begin
		Alt_PC <= 0;
		Request_Alt_PC <= 0;
		Instr1_OUT <= 0;
		OperandA1_OUT <= 0;
		OperandB1_OUT <= 0;
		ReadRegisterA1_OUT <= 0;
		ReadRegisterB1_OUT <= 0;
		WriteRegister1_OUT <= 0;
		MemWriteData1_OUT <= 0;
		RegWrite1_OUT <= 0;
		ALU_Control1_OUT <= 0;
		MemRead1_OUT <= 0;
		MemWrite1_OUT <= 0;
		ShiftAmount1_OUT <= 0;
		Instr1_PC_OUT <= 0;
		SYS <= 0;
		syscall_bubble_counter <= 0;
		FORCE_FREEZE <= 0;
		INHIBIT_FREEZE <= 0;
	$display("ID:RESET");
	end else begin
            Alt_PC <= Alt_PC1;
            Request_Alt_PC <= Request_Alt_PC1;
			$display("ID:evaluation SBC=%d; syscal1=%d",syscall_bubble_counter,syscal1);
			case (syscall_bubble_counter)
				5,4,3: begin
					//$display("ID:Decrement sbc");
					syscall_bubble_counter <= syscall_bubble_counter - 3'b1;
					end
				2: begin
					//$display("ID:Decrement sbc, , send sys");
					syscall_bubble_counter <= syscall_bubble_counter - 3'b1;
					SYS <= (ALU_control1 != 6'b101000) && (ALU_control1 != 6'b110110);  //We do a flush on LL/SC, but don't need to tell sim_main.
					INHIBIT_FREEZE <=1;
					end
				1: begin
					//$display("ID:Decrement sbc, inhibit freeze, clear sys");
					syscall_bubble_counter <= syscall_bubble_counter - 3'b1;
					SYS <= 0;
					INHIBIT_FREEZE <=0;
					end
				0: begin
					//$display("ID:reenable freezes");
					INHIBIT_FREEZE <=0;
					end
			endcase
			if(syscal1 && (syscall_bubble_counter==0)) begin
				//$display("ID:init SBC");
				syscall_bubble_counter <= 4;
			end
			//$display("sc1,sbc=%d",{syscal1,syscall_bubble_counter});
			case ({syscal1,syscall_bubble_counter})
				8,13,12,11,
				9,1: begin	//9 and 1 depend on multiple syscall in a row
					//$display("ID:send nop");
					Instr1_OUT <= (Instr1_IN==32'hc)?Instr1_IN:0; //We need to propagate the syscall to MEM to flush the cache!
					OperandA1_OUT <= 0;
					OperandB1_OUT <= 0;
					ReadRegisterA1_OUT <= 0;
					ReadRegisterB1_OUT <= 0;
					WriteRegister1_OUT <= 0;
					MemWriteData1_OUT <= 0;
					RegWrite1_OUT <= 0;
					ALU_Control1_OUT <= (Instr1_IN==32'hc)?ALU_control1:0;
					MemRead1_OUT <= 0;
					MemWrite1_OUT <= 0;
					ShiftAmount1_OUT <= 0;
					end
				10,
				0: begin
					//$display("ID: send instr");
                    Instr1_OUT <= Instr1_IN;
                    OperandA1_OUT <= OpA1;
                    OperandB1_OUT <= OpB1;
                    ReadRegisterA1_OUT <= RegA1;
                    ReadRegisterB1_OUT <= RegB1;
                    WriteRegister1_OUT <= WriteRegister1;
                    MemWriteData1_OUT <= MemWriteData1;
                    RegWrite1_OUT <= (WriteRegister1!=5'd0)?RegWrite1:1'd0;
                    ALU_Control1_OUT <= ALU_control1;
                    MemRead1_OUT <= MemRead1;
                    MemWrite1_OUT <= MemWrite1;
                    ShiftAmount1_OUT <= shiftAmount1;
                    Instr1_PC_OUT <= Instr_PC_IN;
					end
			endcase
			/*if (RegWrite_IN) begin
				Reg[WriteRegister_IN] <= WriteData_IN;
				$display("IDWB:Reg[%d]=%x",WriteRegister_IN,WriteData_IN);
			end*/
			if(comment1) begin
                $display("ID1:Instr=%x,Instr_PC=%x,Req_Alt_PC=%d:Alt_PC=%x;SYS=%d(%d)",Instr1_IN,Instr_PC_IN,Request_Alt_PC1,Alt_PC1,syscal1,syscall_bubble_counter);
                //$display("ID1:A:Reg[%d]=%x; B:Reg[%d]=%x; Write?%d to %d",RegA1, OpA1, RegB1, OpB1, (WriteRegister1!=5'd0)?RegWrite1:1'd0, WriteRegister1);
                //$display("ID1:ALU_Control=%x; MemRead=%d; MemWrite=%d (%x); ShiftAmount=%d",ALU_control1, MemRead1, MemWrite1, MemWriteData1, shiftAmount1);
			end
	end
end
	
    Decoder #(
    .TAG("1")
    )
    Decoder1 (
    .Instr(Instr1_IN), 
    .Instr_PC(Instr_PC_IN), 
    .Link(link1), 
    .RegDest(RegDst1), 
    .Jump(jump1), 
    .Branch(branch1), 
    .MemRead(MemRead1), 
    .MemWrite(MemWrite1), 
    .ALUSrc(ALUSrc1), 
    .RegWrite(RegWrite1), 
    .JumpRegister(jumpRegister_Flag1), 
    .SignOrZero(sign_or_zero_Flag1), 
    .Syscall(syscal1), 
    .ALUControl(ALU_control1),
/* verilator lint_off PINCONNECTEMPTY */
    .MultRegAccess(),   //Needed for out-of-order
/* verilator lint_on PINCONNECTEMPTY */
     .comment1(1'b1)
    );

endmodule
