module imm_sel(
				input wire [31:0] imm_s,
				input wire [31:0] imm_l,
				input wire [31:0] imm_u,
				input wire [31:0] imm_b,
				input wire [31:0] imm_j,
				input wire [2:0] imm_sel,
				output reg [31:0] imm);

always @(*) begin
	case(imm_sel)
	3'b000: imm = imm_l;
	3'b001: imm = imm_s;
	3'b010: imm = imm_u;
	3'b011: imm = imm_b;
	3'b100: imm = imm_j;
	default: imm = 32'b0;
	endcase
end
endmodule