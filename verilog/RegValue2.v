`include "config.v"
module RegValue2#(
    parameter NAME = "RV2"
    ) (
    input [4:0] ReadRegister1,
    input [31:0] RegisterData1,
    input [4:0] WriteRegister1stPri1,
    input [31:0] WriteData1stPri1,
    input        Valid1stPri1,
    input [4:0] WriteRegister2ndPri1,
    input [31:0] WriteData2ndPri1,
    input        Valid2ndPri1,
    output [31:0] Output1,
    input comment
    );
	 
    wire [31:0] TempOut1;
	 
	 RegValue1 #( 
	 .NAME({NAME,".2nd"})
	 )
	 RV1(
	 	.ReadRegister1(ReadRegister1),
	 	.RegisterData1(RegisterData1),
	 	.WriteRegister1stPri1(WriteRegister2ndPri1),
	 	.WriteData1stPri1(WriteData2ndPri1),
	 	.Valid1stPri1(Valid2ndPri1),
	 	.Output1(TempOut1),
	 	.comment(comment)
	 );
	 
     RegValue1  #(
     .NAME({NAME,".1st"})
     )RV2(
        .ReadRegister1(ReadRegister1),
        .RegisterData1(TempOut1),
        .WriteRegister1stPri1(WriteRegister1stPri1),
        .WriteData1stPri1(WriteData1stPri1),
        .Valid1stPri1(Valid1stPri1),
        .Output1(Output1),
        .comment(comment)
     );
//   
//always begin
//  if(ReadRegister1 != 0) begin
//      if(Valid1stPri1 && (ReadRegister1 == WriteRegister1stPri1)) begin
//          //$display("FWD:Reg[%d] was %x now %x (1stPri)", ReadRegister1, RegisterData1, WriteData1stPri1);
//          if (Valid2ndPri1 && (ReadRegister1 == WriteRegister2ndPri1)) begin
//              //$display("FWD[declined]:Reg[%d] was %x now %x (2ndPri)", ReadRegister1, RegisterData1, WriteData2ndPri1);
//          end
//      end else if (Valid2ndPri1 && (ReadRegister1 == WriteRegister2ndPri1)) begin
//          //$display("FWD:Reg[%d] was %x now %x (2ndPri)", ReadRegister1, RegisterData1, WriteData2ndPri1);
//      end
//  end
//end
//
endmodule
