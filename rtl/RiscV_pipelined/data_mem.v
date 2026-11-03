module data_mem(

				input wire clk,
				input wire dmem_read,
				input wire dmem_write,
				output reg [31:0] dmem_rd_value,
				input wire [31:0] dmem_wr_value,
				input wire [9:0] dmem_add,
				input wire [2:0] funct3,
				output reg offset_flag_rd,
				output reg offset_flag_wr,
				output reg invalid_rdmem_flag,
				output reg dmem_out_bound_flag_rd,
				output reg dmem_out_bound_flag_wr);

reg [7:0] dmemory [0:1023];

integer i;
	initial for (i=0; i<1024; i=i+1)
		dmemory[i] = 8'd0;

//assign dmem_rd_value = (dmem_read = 1'b0) ? {dmemory[dmem_add] , dmemory[dmem_add+1] , dmemory[dmem_add+2] , dmemory[dmem_add+3] } : 

always @(*) begin ///read data memory
	
	offset_flag_rd=1'b0;
	dmem_out_bound_flag_rd = 1'b0;


	if(dmem_add < 1024) begin /// to prevent out of bound memory indexing
		if(dmem_read==1'b1) begin
			case(funct3)
				3'b000: dmem_rd_value = {{24{dmemory[dmem_add][7]}} , dmemory[dmem_add]}; ///lb
				3'b001: begin /// to prevent out of byte offset
							if(dmem_add[0] == 1'b0) dmem_rd_value = {{16{dmemory[dmem_add+1][7]}} , dmemory[dmem_add+1] , dmemory[dmem_add]}; ///lh
							else begin 
								dmem_rd_value = 32'b0;
								offset_flag_rd = 1'b1;
								end
						end
				3'b010: begin 
							if(dmem_add[1:0]==2'b00) dmem_rd_value = {dmemory[dmem_add+3] , dmemory[dmem_add+2] , dmemory[dmem_add+1] , dmemory[dmem_add]}; ///lw
							else begin 
								dmem_rd_value = 32'b0;
								offset_flag_rd = 1'b1;
								end
						end
				3'b100: dmem_rd_value = {24'd0 , dmemory[dmem_add]}; ///lbu
				3'b101: begin 
							if (dmem_add[0] == 1'b0) dmem_rd_value = {16'd0 , dmemory[dmem_add+1] , dmemory[dmem_add]}; ///lhu
							else begin 
								dmem_rd_value = 32'b0;
								offset_flag_rd = 1'b1;
								end
						end
				default: invalid_rdmem_flag = 1'b1;//dmem_rd_value = 32'b0;
			endcase
		end
		else dmem_rd_value = 32'b0;
	end
	else begin 
		dmem_out_bound_flag_rd = 1'b1;
		dmem_rd_value = 32'b0;
	end
end

always @(posedge clk) begin ///write data memory
	
	offset_flag_wr = 1'b0;
	dmem_out_bound_flag_wr = 1'b0;

	if(dmem_add < 1024) begin
		if(dmem_write==1'b1) begin
			case(funct3)
				3'b000: dmemory[dmem_add] <= dmem_wr_value[7:0]; ///sb
				3'b001: begin /// to prevent out of byte offset
							if(dmem_add[0] == 1'b0) begin 
								dmemory[dmem_add+1] <= dmem_wr_value[15:8]; ///sh
								dmemory[dmem_add] <= dmem_wr_value[7:0];
								end
							else offset_flag_wr = 1'b1;
						end
				3'b010: begin 
							if(dmem_add[1:0]==2'b00) begin
								dmemory[dmem_add+3] <= dmem_wr_value[31:24]; ///sw
								dmemory[dmem_add+2] <= dmem_wr_value[23:16];
								dmemory[dmem_add+1] <= dmem_wr_value[15:8];
								dmemory[dmem_add] <= dmem_wr_value[7:0];
								end
							else offset_flag_wr = 1'b1;
						end
			endcase
		end
	end
	else dmem_out_bound_flag_wr = 1'b1;
end

endmodule
