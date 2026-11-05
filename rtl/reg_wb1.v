module reg_wb1( 
				input wire [31:0] imm_u,
								  pc_plus4,
								  alu_out,
				input wire [1:0] reg_wb,
				output reg [31:0] w_rd1);

always @(*) begin
	case(reg_wb)
		2'b00: w_rd1 = alu_out;
		2'b10: w_rd1 = pc_plus4;
		2'b11: w_rd1 = imm_u;
		default: w_rd1 = 32'b0;
	endcase
end

endmodule