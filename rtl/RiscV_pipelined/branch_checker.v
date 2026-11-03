module branch_checker(
					input wire [31:0] r_rs1,
					input wire [31:0] r_rs2,
					input wire [2:0] funct3,
					output reg branch_ok);

always @(*) begin

	branch_ok = 1'b0;
	
	case(funct3)
			3'b000: if(r_rs1 == r_rs2) branch_ok = 1'b1; ///BEQ
			3'b001: if(r_rs1 != r_rs2) branch_ok = 1'b1; ///BNE
			3'b100: if($signed(r_rs1) < $signed(r_rs2)) branch_ok = 1'b1; ///BLT
			3'b101: if($signed(r_rs1) >= $signed(r_rs2)) branch_ok = 1'b1; ///BGE
			3'b110: if(r_rs1 < r_rs2) branch_ok = 1'b1; ///BLTU
			3'b111: if(r_rs1 >= r_rs2) branch_ok = 1'b1; ///BGEU
			default: branch_ok = 1'b0;
	endcase
end
endmodule