module dMem(dataOut, clk, dMemWE, dMemWMode, address, dataIn, rst);

output reg [31:0] dataOut;
input clk;
input dMemWE;
input [2:0] dMemWMode;
input [31:0] address;
input [31:0] dataIn;
input rst;

reg [7:0] register [1023:0];

initial 
begin
	integer i;
	for(i=0; i<1024; i=i+1)
		register[i] = 0;
end

always @(posedge clk or negedge rst)
begin
	if(!rst)															//Asynchronous Reset (Active Low)
	begin
		integer k;
		for(k=0; k<1024; k=k+1)
			register[k] <= 0;
	end
	
	else
	begin
		if (dMemWE == 1)											
		begin
			case (dMemWMode)										//Case Data Memory Write Mode
			3b'000:														//Byte (Signed)
			begin
				register[address] <= dataIn[7:0];
				register[address+1] <= {8{dataIn[7]}};
				register[address+2] <= {8{dataIn[7]}};
				register[address+3] <= {8{dataIn[7]}};
			end
			3b'001:														//Half Word (Signed)
			begin
				register[address] <= dataIn[7:0];
				register[address+1] <= dataIn[15:8];
				register[address+2] <= {8{dataIn[15]}};
				register[address+3] <= {8{dataIn[15]}};
			end
			3b'010:														//Full Word
			begin
				register[address] <= dataIn[7:0];
				register[address+1] <= dataIn[15:8];
				register[address+2] <= dataIn[23:16];
				register[address+3] <= dataIn[31:24];
			end
			3b'011:														//Byte (Unsigned)
			begin
				register[address] <= dataIn[7:0];
			end
			3b'100:														//Half Word (Unsigned)
			begin
				register[address] <= dataIn[7:0];
				register[address+1] <= dataIn[15:8];
			end
		endcase
		end
		else 
		begin
			dataOut <= {register[address+3], register[address+2], register[address+1], register[address]};	//Data Read from Data Memory
		end
	end
end



endmodule
