module mem_wb_reg(
					input wire clk ,
					input wire [31:0] alu_out,
					input wire [31:0] imm_u,
					input wire [31:0] r_dmem,
					input wire [31:0] pc_plus4,
					input wire [1:0] reg_wb,
					input wire reg_write,
					input wire [4:0] rd, 

					output reg [31:0] alu_out_reg,
					output reg [31:0] imm_u_reg,
					output reg [31:0] r_dmem_reg,
					output reg [31:0] pc_plus4_reg,
					output reg [1:0] reg_wb_reg,
					output reg reg_write_reg,
					output reg [4:0] rd_reg);

initial begin
	
	alu_out_reg  = 32'b0;
	imm_u_reg  = 32'b0;
	r_dmem_reg  = 32'b0;
	pc_plus4_reg  = 32'b0;
	reg_wb_reg  = 2'b0;
	reg_write_reg  = 1'b0;
	rd_reg  = 5'b0;	
end

always @(posedge clk) begin
	
				alu_out_reg  <= alu_out;
				imm_u_reg  <=  imm_u;
				r_dmem_reg  <= r_dmem;
				pc_plus4_reg  <= pc_plus4;
				reg_wb_reg <= reg_wb;
				reg_write_reg <= reg_write;
				rd_reg <= rd;
end 	

endmodule 