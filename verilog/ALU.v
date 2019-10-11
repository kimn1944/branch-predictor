`include "config.v"
//-----------------------------------------
//               ALU Module
//-----------------------------------------
module ALU(
    input CLK,
    output reg [31:0] aluResult,
   output reg [31:0] HI_OUT,
   output reg [31:0] LO_OUT,
   input [31:0] HI_IN,
   input [31:0] LO_IN,
    input [31:0] A,
    input [31:0] B,
    input [5:0] ALU_control,
    input [4:0] shiftAmount);

   reg       [63: 0] temp;
   //reg       [ 4: 0] i;

                        /* verilator lint_off BLKSEQ */

   always @(posedge CLK) begin
      case( ALU_control ) 
			//There might be an issue here: LWC1, LWC0 are supposed to be identical, I thought. Also, LWCz is not valid when z==0.
                    6'b000000,6'b000010,6'b000001,6'b000011,6'b110111,6'b110101:begin aluResult = A+B; $display("ALU:addx,lwc1"); end//add,addi,addiu,addu,lwc1,syscall
                    6'b111101,6'b101000,6'b100001,6'b101010,6'b101011,6'b101100,6'b101101,6'b101110,6'b101111,6'b110000,6'b110001,6'b110110,6'b110010,6'b110011,6'b111001:begin
						  //LW, LL; LB; SLTI, SLTIU, LBU; LH; LHU; LWL; LWR; SB; SH; SW, SC; SWL; SRL; SWC1
			aluResult = A+{{16{B[15]}},B[15:0]};
				$display("ALU:Load,Store,...");
		    end//lw,lb,lbu,lh,lhu,lwl,lwr,sb,sh,sw,swl,swr,swc
                    6'b000100:begin aluResult = A & B; $display("ALU:and,andi"); end//and, andi OK
                    6'b000101://div
                        begin
                            if(B!=0)begin
												//TODO: I don't think that this will work for A and B being negative. For example: -1/-1
												//0xFFFFFFFF / 0xFFFFFFFF = 0x00000001
                                    LO_OUT[31] = A[31] | B[31];	//LO[31]=1
                                    LO_OUT[30:0] = A[30:0] / B[30:0];	//0x7FFFFFFF / 0x7FFFFFFF = 0x00000001.
												//LO[31:0]=0x80000000 | 0x00000001 = 0x80000001  !!!!!
                                    HI_OUT[30:0] = A[30:0] % B[30:0]; //0x7FFFFFFF / 0x7FFFFFFF = 0x00000000.

												LO_OUT = $signed(A) / $signed(B);
												HI_OUT = $signed(A) % $signed(B);
                                    //LO[31] = A[31] ^ B[31];
                                    //LO[30:0] = A[30:0] / B[30:0];
												//HI[31] = B[31];
                                    //HI[30:0] = A[30:0] % B[30:0];
												$display("ALU:div");
                            end
                        end
                    6'b000110://divu OK
                        begin
                            if(B!=0)begin
                                    LO_OUT = A / B;
                                    HI_OUT = A % B;
                            end
									 $display("ALU:divu");
                        end
                    6'b001000:begin aluResult = {B[15:0],16'b0}; $display("ALU:lui"); end//lui OK
                    6'b001001:begin aluResult = HI_IN; $display("ALU:mfhi"); end//mfhi OK
                    6'b001010:begin aluResult = LO_IN; $display("ALU:mflo"); end//mflo OK
                    6'b001011:begin HI_OUT = A; $display("ALU:mthi"); end//mthi OK
                    6'b001100:begin LO_OUT = A; $display("ALU:mtlo"); end//mtlo OK
                    6'b001101://mult//multu  [NEED to check signed/unsigned]
                        begin
                            temp[63:0] = A * B;
                            //HI = 32'b0;
									 HI_OUT = temp[63:32];
                            //LO = 32'b0;
									 LO_OUT = temp[31:0];
									 $display("ALU:mult,multu");
                        end
                    6'b001111:begin aluResult = ~(A | B); $display("ALU:nor"); end//nor	OK
                    6'b010000:begin aluResult = A | B; $display("ALU:or,ori"); end//or,ori	OK
                    6'b010011:begin aluResult = B << shiftAmount; $display("ALU:sll,NOP"); end//sll,NOP [NEED to check operands]
                    6'b010100:begin aluResult = B << A; $display("ALU:sllv"); end//sllv [Need to check operands]
                    6'b010101://slt		// Set on A < B	OK
                        begin
                            if( A[31] < B[31] ) aluResult = 0;	//B is negative, A isn't
                            else if( A[30:0] > B[30:0] ) aluResult = 0;	//A is greater than B
                            else if( A == B ) aluResult = 0;	//A is equal to B
                            else aluResult = 1;	//A must be less than b
									 $display("ALU:slt");
                        end
		    6'b111111://sltu		//Set on A < B  OK
                        begin
                            if( A[31:0] > B[31:0] ) aluResult = 0;	//A is greater than B
                            else if( A == B ) aluResult = 0;	//A is equal to B
                            else aluResult = 1;	//A must be less than B
									 $display("ALU:sltu");
                        end
                    6'b011001://sra	[NEED to verify that this operates the way it seems it should]
                        begin
                            temp[32]=B[31];
                            temp[31:0] = {B[31:0] >> shiftAmount};
		            temp[31]=temp[32];
			    if(shiftAmount>=1)temp[30]=temp[32];
			    if(shiftAmount>=2)temp[29]=temp[32];
			    if(shiftAmount>=3)temp[28]=temp[32];
			    if(shiftAmount>=4)temp[27]=temp[32];
			    if(shiftAmount>=5)temp[26]=temp[32];
			    if(shiftAmount>=6)temp[25]=temp[32];
			    if(shiftAmount>=7)temp[24]=temp[32];
			    if(shiftAmount>=8)temp[23]=temp[32];
			    if(shiftAmount>=9)temp[22]=temp[32];
			    if(shiftAmount>=10)temp[21]=temp[32];
			    if(shiftAmount>=11)temp[20]=temp[32];
			    if(shiftAmount>=12)temp[19]=temp[32];
			    if(shiftAmount>=13)temp[18]=temp[32];
			    if(shiftAmount>=14)temp[17]=temp[32];
			    if(shiftAmount>=15)temp[16]=temp[32];
			    if(shiftAmount>=16)temp[15]=temp[32];
			    if(shiftAmount>=17)temp[14]=temp[32];
			    if(shiftAmount>=18)temp[13]=temp[32];
			    if(shiftAmount>=19)temp[12]=temp[32];
			    if(shiftAmount>=20)temp[11]=temp[32];
			    if(shiftAmount>=21)temp[10]=temp[32];
			    if(shiftAmount>=22)temp[9]=temp[32];
			    if(shiftAmount>=23)temp[8]=temp[32];
			    if(shiftAmount>=24)temp[7]=temp[32];
			    if(shiftAmount>=25)temp[6]=temp[32];
			    if(shiftAmount>=26)temp[5]=temp[32];
			    if(shiftAmount>=27)temp[4]=temp[32];
			    if(shiftAmount>=28)temp[3]=temp[32];
			    if(shiftAmount>=29)temp[2]=temp[32];
			    if(shiftAmount>=30)temp[1]=temp[32];
			    if(shiftAmount>=31)temp[0]=temp[32];
                            aluResult = temp[31:0];
									 $display("ALU:sra");
                        end
                    6'b011010://srav	[Why is this different than SRA; Why can't we load A[4:0] into shiftAmount or set shiftAmount into A[4:0]??]
                        begin
                            temp[32]=B[31];
                            temp[31:0] = {B[31:0] >> (A[4:0])};
									 temp[31]=temp[32];
									 if(1<=A[4:0])temp[30]=temp[32];
									 if(2<=A[4:0])temp[29]=temp[32];
									 if(3<=A[4:0])temp[28]=temp[32];
									 if(4<=A[4:0])temp[27]=temp[32];
									 if(5<=A[4:0])temp[26]=temp[32];
									 if(6<=A[4:0])temp[25]=temp[32];
									 if(7<=A[4:0])temp[24]=temp[32];
									 if(8<=A[4:0])temp[23]=temp[32];
									 if(9<=A[4:0])temp[22]=temp[32];
									 if(10<=A[4:0])temp[21]=temp[32];
									 if(11<=A[4:0])temp[20]=temp[32];
									 if(12<=A[4:0])temp[19]=temp[32];
									 if(13<=A[4:0])temp[18]=temp[32];
									 if(14<=A[4:0])temp[17]=temp[32];
									 if(15<=A[4:0])temp[16]=temp[32];
									 if(16<=A[4:0])temp[15]=temp[32];
									 if(17<=A[4:0])temp[14]=temp[32];
									 if(18<=A[4:0])temp[13]=temp[32];
									 if(19<=A[4:0])temp[12]=temp[32];
									 if(20<=A[4:0])temp[11]=temp[32];
									 if(21<=A[4:0])temp[10]=temp[32];
									 if(22<=A[4:0])temp[9]=temp[32];
									 if(23<=A[4:0])temp[8]=temp[32];
									 if(24<=A[4:0])temp[7]=temp[32];
									 if(25<=A[4:0])temp[6]=temp[32];
									 if(26<=A[4:0])temp[5]=temp[32];
									 if(27<=A[4:0])temp[4]=temp[32];
									 if(28<=A[4:0])temp[3]=temp[32];
									 if(29<=A[4:0])temp[2]=temp[32];
									 if(30<=A[4:0])temp[1]=temp[32];
									 if(31<=A[4:0])temp[0]=temp[32];
                            //for(i=0;i<=A[4:0];i=i+1) temp[31-i] = temp[32];
                            aluResult = temp[31:0];
									 $display("ALU:srav");
                        end
                    6'b011011: begin aluResult = (B[31:0] >> shiftAmount); $display("ALU:srl"); end//srl	OK
                    6'b011100://srlv	OK, but why do we use temp??
                        begin
                            temp[31:0] = (B[31:0] >> A[4:0]);
                            aluResult = temp[31:0];
									 $display("ALU:srlv");
                        end
                    6'b011101,6'b011110:begin aluResult = A - B; $display("ALU:sub,subu"); end//sub,subu   OK, but no overflow handling
                    6'b011111,6'b100000:begin aluResult = A ^ B; $display("ALU:xor,xori"); end//xor,xori	  OK
                    6'b110100,6'b111000:begin aluResult = B; $display("ALU:ctc,mtc"); end//ctc,mtc	Probably OK, but it's not clear why this is done in ALU.
                    default: begin aluResult = 0; $display("ALU:NOP"); end
      endcase
   end
                        /* verilator lint_on BLKSEQ */
	
endmodule
