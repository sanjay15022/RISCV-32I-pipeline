module main_pipe(
			input wire clk);

// pc
wire [31:0] pc,pc_plus4;

//instr reg
wire [31:0] instr;

//if idbreg 

wire [31:0]pc_ifid,pc_plus4_ifid,instr_ifid;

//splitter

wire [31:0] imm_s,imm_l,imm_j,imm_u,imm_b;
wire [4:0] rs1,rs2,rd;
wire [6:0] opcode,funct7;
wire [2:0] funct3;

//ctrl unit 

wire [3:0] alu_ctrl;
wire alu_src1,alu_src2,reg_read,reg_write,dmem_read,dmem_write,branch,jalr,jump;
wire [2:0] imm_sel;
wire [1:0] reg_wb;
wire [3:0] alu_out_flow;
wire f1_enb,f2_enb;
wire reg_read2;

//register

wire [31:0] r_rs1,r_rs2;

//imm_select

wire [31:0] imm;

//alu source

wire [31:0] alu_ip1,alu_ip2;

// forwarding 
wire fA1,fA2,fB1,fB2,fC1,fC2;
wire [31:0] alu_ip1_f,alu_ip2_f;
wire [31:0] r_rs1_f,r_rs2_f;
wire stall ;
// id exe register 

wire [31:0] instr_idexe,alu_ip1_idexe,alu_ip2_idexe,pc_idexe,pc_plus4_idexe,imm_u_idexe,r_rs1_idexe,r_rs2_idexe;
wire [2:0] funct3_idexe;
wire [3:0] alu_ctrl_idexe;
wire [1:0] reg_wb_idexe;
wire [4:0] rd_idexe;
wire reg_write_idexe,dmem_read_idexe,dmem_write_idexe,branch_idexe,jalr_idexe,jump_idexe;

//alu

wire [31:0] alu_out;
wire neg_flag,zero_flag;

//branch checker

wire branch_ok; 

// reg_wb1

wire [31:0] w_rd1;

//exe mem register 

wire [31:0] alu_out_exemem,imm_u_exemem,pc_plus4_exemem,r_rs2_exemem,w_rd_exemem;
wire [1:0] reg_wb_exemem;
wire [2:0] funct3_exemem;
wire [4:0] rd_exemem;
wire branch_ok_exemem,reg_write_exemem,dmem_read_exemem,dmem_write_exemem,branch_exemem,jalr_exemem,jump_exemem;


//pc nxt mux 

wire [31:0] pc_clc;

//data memory 

wire [31:0] r_dmem;
wire offset_flag_rd,invalid_rdmem_flag,dmem_out_bound_flag_rd,dmem_out_bound_flag_wr,offset_flag_wr;

// mem wb register 

wire [31:0] alu_out_memwb,imm_u_memwb,r_dmem_memwb,pc_plus4_memwb,w_rd;
wire [1:0] reg_wb_memwb;
wire [4:0] rd_memwb;
wire reg_write_memwb;

//reg wb2

wire [31:0] w_rd2;


pc pc1(.clk(clk) ,
	   .branch_future(branch_idexe) ,
	   .branch_ok(branch_ok) ,
	   .jump_future(jump_idexe) ,
	   .jalr_future(jalr_idexe) ,
	   .pc(pc) ,
	   .pc_plus4(pc_plus4) ,
	   .pc_clc(pc_clc) ,
	   .stall(stall) );

instr_reg instr_reg1(.clk(clk) ,
					 .instr_add(pc[9:0]) ,
					 .instr(instr));

if_id_reg if_id_reg1 (.clk(clk) ,
					  .instr(instr) ,
					  .pc(pc) ,
					  .pc_plus4(pc_plus4) ,
					  .branch_ok(branch_ok) ,
					  .branch_future(branch_idexe) ,
					  .jump_future(jump_idexe) ,
					  .jalr_future(jalr_idexe) ,
					  .stall(stall) ,

					  .pc_reg(pc_ifid),
					  .pc_plus4_reg(pc_plus4_ifid) ,
					  .instr_reg(instr_ifid));

splitter splitter1(.instr(instr_ifid) ,
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
					 .reg_read(reg_read) ,
					 .reg_write(reg_write) ,
					 .dmem_read(dmem_read) ,
					 .dmem_write(dmem_write) ,
					 .branch(branch) ,
					 .jalr(jalr) ,
					 .jump(jump) ,
					 .f1_enb(f1_enb) ,
					 .f2_enb(f2_enb) ,
					 .reg_read2(reg_read2) );

register register1(.clk(clk) ,
				   .reg_read(reg_read) ,
				   .reg_write(reg_write_memwb) ,
				   .rs1(rs1) ,
				   .rs2(rs2) ,
				   .rd(rd_memwb) ,
				   .r_rs1(r_rs1) ,
				   .r_rs2(r_rs2) ,
				   .w_rd(w_rd));

imm_sel imm_sel1(.imm_s(imm_s) ,
				 .imm_l(imm_l) ,
				 .imm_u(imm_u) ,
				 .imm_b(imm_b) ,
				 .imm_j(imm_j) ,
				 .imm_sel(imm_sel) ,
				 .imm(imm));

forwarding forward1(.rs1(rs1) ,
					.rs2(rs2) ,
					.r_rs1(r_rs1) ,
					.r_rs2(r_rs2) ,
					.w_rd1(w_rd1) ,
					.w_rd2(w_rd2) ,
					.w_rd(w_rd) ,
					.reg_write_idexe(reg_write_idexe) ,
					.reg_write_exemem(reg_write_exemem) ,
					.reg_write_memwb(reg_write_memwb),
					.rd_idexe(rd_idexe) ,
					.rd_exemem(rd_exemem) ,
					.rd_memwb(rd_memwb) ,
					.dmem_read_idexe(dmem_read_idexe) ,
					.reg_read(reg_read) ,
					.reg_read2(reg_read2) ,

					.stall(stall) ,
					.r_rs1_f(r_rs1_f) ,
					.r_rs2_f(r_rs2_f));


alu_src alu_src_1 (.r_rs1_f(r_rs1_f) ,
				   .r_rs2_f(r_rs2_f) ,
				   .imm(imm) ,
				   .pc(pc_ifid) ,
				   .alu_src1(alu_src1) ,
				   .alu_src2(alu_src2) ,
				   .alu_ip1(alu_ip1) ,
				   .alu_ip2(alu_ip2) );


/*forward_mux forward_mux1(.fA1(fA1) ,
						 .fB1(fB1) ,
						 .fA2(fA2) ,
						 .fB2(fB2) ,
						 .fC1(fC1) ,
						 .fC2(fC2) ,
						 .f1_enb(f1_enb) ,
						 .f2_enb(f2_enb) ,
				   		 .alu_ip1(alu_ip1) ,
				  	     .alu_ip2(alu_ip2) ,
				  	     .reg_write_idexe(reg_write_idexe) ,
				  	     .reg_write_exemem(reg_write_exemem) ,
				  	     .w_rd1(w_rd1) ,
				  	     .w_rd(w_rd) , /// memwb
				  	     .w_rd2(w_rd2) ,
				  	     .reg_write_memwb(reg_write_memwb),

				  	     .alu_ip1_f(alu_ip1_f) ,
				  	     .alu_ip2_f(alu_ip2_f) ); */

id_exe_reg id_exe_reg1(.clk(clk) ,
					   .branch_ok(branch_ok) ,
					   .branch_future(branch_idexe) ,
					   .jump_future(jump_idexe) ,
					   .jalr_future(jalr_idexe) ,	
					   .instr(instr_ifid) ,
					   .funct3(funct3) ,
					   .alu_ctrl(alu_ctrl) ,
					   .alu_ip1(alu_ip1) ,
					   .alu_ip2(alu_ip2) ,
					   .reg_wb(reg_wb) ,
					   .reg_write(reg_write) ,
					   .dmem_read(dmem_read) ,
					   .dmem_write(dmem_write) ,
					   .branch(branch) ,
					   .jalr(jalr) ,
					   .jump(jump) ,
					   .pc(pc_ifid) ,
					   .pc_plus4(pc_plus4_ifid) ,
					   .imm_u(imm_u) ,
					   .r_rs1(r_rs1_f) ,
					   .r_rs2(r_rs2_f) ,
					   .rd(rd) ,
					   .stall(stall) ,
					   
					   .instr_reg(instr_idexe) ,
					   .funct3_reg(funct3_idexe) ,
					   .alu_ctrl_reg(alu_ctrl_idexe) ,
					   .alu_ip1_reg(alu_ip1_idexe) ,
					   .alu_ip2_reg(alu_ip2_idexe) ,
					   .reg_wb_reg(reg_wb_idexe) ,
					   .reg_write_reg(reg_write_idexe) ,
					   .dmem_read_reg(dmem_read_idexe) ,
					   .dmem_write_reg(dmem_write_idexe) ,
					   .branch_reg(branch_idexe) ,
					   .jalr_reg(jalr_idexe) ,
					   .jump_reg(jump_idexe) ,
					   .pc_reg(pc_idexe) ,
					   .pc_plus4_reg(pc_plus4_idexe) ,
					   .imm_u_reg(imm_u_idexe) ,
					   .r_rs1_reg(r_rs1_idexe) ,
					   .r_rs2_reg(r_rs2_idexe) ,
					   .rd_reg(rd_idexe) );

alu alu1(.alu_ip1(alu_ip1_idexe) ,
		 .alu_ip2(alu_ip2_idexe) ,
		 .alu_ctrl(alu_ctrl_idexe) ,
		 .alu_out(alu_out) ,
		 .neg_flag(neg_flag) ,
		 .zero_flag(zero_flag) );

branch_checker checker1(.r_rs1(r_rs1_idexe) ,
					    .r_rs2(r_rs2_idexe) ,
					    .funct3(funct3_idexe) ,
					    .branch_ok(branch_ok) ); 

reg_wb1 reg_wb1_1(.imm_u(imm_u_idexe) ,
				  .pc_plus4(pc_plus4_idexe) ,
				  .alu_out(alu_out) ,
				  .reg_wb(reg_wb_idexe) ,
				  .w_rd1(w_rd1) );

exe_mem_reg exe_mem_reg1(.clk(clk) ,
						 .alu_out(alu_out) ,
						 .branch_ok(branch_ok) ,
						 .reg_wb(reg_wb_idexe) ,
						 .reg_write(reg_write_idexe) ,
						 .dmem_read(dmem_read_idexe) ,
						 .dmem_write(dmem_write_idexe) ,
						 .branch(branch_idexe) ,
						 .jalr(jalr_idexe) ,
						 .jump(jump_idexe) ,
						 .imm_u(imm_u_idexe) ,
						 .r_rs2(r_rs2_idexe),
						 .funct3(funct3_idexe),
						 .pc_plus4(pc_plus4_idexe), 
						 .rd(rd_idexe),
						 .w_rd(w_rd1),

						 .alu_out_reg(alu_out_exemem) ,
						 .branch_ok_reg(branch_ok_exemem) ,
						 .reg_wb_reg(reg_wb_exemem) ,
						 .reg_write_reg(reg_write_exemem) ,
						 .dmem_read_reg(dmem_read_exemem) ,
						 .dmem_write_reg(dmem_write_exemem) ,
						 .branch_reg(branch_exemem) ,
						 .jalr_reg(jalr_exemem) ,
						 .jump_reg(jump_exemem) ,
						 .imm_u_reg(imm_u_exemem) ,
						 .r_rs2_reg(r_rs2_exemem) ,
						 .funct3_reg(funct3_exemem) ,
						 .pc_plus4_reg(pc_plus4_exemem) ,
						 .rd_reg(rd_exemem) ,
						 .w_rd_reg(w_rd_exemem));

pc_nxt_mux pc_nxt_mux1(.alu_out(alu_out) ,
					   .jalr(jalr_idexe) ,
					   .pc_clc(pc_clc) );

data_mem dmem1(.clk(clk) ,
			   .dmem_read(dmem_read_exemem) ,
			   .dmem_write(dmem_write_exemem) ,
			   .dmem_rd_value(r_dmem) ,
			   .dmem_wr_value(r_rs2_exemem) ,
			   .dmem_add(alu_out_exemem[9:0]) ,
			   .funct3(funct3_exemem) ,
			   .offset_flag_rd(offset_flag_rd) ,
			   .offset_flag_wr(offset_flag_wr) ,
			   .invalid_rdmem_flag(invalid_rdmem_flag) ,
			   .dmem_out_bound_flag_rd(dmem_out_bound_flag_rd) ,
			   .dmem_out_bound_flag_wr(dmem_out_bound_flag_wr) );

reg_wb2 reg_wb2_1(.w_rd_exemem(w_rd_exemem) ,
				  .r_dmem(r_dmem) ,
				  .reg_wb(reg_wb_exemem) ,
				  .w_rd2(w_rd2) );

mem_wb_reg mem_wb_reg1(.clk(clk) ,
					   .alu_out(alu_out_exemem) ,
					   .imm_u(imm_u_exemem) ,
					   .r_dmem(r_dmem) ,
					   .pc_plus4(pc_plus4_exemem) ,
					   .reg_wb(reg_wb_exemem) ,
					   .reg_write(reg_write_exemem) ,
					   .rd(rd_exemem),
					   .w_rd(w_rd2),

					   .alu_out_reg(alu_out_memwb) ,
					   .imm_u_reg(imm_u_memwb) ,
					   .r_dmem_reg(r_dmem_memwb) ,
					   .pc_plus4_reg(pc_plus4_memwb) ,
					   .reg_wb_reg(reg_wb_memwb) ,
					   .reg_write_reg(reg_write_memwb) ,
					   .rd_reg(rd_memwb) ,
					   .w_rd_reg(w_rd));

/*reg_wb reg_wb1(.alu_out(alu_out_memwb) ,
			   .r_dmem(r_dmem_memwb) ,
			   .pc_plus4(pc_plus4_memwb) ,
			   .reg_wb(reg_wb_memwb) ,
			   .imm_u(imm_u_memwb) ,
			   .w_rd(w_rd) ); */



endmodule