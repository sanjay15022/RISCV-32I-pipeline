module alu_src(
	input wire [31:0] imm,
	input wire [31:0] pc,
	input wire alu_src1,
	input wire alu_src2,
	output wire [31:0] alu_ip1,
	output wire [31:0] alu_ip2,

	// forwarding 
	input wire [31:0] r_rs1_f, r_rs2_f);


assign alu_ip1 = (alu_src1 == 1'b0) ? r_rs1_f : pc;
assign alu_ip2 = (alu_src2 == 1'b0) ? r_rs2_f : imm;

endmodule