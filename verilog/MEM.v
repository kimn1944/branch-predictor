`include "config.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:17:07 10/18/2013 
// Design Name: 
// Module Name:    MEM2 
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
module MEM(
    input CLK,
    input RESET,
    //Currently executing instruction [debug only]
    input [31:0] Instr1_IN,
    //PC of executing instruction [debug only]
    input [31:0] Instr1_PC_IN,
    input Request_Alt_PC,
    input[31:0] Alt_PC,
    //Output of ALU (contains address to access, or data enroute to writeback)
    input [31:0] ALU_result1_IN,
    //What register will get our ultimate outputs
    input [4:0] WriteRegister1_IN,
    //What data gets written to memory
    input [31:0] MemWriteData1_IN,
    //This instruction is a register write?
    input RegWrite1_IN,
    //ALU control value (used to also specify the type of memory operation)
    input [5:0] ALU_Control1_IN,
    //The instruction requests a load
    input MemRead1_IN,
    //The instruction requests a store
    input MemWrite1_IN,
    //What register we are writing to
    output reg [4:0] WriteRegister1_OUT,
    //Actually do the write
    output reg RegWrite1_OUT,
    //And what data
    output reg [31:0] WriteData1_OUT,	 
    output reg [31:0] data_write_2DM,
    output [31:0] data_address_2DM,
    output  [31:0] Alt_PC1,
    output  Request_Alt_PC1,
	 output reg [1:0] data_write_size_2DM,
    input [31:0] data_read_fDM,
	 output MemRead_2DM,
	 output MemWrite_2DM

`ifdef HAS_FORWARDING
    ,
    output [31:0] WriteData1_async
`endif

    );


          reg [31:0]  Alt_PC2;
          reg Request_Alt_PC2;	 
	 //Variables for Memory Module Inputs/Outputs:
	 //ALU_result == Memory Address to access
	 //MemRead (obvious)
	 //MemWrite (obvious)
	 //ALU_control (obvious)
	 wire [31:0] MemoryData1;	//Used for LWL, LWR (existing content in register) and for writing (data to write)
	 wire [31:0] MemoryData;
	 //wire [31:0] MemoryReadData;	//Data read in from memory (and merged appropriate if LWL, LWR)
	 reg [31:0]	 data_read_aligned;
	 
	 //Word-aligned address for reads
     wire [31:0] MemReadAddress;
     //Not always word-aligned address for writes (SWR has issues with this)
     reg [31:0] MemWriteAddress;

	 wire MemWrite;
	 wire MemRead;
	 
	 wire [31:0] ALU_result;
	 
	 wire [5:0] ALU_Control;
	 
    assign MemWrite = MemWrite1_IN;
    assign MemRead = MemRead1_IN;
    assign ALU_result = ALU_result1_IN;
    assign ALU_Control = ALU_Control1_IN;
    assign MemoryData = MemoryData1;
 
	 assign MemReadAddress = {ALU_result[31:2],2'b00};
	 
	 assign data_address_2DM = MemWrite?MemWriteAddress:MemReadAddress;	//Reads are always aligned; writes may be unaligned
	 
	 assign MemRead_2DM = MemRead;
    assign MemWrite_2DM = MemWrite;
	 
	 
     reg [31:0]WriteData1;
     
	 wire comment1;
	 assign comment1 = 1;







	 

always @(data_read_fDM) begin
	//$display("MEM Received:data_read_fDM=%x",data_read_fDM);
	data_read_aligned = MemoryData;
	//$display("Updated DRA");
	MemWriteAddress = ALU_result;
	case(ALU_Control)
		6'b101101: begin
`ifdef INCLUDE_MEM_CONTENT
            //LWL   (Load Word Left)
            case (ALU_result[1:0])
			0: data_read_aligned = data_read_fDM;		//Aligned access; read everything
            1:  data_read_aligned[31:8] = data_read_fDM[23:0];	//Mem:[3,2,1,0] => [2,1,0,8'h00]
            2:  data_read_aligned[31:16] = data_read_fDM[15:0]; //Mem: [3,2,1,0] => [1,0,16'h0000]
            3:  data_read_aligned[31:24] = data_read_fDM[7:0];	//Mem: [3,2,1,0] => [0,24'h000000]

			endcase
			data_write_size_2DM = 0;
`else
            //TODO:LWL
`endif
		end
		6'b101110: begin
`ifdef INCLUDE_MEM_CONTENT
            //LWR (Load Word Right)
			case (ALU_result[1:0])
            0:  data_read_aligned[7:0] = data_read_fDM[31:24];	//Mem:[3,2,1,0] => [2,1,0,8'h00]
            1:  data_read_aligned[15:0] = data_read_fDM[31:16]; //Mem: [3,2,1,0] => [1,0,16'h0000]
            2:  data_read_aligned[23:0] = data_read_fDM[31:8];	//Mem: [3,2,1,0] => [0,24'h000000]
				3: data_read_aligned = data_read_fDM;		//Aligned access; read everything
			endcase
			data_write_size_2DM = 0;
`else
            //TODO:LWR
`endif
		end
		6'b100001: begin
`ifdef INCLUDE_MEM_CONTENT
			//LB (Load byte and sign-extend it)
			case (ALU_result[1:0])
				0: data_read_aligned={{24{data_read_fDM[31]}},data_read_fDM[31:24]};
				1: data_read_aligned={{24{data_read_fDM[23]}},data_read_fDM[23:16]};
				2: data_read_aligned={{24{data_read_fDM[15]}},data_read_fDM[15:8]};
				3: data_read_aligned={{24{data_read_fDM[7]}},data_read_fDM[7:0]};
			endcase
			data_write_size_2DM = 0;
`else
            //TODO:LB
`endif
		end
		6'b101011: begin
`ifdef INCLUDE_MEM_CONTENT
			//LH (Load halfword)
			case( ALU_result[1:0] )
				0:data_read_aligned={{16{data_read_fDM[31]}},data_read_fDM[31:16]};
				2:data_read_aligned={{16{data_read_fDM[15]}},data_read_fDM[15:0]};
			endcase
			data_write_size_2DM=0;
`else
            //TODO:LH
`endif
		end
		6'b101010: begin
`ifdef INCLUDE_MEM_CONTENT
			//LBU (Load byte unsigned)
			case (ALU_result[1:0])
				0: data_read_aligned={{24{1'b0}},data_read_fDM[31:24]};
				1: data_read_aligned={{24{1'b0}},data_read_fDM[23:16]};
				2: data_read_aligned={{24{1'b0}},data_read_fDM[15:8]};
				3: data_read_aligned={{24{1'b0}},data_read_fDM[7:0]};
			endcase
			data_write_size_2DM = 0;
`else
            //TODO:LBU
`endif
		end
		6'b101100: begin
`ifdef INCLUDE_MEM_CONTENT
			//LHU (Load halfword unsigned)
			case( ALU_result[1:0] )
				0:data_read_aligned={{16{1'b0}},data_read_fDM[31:16]};
				2:data_read_aligned={{16{1'b0}},data_read_fDM[15:0]};
			endcase
			data_write_size_2DM=0;
`else
            //TODO:LHU
`endif
		end
		6'b111101, 6'b101000, 6'd0, 6'b110101: begin	//LW, LL, NOP, LWC1
			data_read_aligned = data_read_fDM;
			data_write_size_2DM=0;
		end
		6'b101111: begin	//SB
			data_write_size_2DM=1;
`ifdef INCLUDE_MEM_CONTENT
			data_write_2DM[7:0] = MemoryData[7:0];
`else
            //TODO:SB
            //Set data_write_2DM appropriately
`endif
		end
		6'b110000: begin	//SH
			data_write_size_2DM=2;
`ifdef INCLUDE_MEM_CONTENT
			data_write_2DM[15:0] = MemoryData[15:0];
`else
            //TODO:SH
            //Set data_write_2DM appropriately
`endif
		end
		6'b110001, 6'b110110: begin	//SW/SC
			data_write_size_2DM=0;
`ifdef INCLUDE_MEM_CONTENT
			data_write_2DM = MemoryData;
`else
            //TODO:SW
            //Set data_write_2DM appropriately
`endif
		end
		6'b110010: begin	//SWL
`ifdef INCLUDE_MEM_CONTENT
			MemWriteAddress = ALU_result;
			case( ALU_result[1:0] )
				0: begin data_write_2DM = MemoryData; data_write_size_2DM=0; end
				1: begin data_write_2DM[23:0] = MemoryData[31:8]; data_write_size_2DM=3; end
				2: begin data_write_2DM[15:0] = MemoryData[31:16]; data_write_size_2DM=2; end
				3: begin data_write_2DM[7:0] = MemoryData[31:24]; data_write_size_2DM=1; end
			endcase
`else
            //TODO:SWL
            //Set MemWriteAddress, data_write_2DM and data_write_size_2DM appropriately
`endif
		end
		6'b110011: begin	//SWR
`ifdef INCLUDE_MEM_CONTENT
			MemWriteAddress = MemReadAddress;
			case( ALU_result[1:0] )
				//TODO: this may be wrong. It needs to be tested.
				0: begin data_write_2DM[7:0] = MemoryData[7:0]; data_write_size_2DM=1; end
				1: begin data_write_2DM[15:0] = MemoryData[15:0]; data_write_size_2DM=2; end
				2: begin data_write_2DM[23:0] = MemoryData[23:0]; data_write_size_2DM=3; end
				3: begin data_write_2DM = MemoryData; data_write_size_2DM=0; end
			endcase
`else
            //TODO:SWR
            //Set MemWriteAddress, data_write_2DM and data_write_size_2DM appropriately
`endif
		end
		default: begin
		  //If it's not a real memory istruction, do something somewhat related?
			data_read_aligned = data_read_fDM;
			data_write_size_2DM=0;
		end
	endcase
    WriteData1 = MemRead1_IN?data_read_aligned:ALU_result1_IN;
`ifdef INCLUDE_MEM_CONTENT
`else
    //Since it's not set elsewhere (that's your job), we'll set a dummy value here:
    data_write_2DM=32'hCAFEDEAD;
`endif
end

`ifdef HAS_FORWARDING
RegValue1 MemoryDataValue(
    .ReadRegister1(WriteRegister1_IN), 
    .RegisterData1(MemWriteData1_IN), 
    .WriteRegister1stPri1(WriteRegister1_OUT), 
    .WriteData1stPri1(WriteData1_OUT), 
    .Valid1stPri1(RegWrite1_OUT), 
    .Output1(MemoryData1), 
    .comment(1'b0)
    );
	 
	 assign WriteData1_async = WriteData1;
`else
assign MemoryData1 = MemWriteData1_IN;
`endif
	 
	 /* verilator lint_off UNUSED */
	 reg [31:0] Instr1_OUT;
	 reg [31:0] Instr1_PC_OUT;
     /* verilator lint_on UNUSED */

always @(posedge CLK or negedge RESET) begin
	if(!RESET) begin
		Instr1_OUT <= 0;
		Instr1_PC_OUT <= 0;
		WriteRegister1_OUT <= 0;
		RegWrite1_OUT <= 0;
		WriteData1_OUT <= 0;
                Request_Alt_PC2 <= 1'b0;
                Alt_PC2 <= 32'b0;
                Request_Alt_PC1 <=1'b0;
                Alt_PC1 <=32'b0;
	end else if(CLK) begin 
			Instr1_OUT <= Instr1_IN;
			Instr1_PC_OUT <= Instr1_PC_IN;
			WriteRegister1_OUT <= WriteRegister1_IN;
			RegWrite1_OUT <= RegWrite1_IN;
			WriteData1_OUT <= WriteData1;
                        $display("MEM: Request_Alt_PC=%X",Request_Alt_PC);
			if(comment1) begin
				$display("MEM:Instr1_OUT=%x,Instr1_PC_OUT=%x,WriteData1=%x; Write?%d to %d",Instr1_IN,Instr1_PC_IN,WriteData1, RegWrite1_IN, WriteRegister1_IN);
				$display("MEM:data_address_2DM=%x; data_write_2DM(%d)=%x(%d); data_read_fDM(%d)=%x",data_address_2DM,MemWrite_2DM,data_write_2DM,data_write_size_2DM,MemRead_2DM,data_read_fDM);
			end
	end
end

endmodule
