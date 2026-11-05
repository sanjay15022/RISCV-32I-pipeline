module forwarding(
			   input wire [4:0] rs1 ,
			   input wire [4:0] rs2,
			   input wire [4:0] rd_idexe,
			   input wire [4:0] rd_exemem,
			   input wire [4:0] rd_memwb,
			   output wire fA1,fA2,fB1,fB2,fC1,fC2);
			   /*input wire [31:0] alu_ip1,
			   input wire [31:0] alu_ip2,
			   input wire [31:0] alu_out,
			   output reg [31:0] alu_ip1_f,
			   output reg [31:0] alu_ip2_f);*/

assign fA1 = (rs1==rd_idexe & rd_idexe!= 5'b0) ? 1'b1 : 1'b0 ;
assign fB1 = (rs1==rd_exemem & rd_exemem!= 5'b0) ? 1'b1 : 1'b0 ;
assign fC1 = (rs1==rd_memwb & rd_memwb!= 5'b0) ? 1'b1 : 1'b0 ;

assign fA2 = (rs2==rd_idexe & rd_idexe!= 5'b0) ? 1'b1 : 1'b0 ;
assign fB2 = (rs2==rd_exemem & rd_exemem!= 5'b0) ? 1'b1 : 1'b0 ;
assign fC2 = (rs2==rd_memwb & rd_memwb!= 5'b0) ? 1'b1 : 1'b0 ;




endmodule