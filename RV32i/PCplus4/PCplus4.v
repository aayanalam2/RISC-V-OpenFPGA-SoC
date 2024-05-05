module PCplus4(PCin, PCadd);
	output reg [31:0]PCadd;
	input [31:0]PCin;
	
	initial
		begin
		PCadd = 0;
		end
	
	always @(*)
		begin
		PCadd = PCin + 4;
		end

endmodule
