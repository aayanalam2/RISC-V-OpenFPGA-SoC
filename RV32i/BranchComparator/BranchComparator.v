module BranchComparator(
 	sr1,
 	sr2,
 	BrUn,
 	BrLT,
 	BrEq,
 	reset
	);

input [31:0] sr1;
input [31:0] sr2;
input BrUn;
input reset;
output reg BrLT;
output reg BrEq;

//comparisons 
always @(*) begin 
	// reset
	if (reset) begin
		BrLT = 0;
		BrEq = 0;
	end
	else begin
		BrEq = 0;
		BrLT = 0;
		//unsigned comparison
		if(BrUn)begin
			if(sr1 < sr2) BrLT = 1;
			else if(sr1 == sr2) BrEq = 1;
		end
		//signed comparison
		else begin
			if ($signed(sr1)<$signed((sr2))) BrLT = 1;
			else if ($signed(sr1) ==  $signed((sr2))) BrEq = 1;
		end
	end
end
endmodule
