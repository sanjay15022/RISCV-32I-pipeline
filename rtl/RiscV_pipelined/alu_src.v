module alu_src(
	input wire [31:0] r_rs1,
	input wire [31:0] r_rs2,
	input wire [31:0] imm,
	input wire [31:0] pc,
	input wire alu_src1,
	input wire alu_src2,
	output wire [31:0] alu_ip1,
	output wire [31:0] alu_ip2);

assign alu_ip1 = (alu_src1 == 1'b0) ? r_rs1 : pc;
assign alu_ip2 = (alu_src2 == 1'b0) ? r_rs2 : imm;

/*always @(*) begin
	casez({fA1,fB1,reg_write_idexe,reg_write_exemem})  // casrres abt lau_ip1 only

		4'b00??:begin
			 	alu_ip1 = (alu_src1 == 1'b0) ? r_rs1 : pc;
		 end
		4'b1?1?: begin
				alu_ip1 = alu_out;
		end 
		4'b01?1: begin
			alu_ip1 = alu_out_exemem;
		end
		*4'b111?: begin
			alu_ip1 = alu_out;
		end*
		default: alu_ip1 = (alu_src1 == 1'b0) ? r_rs1 : pc;

	endcase

	casez({fA2,fB2,reg_write_idexe,reg_write_exemem}) // cares abt alu_ip2 only

		4'b00??:begin
	 			alu_ip2 = (alu_src2 == 1'b0) ? r_rs2 : imm;
		end
		4'b1?1?: begin
			alu_ip2 = alu_out;
		end 
		4'b01?1: begin
			alu_ip2 = alu_out_exemem;
		end
		*4'b111x: begin
			alu_ip2 = alu_out;
		end*
		default: alu_ip2 = (alu_src2 == 1'b0) ? r_rs2 : imm;
	endcase
end
*/
endmodule