module if_id_reg(
				input wire clk,
				input wire [31:0] instr,
				input wire [31:0] pc,
				input wire [31:0] pc_plus4,
				input wire branch_ok,
				input wire branch_future,
				input wire jump_future,
				input wire jalr_future,
				output reg [31:0] pc_reg,
				output reg [31:0] pc_plus4_reg,				 
				output reg [31:0] instr_reg );

initial begin
	instr_reg = 32'b0;
	pc_reg = 32'b0;
	pc_plus4_reg = 32'b0;
end

always @(posedge clk) begin 

	if((branch_ok==1'b1 & branch_future==1'b1) | jump_future == 1'b1 | jalr_future ==1'b1) begin

		instr_reg <= 32'b0;
		pc_reg <= 32'b0;
		pc_plus4_reg <= 32'b0;
	end
	else begin
			
		instr_reg <= instr;
		pc_reg <= pc;
		pc_plus4_reg <= pc_plus4;
	end
end

endmodule