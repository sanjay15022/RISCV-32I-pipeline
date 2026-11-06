module id_exe_reg( 
					input wire clk,
					input wire branch_ok,
  	 				input wire branch_future,
					input wire jump_future,
					input wire jalr_future,
					input wire [31:0] instr, 
					input wire [2:0] funct3,
					input wire [3:0] alu_ctrl,
					input wire [31:0] alu_ip1,
					input wire [31:0] alu_ip2,
					//input wire [2:0] imm_sel,
					input wire [1:0] reg_wb,
					//input wire [3:0] alu_out_flow,
					//input wire reg_read,
					input wire reg_write,
					input wire dmem_read,
					input wire dmem_write,
					input wire branch,
					input wire jalr,
					input wire jump,
					input wire [31:0] pc,
					input wire [31:0] pc_plus4,
					input wire [31:0] imm_u,
					input wire [31:0] r_rs1,
					input wire [31:0] r_rs2,
					input wire [4:0] rd ,
					input wire stall,

					output reg [31:0] instr_reg, 
					output reg [2:0] funct3_reg,
					output reg [3:0] alu_ctrl_reg,
					output reg [31:0] alu_ip1_reg,
					output reg [31:0] alu_ip2_reg,
					//output reg [2:0] imm_sel_reg,
					output reg [1:0] reg_wb_reg,
					//output reg [3:0] alu_out_flow_reg,
					//output reg reg_read_reg,
					output reg reg_write_reg,
					output reg dmem_read_reg,
					output reg dmem_write_reg,
					output reg branch_reg,
					output reg jalr_reg,
					output reg jump_reg,
					output reg [31:0] pc_reg,
					output reg [31:0] pc_plus4_reg,
					output reg [31:0] imm_u_reg,
					output reg [31:0] r_rs1_reg,
					output reg [31:0] r_rs2_reg ,
					output reg [4:0] rd_reg);

initial begin
		instr_reg = 32'b0; 
		funct3_reg = 3'b0;
		alu_ctrl_reg = 4'b0;
		alu_ip1_reg = 32'b0;
		alu_ip2_reg = 32'b0;
		reg_wb_reg = 2'b0;
		reg_write_reg = 1'b0;
		dmem_read_reg = 1'b0;
		dmem_write_reg = 1'b0;
		branch_reg = 1'b0;
		jalr_reg = 1'b0;
		jump_reg = 1'b0;
		pc_reg = 32'b0;
		pc_plus4_reg = 32'b0;
		imm_u_reg = 32'b0;
		r_rs1_reg = 32'b0;
		r_rs2_reg  = 32'b0;
		rd_reg = 5'b0;
end

always @(posedge clk) begin

	if((branch_ok==1'b1 & branch_future==1'b1) | jump_future == 1'b1 | jalr_future ==1'b1 | stall ==1'b1) begin
		instr_reg <= 32'b0; 
		funct3_reg <= 3'b0;
		alu_ctrl_reg <= 4'b0;
		alu_ip1_reg <= 32'b0;
		alu_ip2_reg <= 32'b0;
		reg_wb_reg <= 2'b0;
		reg_write_reg <= 1'b0;
		dmem_read_reg <= 1'b0;
		dmem_write_reg <= 1'b0;
		branch_reg <= 1'b0;
		jalr_reg <= 1'b0;
		jump_reg <= 1'b0;
		pc_reg <= 32'b0;
		pc_plus4_reg <= 32'b0;
		imm_u_reg <= 32'b0;
		r_rs1_reg <= 32'b0;
		r_rs2_reg  <= 32'b0;
		rd_reg <= 5'b0;
	end
	
	else begin
					instr_reg <= instr;
					funct3_reg <= funct3;
					alu_ctrl_reg <= alu_ctrl;
 					alu_ip1_reg <= alu_ip1;
					alu_ip2_reg <= alu_ip2;
					//imm_sel_reg <= imm_sel;
					reg_wb_reg <= reg_wb;
					//alu_out_flow_reg <= alu_out_flow;
					//reg_read_reg <= reg_read;
					reg_write_reg <= reg_write;
					dmem_read_reg <= dmem_read;
					dmem_write_reg <= dmem_write;
					branch_reg <= branch;
					jalr_reg <= jalr;
					jump_reg <= jump;
					pc_reg <= pc;
					pc_plus4_reg <= pc_plus4;
					imm_u_reg <= imm_u;
					r_rs1_reg <= r_rs1;
					r_rs2_reg <= r_rs2;
					rd_reg <= rd ;
	end

end

endmodule