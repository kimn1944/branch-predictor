`include "config.v"
//-----------------------------------------
//           Quick Compare
//-----------------------------------------
module compare(	Jump,
		OpA,
		OpB,
		Instr_input,
		taken
		);

	output taken; // main output of module - whether we jump/branch or not
	// 1 if branch
	// 0 if not

	input      [31: 0] OpA; // operand a
	input      [31: 0] OpB; // operand b
	input      [31: 0] Instr_input;	 // instruction
	input	           Jump; // if we plan to jump

	reg               br_taken; // if we are taking the branch
	
	assign taken=br_taken|Jump; //if we jump, we always take the branch

	always @(Instr_input or OpA or OpB) begin
		case(Instr_input[31:26])
			6'b000001:begin
				case(Instr_input[20:16])
					5'b00000,5'b10000:br_taken=(OpA[31]==1)?1'b1:1'b0;		  	//BLTZ,BLTZAL // appears correct
					5'b00001,5'b10001:br_taken=(OpA[31]==0)?1'b1:1'b0;	//BGEZ,BGEZAL // appears correct
					default: br_taken=1'b0; // not actually branching
				endcase
			end			
			6'b000100:br_taken=(OpA==OpB)?1'b1:1'b0;						//BEQ //ops look correct
			6'b000101:br_taken=(OpA!=OpB)?1'b1:1'b0;						//BNE // ops look correct
			6'b000110:br_taken=((OpA[31]==1)||(OpA==0))?1'b1:1'b0;				//BLEZ // ops look correct
			6'b000111: begin
				br_taken=((OpA[31]==0)&&(OpA!=0))?1'b1:1'b0;			//BGTZ  // ops look correct
			end
			default:br_taken=1'b0; // default, don't branch
		endcase
	end

endmodule


// We went over this, if looks correct.....
