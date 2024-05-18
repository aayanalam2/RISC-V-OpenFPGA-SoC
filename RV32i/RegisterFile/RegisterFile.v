module RegisterFile(r1Read, r2Read, r1Addr, r2Addr, writeEn, clk, writeAddr, dataIn);
	output reg [31:0] r1Read;
	output reg [31:0] r2Read;
	input clk;
	input writeEn;
	input [4:0] writeAddr;
	input [4:0] r1;
	input [4:0] r2;
	input [31:0] dataIn;
	
	reg [31:0] regFile [31:0];
	
	initial 
	begin
		integer i;
		for (i=0; i<32; i=i+1)
			regFile[i] = 0;
	end
	
	always@(posedge clk)
	begin
		if(writeEn)
			regFile[writeAddr] <= dataIn;
	end
	always@(*)
	begin
		r1Read = regFile[r1Addr];
		r2Read = regFile[r2Addr];
	end
endmodule
