`include "config.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:21:29 10/16/2013 
// Design Name: 
// Module Name:    RegValue1 
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
module RegValue1 #(
    parameter NAME = "RV1"
    ) (
    input [4:0] ReadRegister1,
    input [31:0] RegisterData1,
    input [4:0] WriteRegister1stPri1,
    input [31:0] WriteData1stPri1,
    input        Valid1stPri1,
    output [31:0] Output1,
	 input comment
    );
    
    wire [4:0]  InterimRegister1;
    wire [31:0] InterimData1;
    wire        InterimValid1;
    assign InterimRegister1 = WriteRegister1stPri1;
    assign InterimData1 = WriteData1stPri1;
    assign InterimValid1 = Valid1stPri1;

    assign Output1 = ((ReadRegister1 == InterimRegister1) && InterimValid1)?InterimData1:RegisterData1;
	 
	 //TODO: Fix commenting
always @(ReadRegister1 or RegisterData1 or WriteRegister1stPri1 or WriteData1stPri1 or Valid1stPri1)  begin
    if(comment) begin
        $display("RV%s:Reg[%d] was %x; BypassReg[%d]?%d=%x",NAME,ReadRegister1, RegisterData1, WriteRegister1stPri1,Valid1stPri1,WriteData1stPri1);
    end
end


endmodule
