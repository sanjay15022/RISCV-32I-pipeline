module exe_mem_reg( 
				input wire clk,
				input wire [31:0] alu_out,
				input wire branch_ok,
				input wire [1:0] reg_wb,
				input wire reg_write,
				input wire dmem_read,
				input wire dmem_write,
				input wire branch,
				input wire jalr,
				input wire jump, 
				input wire [31:0] imm_u,
				input wire [31:0] r_rs2,
				input wire [2:0] funct3,
				input wire [31:0] pc_plus4,	
				input wire [4:0] rd,
				
				output reg [31:0] alu_out_reg,
				output reg branch_ok_reg,
				output reg [1:0] reg_wb_reg,
				output reg reg_write_reg,
				output reg dmem_read_reg,
				output reg dmem_write_reg,
				output reg branch_reg,
				output reg jalr_reg,
				output reg jump_reg, 
				output reg [31:0] imm_u_reg,
				output reg [31:0] r_rs2_reg,
				output reg [2:0] funct3_reg, 
				output reg [31:0] pc_plus4_reg,
				output reg [4:0] rd_reg );

initial begin
	
				alu_out_reg  = 32'b0;
				branch_ok_reg  = 1'b0;
				reg_wb_reg  = 2'b0;
				reg_write_reg  = 1'b0;
				dmem_read_reg  = 1'b0;
				dmem_write_reg  = 1'b0;
				branch_reg  = 1'b0;
				jalr_reg  = 1'b0;
				jump_reg  = 1'b0; 
				imm_u_reg  = 32'b0;
				r_rs2_reg  = 32'b0;
				funct3_reg  = 3'b0; 
				pc_plus4_reg  = 32'b0;
				rd_reg  = 5'b0;	
end

always@(posedge clk) begin
	
			alu_out_reg   <= alu_out;
			branch_ok_reg   <= branch_ok;
			reg_wb_reg   <= reg_wb;
			reg_write_reg   <= reg_write;
			dmem_read_reg   <= dmem_read;
			dmem_write_reg   <= dmem_write;
			branch_reg   <= branch;
			jalr_reg   <= jalr;
			jump_reg   <=  jump;
			imm_u_reg   <= imm_u;
			r_rs2_reg  <= r_rs2;
			funct3_reg <= funct3;
			pc_plus4_reg  <= pc_plus4;
			rd_reg <= rd;
end

endmodule