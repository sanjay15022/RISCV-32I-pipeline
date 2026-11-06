module forwarding(
			   input wire [4:0] rs1 ,
			   input wire [4:0] rs2,
			   input wire [31:0] r_rs1,
			   					 r_rs2,
			   input wire [4:0] rd_idexe,
			   input wire [4:0] rd_exemem,
			   input wire [4:0] rd_memwb,
			   input wire [31:0] w_rd1,w_rd2,w_rd,
			   output reg [31:0] r_rs1_f , 
			   					 r_rs2_f, 
			   input wire  reg_write_idexe ,
			   		       reg_write_exemem ,
					       reg_write_memwb ,
				input wire reg_read , reg_read2,

				input wire dmem_read_idexe,
				output reg stall);
			   /*input wire [31:0] alu_ip1,
			   input wire [31:0] alu_ip2,
			   input wire [31:0] alu_out,
			   output reg [31:0] alu_ip1_f,
			   output reg [31:0] alu_ip2_f);*/

always @(*) begin 

		
	 stall = 1'b0;

	 if (rs1==rd_idexe & rd_idexe!= 5'b0 & reg_write_idexe) r_rs1_f = w_rd1;
	 else if (rs1==rd_exemem & rd_exemem!= 5'b0 & reg_write_exemem) r_rs1_f = w_rd2;
	 else if (rs1==rd_memwb & rd_memwb!= 5'b0 & reg_write_memwb) r_rs1_f = w_rd;
	 else r_rs1_f = r_rs1;

	 if (rs2==rd_idexe & rd_idexe!= 5'b0 & reg_write_idexe) r_rs2_f = w_rd1;
	 else if (rs2==rd_exemem & rd_exemem!= 5'b0 & reg_write_exemem) r_rs2_f = w_rd2;
	 else if (rs2==rd_memwb & rd_memwb!= 5'b0 & reg_write_memwb) r_rs2_f = w_rd;
	 else r_rs2_f = r_rs2;

	//stall 

	 if(((rs1 == rd_idexe & reg_read )| ( rs2 == rd_idexe & reg_read2) ) & rd_idexe!= 5'b0 & reg_write_idexe & dmem_read_idexe) stall = 1'b1;
	 

 end 



endmodule