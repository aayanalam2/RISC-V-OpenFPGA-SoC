module ALU(output reg [31:0] out, input [4:0] op, input [31:0] r1, input [31:0] r2);	//r1 represents the value stored in register1, the same goes for r2
	always @(*)
		begin
		case(op)
			4'b0000: out = r1 + r2;								//ADD
			4'b0001: out = r1 - r2;								//SUB
			4'b0010: out = r1 << r2;							//SLL
			4'b0011: out = ($signed(r1) < $signed(r2));	//SLT
			4'b0100: out = r1 < r2;								//SLTU
			4'b0101: out = r1 ^ r2;								//XOR
			4'b0110: out = r1 >> r2;							//SRL
			4'b0111: out = r1 >>> r2;							//SRA
			4'b1000: out = r1 | r2;								//OR
			4'b1001: out = r1 & r2;								//AND
		endcase
	end
endmodule
