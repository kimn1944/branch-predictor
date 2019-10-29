module RAS (
        input CLK,
        input RESET,
        input [31:0] InstrPC_IF,
        input [31:0] Instr_IF,
        input IsJL,
        input [31:0] InstrPC_ID,

        output reg hit,
        output reg [31:0] alt_PC
    );

    reg [31:0]  stack [31:0];
    integer     i;
    integer     stack_pointer;
    wire        IsJR;
    wire [31:0] next_PC;
    wire        RAS_hit;

    assign IsJR     = (Instr_IF[31:11] == 21'b000000111110000000000) && (Instr_IF[5:0] == 6'b001000);
    assign RAS_hit  = IsJR && (stack_pointer > 0);
    assign next_PC  = RAS_hit ? (IsJL ? {(InstrPC_ID + 8)} : stack[stack_pointer - 1] ) : (InstrPC_IF + 4);

    always @(posedge IsJL or posedge IsJR or negedge RESET) begin
        if (!RESET) begin
            alt_PC   <= 0;
            hit      <= 0;
            for(i = 0; i < 32; i = i + 1) begin
                stack[i] = 0;
            end
            stack_pointer <= 0;
        end else if (IsJL && !IsJR && (stack_pointer < 32))begin
            stack[stack_pointer] <= {InstrPC_ID + 8};
            stack_pointer        <= stack_pointer +1;
        end else if (IsJL && !IsJR && stack_pointer == 32) begin
            stack[31] <= {(InstrPC_ID + 8)};
            stack[30:0] <= {stack[31:1]};
        end else if (RAS_hit) begin
            stack_pointer <= stack_pointer - {31'd0, RAS_hit} + {31'd0, IsJL};
            hit           <= RAS_hit;
            alt_PC        <= next_PC;
            stack[stack_pointer - 1]   <= IsJL ? stack[stack_pointer - 1] : {32'b0};
        end else begin
            hit           <= 0;
            alt_PC        <= next_PC;
        end
        // $display("\n\nStack[0]: %x", stack[0]);
        // $display("Stack[1]: %x", stack[1]);
        // $display("Stack[2]: %x", stack[2]);
        // $display("Stack[3]: %x", stack[3]);
        // $display("Stack[4]: %x", stack[4]);
        // $display("Stack[5]: %x", stack[5]);
        // $display("Stack[6]: %x", stack[6]);
        // $display("Stack[7]: %x", stack[7]);
        // $display("Stack[8]: %x", stack[8]);
        // $display("Stack pointer: %d %d %x; isJL: %b; isJR: %b", stack_pointer - RAS_hit + IsJL, stack_pointer -1, stack[stack_pointer-1], IsJL, IsJR);
        // $display("His_RAS: %b; next_PC: %x, IF_Instr: %x, IF_PC: %x", RAS_hit, next_PC, Instr_IF, InstrPC_IF);
    end



endmodule
