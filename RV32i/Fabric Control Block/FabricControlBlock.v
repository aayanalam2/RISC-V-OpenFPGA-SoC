module FabricControlBlock (
    input clk,
    input reset,
    
    input [2:0] wb_address,
    input [31:0] wb_data_in,
    input [3:0] wb_select,
    input wb_stb,
    input wb_we,
    input wb_bus_cycle,
    output reg [31:0] wb_data_out,
    output wb_ack,

    input fpga_tail,
    output reg prog_clk,
    output reg fpga_head
);

reg [31:0] FCB_control_reg;
reg [31:0] FCB_status_reg;
reg [31:0] Bitstream_write_reg;
reg [31:0] Bitstream_read_reg;
reg [31:0] Bitstream_lenght_reg;
reg [31:0] Bitstream_checksum_reg;

  
reg [31:0] Bitstream_write_reg_shift;
reg [31:0] Bitstream_read_reg_shift;

  
reg [4:0] count_value_write;
reg [4:0] count_value_read;
reg [31:0] bitstream_count;
  
reg bitstream_write_req ;
reg bitstream_read_req;
reg valid;

reg word_complt, bitstream_complt;

reg bitstream_read_pending;
reg bitstream_read_ack;
 
reg [31:0] pre_checksum_reg;
reg [31:0] post_checksum_reg;
reg pre_check_match;
reg post_check_match;
reg chksum_status;
reg pre_chksum;
reg post_chksum;


assign wb_ack = wb_stb & wb_bus_cycle;


always @(posedge clk or negedge reset) begin
    if (!reset) begin
        FCB_control_reg <= 32'h0000;
        Bitstream_write_reg <= 32'h0000;
        Bitstream_lenght_reg <= 32'h0000;
       // Bitstream_checksum_reg <= 32'h0000;
    end else begin
        if (wb_stb & wb_we & wb_bus_cycle) begin
            case (wb_address)
                3'b000: begin
                    if (wb_select[0]) FCB_control_reg[7:0] <= wb_data_in[7:0];
                    if (wb_select[1]) FCB_control_reg[15:8] <= wb_data_in[15:8];
                    if (wb_select[2]) FCB_control_reg[23:16] <= wb_data_in[23:16];
                    if (wb_select[3]) FCB_control_reg[31:24] <= wb_data_in[31:24];
                end
                3'b001: begin
					
                    if (wb_select[0]) Bitstream_write_reg[7:0] <= wb_data_in[7:0];
                    if (wb_select[1]) Bitstream_write_reg[15:8] <= wb_data_in[15:8];
                    if (wb_select[2]) Bitstream_write_reg[23:16] <= wb_data_in[23:16];
                    if (wb_select[3]) Bitstream_write_reg[31:24] <= wb_data_in[31:24];
                end
					 3'b010: begin
                    if (wb_select[0]) Bitstream_lenght_reg[7:0] <= wb_data_in[7:0];
                    if (wb_select[1]) Bitstream_lenght_reg[15:8] <= wb_data_in[15:8];
                    if (wb_select[2]) Bitstream_lenght_reg[23:16] <= wb_data_in[23:16];
                    if (wb_select[3]) Bitstream_lenght_reg[31:24] <= wb_data_in[31:24];
                end
					 3'b011: begin
                    if (wb_select[0]) Bitstream_checksum_reg[7:0]   <= wb_data_in[7:0];
                    if (wb_select[1]) Bitstream_checksum_reg[15:8]  <= wb_data_in[15:8];
                    if (wb_select[2]) Bitstream_checksum_reg[23:16] <= wb_data_in[23:16];
                    if (wb_select[3]) Bitstream_checksum_reg[31:24] <= wb_data_in[31:24];
                end
            endcase
        end
		  
		  else if (wb_stb & !wb_we & wb_bus_cycle) begin
            case (wb_address)
                3'b000: wb_data_out <= FCB_control_reg;
                3'b001: wb_data_out <= Bitstream_write_reg;
                3'b010: wb_data_out <= Bitstream_lenght_reg;
                3'b011: wb_data_out <= Bitstream_checksum_reg;
					 3'b100: wb_data_out <= FCB_status_reg;
					 3'b101: wb_data_out <= Bitstream_read_reg;
            endcase
		  end
		  end	
end

// read write request
always @(*)begin	
if (wb_stb & wb_we & wb_bus_cycle &  wb_address==3'b001)
    bitstream_write_req <= 1 ;
else
 bitstream_write_req <= 0;
	  
if (wb_stb & !wb_we & wb_bus_cycle &  wb_address==3'b101)
    bitstream_read_req <= 1;
else
  bitstream_read_req <= 0;	
end

//program clock
always @(*)begin
        if (!reset) begin
            prog_clk <= 0;
        end else if (valid) begin
            prog_clk <= clk;
				end
         else prog_clk <= 0;
 end
 
 // word complete
always @(posedge clk or negedge reset)begin
        if (!reset)
		  word_complt <= 0;
        else if (count_value_write == 5'b11111|count_value_read == 5'b11111) begin
            word_complt <= 1;
         end else if (bitstream_write_req | bitstream_read_req) begin
            word_complt <= 0;
        end
end

//bitstream complete
always @(posedge clk or negedge reset)begin
        if (!reset)
		  bitstream_complt <= 0;
        else if (bitstream_count == Bitstream_lenght_reg) begin
            bitstream_complt <= 1;
       end else begin
           bitstream_complt <= 0;
                     end
end

// status reg assignments
always @(*) begin
        FCB_status_reg[1] = word_complt;
        FCB_status_reg[0] = bitstream_complt;
end


//valid
always @(posedge clk or negedge reset) begin
     if (!reset) valid <= 0;
  else if (FCB_control_reg [0] &  (bitstream_write_req|bitstream_read_req )) valid <= 1;
     else if (count_value_write == 31| count_value_read == 31) valid <= 0;
	 else if (bitstream_count == Bitstream_lenght_reg) valid <= 0;
end

 // write logic
  always @(posedge clk or negedge reset) begin
 if(!reset)   Bitstream_write_reg_shift  <= 32'h0000;
 else if(bitstream_write_req)  Bitstream_write_reg_shift <= Bitstream_write_reg;
 else if (valid)
 Bitstream_write_reg_shift <= Bitstream_write_reg_shift >> 1;
 end
 
 
 always@(posedge prog_clk) begin 
   fpga_head =  Bitstream_write_reg_shift[0]; 
 end
 
 // write count logic
 always @(posedge clk or negedge reset) begin
 if(!reset) count_value_write <= 0;
 else if (valid) count_value_write <= count_value_write + 1;
 else if (count_value_write == 31) count_value_write <= 0;
 else count_value_write <= 0;
 end

 // total bitstream count logic
 always @(posedge clk or negedge reset) begin
 if(!reset) bitstream_count <= 0;
   else if (bitstream_write_req) bitstream_count <= bitstream_count + 1;
 else if (bitstream_count == Bitstream_lenght_reg) bitstream_count  <= 0;
 else bitstream_count  <= 0;
 end
 
 // read logic
 always @(posedge clk or negedge reset) begin
 if(!reset)  Bitstream_read_reg_shift <= 32'h0000;
   else if (valid)
     Bitstream_read_reg_shift[0]  <= fpga_tail;
   else if (bitstream_read_req)
 Bitstream_read_reg_shift  <=  Bitstream_read_reg_shift  << 1;
 end
  
 always@(posedge clk or negedge reset) begin 
  if(!reset)   Bitstream_read_reg <= 32'h0000;
    else if (valid) Bitstream_read_reg <=  Bitstream_read_reg_shift; 
 end
 
 

 // read count logic
 always @(posedge clk or negedge reset) begin
 if(!reset) count_value_read <= 0;
 else if (bitstream_read_req) count_value_read <= count_value_read + 1;
 else if (count_value_read == 31) count_value_read <= 0;
 else count_value_read <= 0;
 end
  
 
//acknowledge signal to processor
always @(posedge clk or negedge reset) 
        if(!reset) bitstream_read_pending <= 1'b0;
        else if(FCB_control_reg [0] & bitstream_read_req)  
		  bitstream_read_pending <= 1'b1;
        else if ((word_complt| bitstream_complt) & bitstream_read_pending)   
		  bitstream_read_pending <= 0;  

    
always @(posedge clk or negedge reset)
        if(!reset)bitstream_read_ack <= 1'b0;
        else if (( word_complt | bitstream_complt) & bitstream_read_pending)  
		  bitstream_read_ack <= 1;  
        else if (!bitstream_read_pending) bitstream_read_ack <= 0; 
		  
//checksum logic


always@(*)begin
post_check_match = post_checksum_reg == Bitstream_checksum_reg;
pre_check_match  = pre_checksum_reg == Bitstream_checksum_reg;
end

always @(posedge clk, negedge reset)begin
if(!reset) pre_checksum_reg <= 0;
else if (bitstream_write_req)        
pre_checksum_reg <= pre_checksum_reg + Bitstream_write_reg; 
else
pre_checksum_reg <= 0;
end

always @(posedge clk, negedge reset) begin
if(!reset)post_checksum_reg <= 0;
else if (bitstream_read_req)        
post_checksum_reg <= post_checksum_reg + Bitstream_read_reg;
else             
post_checksum_reg <= 0; 
end

always @(posedge clk, negedge reset)begin
if(!reset)chksum_status <= 0;
else if(post_chksum & bitstream_complt & bitstream_read_ack)       
chksum_status <= post_check_match;    
else if (pre_chksum & bitstream_complt)                       
chksum_status <= pre_check_match;
else
chksum_status <= 0; 
end 

endmodule







