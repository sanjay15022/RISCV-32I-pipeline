module reg_wb(
			input wire [31:0] alu_out, 
			input wire [31:0] r_dmem,
			input wire [31:0] pc_plus4,
			output reg [31:0] w_rd,
			input wire [1:0] reg_wb,
			input wire [31:0] imm_u);

always @(*) begin
	case(reg_wb)
		2'b00: w_rd = alu_out;
		2'b01: w_rd = r_dmem;
		2'b10: w_rd = pc_plus4;
		2'b11: w_rd = imm_u;
		default: w_rd = 32'b0;
	endcase
end
endmodule