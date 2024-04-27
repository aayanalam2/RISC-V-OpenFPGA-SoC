//Instruction Decoder for RV32i microarchitecture

module InstructionDecoder(
inst, jump, ALU_SEL, dmemMode,immSEL,A_SEL, B_SEL, pcSEL, dmemWE, regWE, rs1SEL, rs2SEL,  reset, BrUn, BrEq, BrLT,igensel
);

input wire[31:0] inst;
input wire jump,  reset;
input BrEq;
input BrLT;

output reg BrUn;
output reg [3:0] ALU_SEL;
output reg [1:0] wb_SEL;
output reg A_SEL;
output reg B_SEL;
output reg pc_SEL;
output reg dmemWE, regWE;

// dmemMode
// 0 -  Byte
// 1 -  Half Word
// 2 -  Word
// 3 -  Byte Unsigned
// 4 -  Half Word Unsigned
output reg [3:0] dmemMode;


//igensel
    //0 I-Type	
	//1 S-Type
	//2 B-Type
	//3 J-Type
	//4 U-Type

output reg [3:0] igensel;

// Internal Signals
wire [6:0] opcode, funct7;
wire [2:0] funct3;

assign opcode = inst[6:0];
assign funct3 = inst[14:12];
assign funct7 = inst[31:25];

//Decoding Logic
always @(*)
begin
	if(reset)
	begin
	    	ALU_SEL = 0;
	    	A_SEL = 0;
	    	B_SEL = 0;
	    	wb_SEL = 0;
	    	regWE = 0;
	    	memWe = 0;
	    	pc_SEL = 0;
	end
	else begin 
	case (opcode)

		//R-Type Instructions
		7'b0110011:
		begin
			regWE = 1;
			dmemWE = 0;
			A_SEL = 0;
			B_SEL = 0;
			pc_SEL = 0;
			wb_SEL = 2'b01;
			if (funct7 == 7'b0000000)
			begin
				case (funct3)
					//ADD
					3'b000:
					ALU_SEL = 0;
					
					//SLL
					3'b001:
					ALU_SEL = 2;
					
					//SLT
					3'b010:
					ALU_SEL = 3;
					
					//SLTU
					3'b011:
					ALU_SEL = 4;
					
					//XOR
					3'b100:
					ALU_SEL = 5;
					
					//SRL
					3'b101:
					ALU_SEL = 6;
					
					//OR
					3'b110:
					ALU_SEL = 8;
					
					//AND
					3'b111:
					ALU_SEL = 9;
				endcase 
			end
			if (funt7 == 7'b0100000)
			begin
				//SUB
				if (funct3 == 3'b000) ALU_SEL = 1;
				// SRA
				else ALU_SEL = 	7;
			end
		end

		//I-Type Instructions:
		7'b0010011:
		begin
		 	regWE = 1;
		 	dmemWE = 0;
		 	A_SEL = 0;
		 	B_SEL = 1;
		 	wb_SEL = 1;
		 	pc_SEL = 0;
		 	igensel = 0;
			 	case (funct3)
			 		//ADDI
			 		3'b000:
			 		ALU_SEL = 0;
			 		
			 		//SLLI
			 		3'b001:
			 		ALU_SEL = 2;
			 		
			 		//SLTI
			 		3'b010:
			 		ALU_SEL = 3;
			 		
			 		//SLTIU
			 		3'b011:
			 		ALU_SEL = 4;
			 		
			 		//XORI
			 		3'b100:
			 		ALU_SEL = 5;

			 		3'b101:
			 		begin
			 			//SSRAI and SRLI
			 			ALU_SEL = (funct3 == 7'b0000000)?(6):(7);
			 		end
			 		//ORI 
			 		3'b110:
			 		ALU_SEL = 8;

			 		//ANDI
			 		3'b111:
			 		ALU_SEL = 9;
			 	endcase 
		end

	    //L-Type Instructions:
	    7'b0000011:
	    begin
	    	regWE = 1;
	    	dmemWE = 0;
	    	A_SEL = 0;
	    	B_SEL = 1;
	    	wb_SEL = 0;
	    	// ALU is a don't care, default to 0
	    	ALU_SEL = 0;
	    	igensel = 0;
	    	case (funct3)
	    		//LB
	    		3'b000: 
	    		dmemMode = 0;
	    		
	    		//LH
	    		3'b001:
	    		dmemMode = 1;
	    		
	    		//LW
	    		3'b010:
	    		dmemMode = 2;

	    		//LBU
	    		3'b100:
	    		dmemMode = 3;

	    		//LHU
	    		3'b101:
	    		dmemMode = 4;

	    		default: dmemMode = 0;
	    	endcase
	    end

	    //S-Type Instructions:
	    7'b0100011:
	    begin
	    	igensel = 1;
	    	regWE = 0;
	    	dmemWE = 1;
	    	wb_SEL = 0;
	    	pc_SEL = 0;
	    	A_SEL = 0;
	    	B_SEL = 0;
			dmemMode = funct3;
	    end

	    //Branch-Type Instructions:
	    7'b1100011: 
	    begin
	    	regWE = 0;
	    	memWe = 0;
	    	A_SEL = 1;
	    	B_SEL = 1;
	    	wb_SEL = 0;
	    	ALU_SEL = 0;
	    	igensel = 2;
	    	case (funct3)
	    		3'b000: 
	    		begin
	    			BrUn = 0;
	    			pc_SEL = BrEq;
	    		end

	    		3'b001: 
	    		begin
	    			BrUn = 0; 
	    			pc_SEL = !BrEq;
	    		end

	    		3'b100:
	    		begin
	    			BrUn = 0;
	    			pc_SEL = BrLT;
	    		end

	    		3'b101:
	    		begin
	    			BrUn = 0;
	    			pc_SEL = !BrLT;
	    		end

	    		3'b110: 
	    		begin
	    			BrUn = 1;
	    			pc_SEL = BrLT;
	    		end
	    		3'b111:
	    		begin
	    			BrUn = 1;
	    			pc_SEL = !BrLT;
	    		end


	    	endcase
	    end

	    //JALR
	    7'b1100111:
	    begin
	    	regWE = 1;
	    	memWe = 0;
	    	A_SEL = 0;
	    	B_SEL - 1;
	    	wb_SEL = 2;
	    	pc_SEL = 1;
	    	ALU_SEL = 0;
	    	igensel = 0;
	    end

	    //JAL
	    7'b1101111:
	    begin
	    	regWE = 1;
	    	dmemMode = 0;
	    	A_SEL = 1;
	    	B_SEL = 1;
	    	wb_SEL = 2;
	    	pc_SEL = 1;
	    	ALU_SEL = 0;
	    	igensel = 3;
	    end

	    //LUI
	    7'b0110111:
	    begin
	    	regWE = 1;
	    	memWe = 0;
	    	A_SEL = 0;
	    	B_SEL = 1;
	    	wb_SEL = 1;
	    	pc_SEL = 0;
	    	ALU_SEL = 0;
	    end

	    //AUIPC
	    7'b0110111:
	    begin
	    	regWE = 1;
	    	memWe = 0;
	    	A_SEL = 1;
	    	B_SEL = 1;
	    	wb_SEL = 2;
	    	pc_SEL = 0;
	    	ALU_SEL = 0;
	    	igensel = 4;
	    end

	    default:
	    begin
	    	ALU_SEL = 0;
	    	A_SEL = 0;
	    	B_SEL = 0;
	    	wb_SEL = 0;
	    	regWE = 0;
	    	memWe = 0;
	    	pc_SEL = 0;
	    	igensel = 4;
	    end
	endcase // opcode	
end
end

endmodule
