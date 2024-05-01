module PC(PCout, PCin, clk, rst);
  output reg [31:0]PCout;
	input [31:0]PCin;
	input clk;
	input rst;
	
	initial
		begin
		PCout = 0;    //Initialise the output register
		end
	
	always @(posedge clk, negedge rst)
		begin
    if(!rst)    
			PCout <= 0;    //Active Low Reset
		else
			begin
			PCout <= PCin;
			end
		end
endmodule
