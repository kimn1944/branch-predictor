`include "config.v"
module RegValue3 #(
    parameter NAME="RV3"
)(
    input [4:0] ReadRegister1,
    input [31:0] RegisterData1,
    input [4:0] WriteRegister1stPri1,
    input [31:0] WriteData1stPri1,
    input        Valid1stPri1,
    input [4:0] WriteRegister2ndPri1,
    input [31:0] WriteData2ndPri1,
    input        Valid2ndPri1,
    input [4:0] WriteRegister3rdPri1,
    input [31:0] WriteData3rdPri1,
    input        Valid3rdPri1,
    output [31:0] Output1,
	 input comment
    );
	 
    wire [31:0] TempOut1;

    RegValue2 #( 
     .NAME({NAME,".2nd"})
     ) RV2(
        .ReadRegister1(ReadRegister1),
        .RegisterData1(RegisterData1),
        .WriteRegister1stPri1(WriteRegister2ndPri1),
        .WriteData1stPri1(WriteData2ndPri1),
        .Valid1stPri1(Valid2ndPri1),
        .WriteRegister2ndPri1(WriteRegister3rdPri1),
        .WriteData2ndPri1(WriteData3rdPri1),
        .Valid2ndPri1(Valid3rdPri1),
        .Output1(TempOut1),
        .comment(comment)
    );
    
    RegValue1 #( 
     .NAME({NAME,".1st"})
     ) RV1(
    	.ReadRegister1(ReadRegister1),
    	.RegisterData1(TempOut1),
    	.WriteRegister1stPri1(WriteRegister1stPri1),
    	.WriteData1stPri1(WriteData1stPri1),
    	.Valid1stPri1(Valid1stPri1),
    	.Output1(Output1),
    	.comment(comment)
    );

endmodule
