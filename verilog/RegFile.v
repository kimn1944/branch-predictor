`include "config.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:27:55 10/20/2013 
// Design Name: 
// Module Name:    RegFile 
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
module RegFile(
    input CLK,
    input RESET,
    /*Register A to read*/
    input [4:0] RegA1,
    /*Register B to read*/
    input [4:0] RegB1,
    /*Register C to read*/
    input [4:0] RegC1,
    /*Value of register A*/
    output [31:0] DataA1,
    /*Value of register B*/
    output [31:0] DataB1,
    /*Value of register C*/
    output [31:0] DataC1,
    /*Register to write*/
    input [4:0] WriteReg1,
    /*Data to write*/
    input [31:0] WriteData1,
    /*Actually do it?*/
     input Write1
);
	 
    reg [31:0] Reg [0:31]/*verilator public*/;
    
    assign DataA1 = Reg[RegA1];
    assign DataB1 = Reg[RegB1];
    assign DataC1 = Reg[RegC1];
		
always @(posedge CLK or negedge RESET) begin
	if (!RESET) begin
		Reg[0] <= 0;
		Reg[1] <= 0;
		Reg[2] <= 0;
		Reg[3] <= 0;
		Reg[4] <= 0;
		Reg[5] <= 0;
		Reg[6] <= 0;
		Reg[7] <= 0;
		Reg[8] <= 0;
		Reg[9] <= 0;
		Reg[10] <= 0;
		Reg[11] <= 0;
		Reg[12] <= 0;
		Reg[13] <= 0;
		Reg[14] <= 0;
		Reg[15] <= 0;
		Reg[16] <= 0;
		Reg[17] <= 0;
		Reg[18] <= 0;
		Reg[19] <= 0;
		Reg[20] <= 0;
		Reg[21] <= 0;
		Reg[22] <= 0;
		Reg[23] <= 0;
		Reg[24] <= 0;
		Reg[25] <= 0;
		Reg[26] <= 0;
		Reg[27] <= 0;
		Reg[28] <= 0;
		Reg[29] <= 0;
		Reg[30] <= 0;
		Reg[31] <= 0;
    end else begin
`ifdef HAS_WRITEBACK
        if (Write1) begin
            Reg[WriteReg1] <= WriteData1;
            $display("IDWB:Reg[%d]=%x",WriteReg1,WriteData1);
        end
`else
        /*You might want to process the writebacks*/
        $display("IDWB:%d?Reg[%d]=%x",Write1,WriteReg1,WriteData1);
`endif
    end

end

endmodule
