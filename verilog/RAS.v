module RAS (
        input CLK,
        input RESET,
        input [31:0] InstrPC_IF,
        input IsJL,
        input [31:0] InstrPC_ID,

        output reg hit,
        output reg [31:0] alt_PC
    );

    reg [31:0] stack [31:0];
    integer i;
    integer valid;
    wire IsJR;
    assign IsJR = (InstrPC_IF[31:11] == 21'b000000111110000000000) && (InstrPC_IF[5:0] == 6'b001000);
    
    always @(posedge CLK or negedge RESET) begin
        if (!RESET) begin
            alt_pc   <= 0;
            hit      <= 0;
            for(i = 0; i < 32; i = i + 1) begin
                stack[i] <= 0;
            end
            valid <= 0;
        end else if (IsJL)begin
            stack <= {InstrPC_ID + 8,stack[31:1]};
            valid <= valid +1;
        end

        if (!RESET && IsJR && valid > 0)begin
            valid <= valid - IsJR;
            hit <= IsJR;
            alt_PC <= stack[0];
        end
    end


endmodule