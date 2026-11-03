module main(
				input wire clk);

wire [31:0] pc,pc_clc,pc_plus4,instr , imm_s,imm_l,imm_u,imm_b,imm_j ,r_rs1,r_rs2,w_rd,wr_rd;
wire [31:0] imm,alu_ip1,alu_ip2 ,alu_out,r_dmem;
wire branch,branch_ok,jump,jalr ,alu_src1,alu_src2,reg_read,reg_write,dmem_write,dmem_read ;
wire neg_flag,zero_flag,offset_flag_wr,offset_flag_rd,invalid_rdmem_flag,dmem_out_bound_flag_rd,dmem_out_bound_flag_wr;
wire [4:0] rs1,rs2,rd;
wire [6:0] opcode,funct7;
wire [2:0] funct3 , imm_sel;
wire [3:0] alu_ctrl,alu_out_flow;
wire [1:0] reg_wb;
wire [9:0] dmem_add;


pc pc_1(.clk(clk) ,
		.pc(pc) ,
		.pc_clc(pc_clc) ,
		.branch(branch) ,
		.branch_ok(branch_ok) ,
		.jump(jump),
		.jalr(jalr) ,
		.pc_plus4(pc_plus4));

instr_reg instr_reg1(.clk(clk) ,
					 .instr_add(pc[9:0]) ,
					 .instr(instr));

splitter instr_splitter(.instr(instr) ,
						.rs1(rs1) ,
						.rs2(rs2) ,
						.rd(rd) ,
						.opcode(opcode) ,
						.funct3(funct3) ,
						.funct7(funct7) ,
						.imm_s(imm_s) ,
						.imm_l(imm_l) ,
						.imm_u(imm_u) ,
						.imm_b(imm_b) ,
						.imm_j(imm_j) );

ctrl_unit ctrl_unit1(.opcode(opcode) ,
					 .funct3(funct3) ,
					 .funct7(funct7) ,
					 .alu_ctrl(alu_ctrl) ,
					 .alu_src1(alu_src1) ,
					 .alu_src2(alu_src2) ,
					 .imm_sel(imm_sel) ,
					 .reg_wb(reg_wb) ,
					 .alu_out_flow(alu_out_flow) ,
					 .reg_read(reg_read) ,
					 .reg_write(reg_write) ,
					 .dmem_write(dmem_write) ,
					 .dmem_read(dmem_read) ,
					 .branch(branch) ,
					 .jump(jump) ,
					 .jalr(jalr) );

reg_wb reg_wb1(.alu_out(alu_out) ,
			   .r_dmem(r_dmem) ,
			   .pc_plus4(pc_plus4) ,
			   .w_rd(w_rd) ,
			   .reg_wb(reg_wb) ,
			   .imm_u(imm_u) );

register regi1(.clk(clk) ,
			   .reg_read(reg_read) ,
			   .reg_write(reg_write) ,
			   .rs1(rs1) ,
			   .rs2(rs2) ,
			   .rd(rd) ,
			   .r_rs1(r_rs1) ,
			   .r_rs2(r_rs2) ,
			   .w_rd(w_rd) );

imm_sel imm_sel1(.imm_s(imm_s) ,
				 .imm_l(imm_l) ,
				 .imm_u(imm_u) ,
				 .imm_b(imm_b) ,
				 .imm_j(imm_j) ,
				 .imm_sel(imm_sel) ,
				 .imm(imm) );

alu_src alu_src_1(.r_rs1(r_rs1) ,
				 .r_rs2(r_rs2) ,
				 .imm(imm) ,
				 .pc(pc) ,
				 .alu_src1(alu_src1) ,
				 .alu_src2(alu_src2) ,
				 .alu_ip1(alu_ip1) ,
				 .alu_ip2(alu_ip2) );

alu alu1(.alu_ip1(alu_ip1) ,
		 .alu_ip2(alu_ip2) ,
		 .alu_ctrl(alu_ctrl) ,
		 .alu_out(alu_out) ,
		 .neg_flag(neg_flag) ,
		 .zero_flag(zero_flag) );

/*alu_out_flow alu_out1(.alu_out(alu_out) ,
					  .alu_out_flow(alu_out_flow) ,
					  .pc_clc() ,
					  .wr_rd(wr_rd) ,
					  .dmem_add(dmem_add) );*/

data_mem dmem1(.clk(clk) ,
			   .dmem_read(dmem_read) ,
			   .dmem_write(dmem_write) ,
			   .dmem_rd_value(r_dmem) ,
			   .dmem_wr_value(r_rs2) ,
			   .dmem_add(alu_out[9:0]) ,
			   .funct3(funct3) ,
			   .offset_flag_rd(offset_flag_rd) ,
			   .offset_flag_wr(offset_flag_wr) ,
			   .invalid_rdmem_flag(invalid_rdmem_flag) ,
			   .dmem_out_bound_flag_rd(dmem_out_bound_flag_rd) ,
			   .dmem_out_bound_flag_wr(dmem_out_bound_flag_wr) );

pc_nxt_mux pc_nxt(.alu_out(alu_out) ,
				  .jalr(jalr) ,
				  .pc_clc(pc_clc) );

branch_checker check1(.r_rs1(r_rs1) ,
					  .r_rs2(r_rs2) ,
					  .funct3(funct3) ,
					  .branch_ok(branch_ok) );
endmodule
