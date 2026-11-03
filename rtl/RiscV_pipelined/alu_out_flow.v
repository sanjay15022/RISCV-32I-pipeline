/// alu out can be written to registe pc or stored in dmem 

module alu_out_flow(
			input wire [31:0] alu_out,
			input wire [3:0] alu_out_flow,
			output reg [31:0] pc_clc,
			output reg [31:0] wr_rd,
			output reg [9:0] dmem_add );

always @(*) begin
	case(alu_out_flow)
		3'b000: begin
			wr_rd = alu_out;
			pc_clc = 32'b0;
			dmem_add= 9'b0;
				end
		3'b001: begin
			pc_clc = alu_out;
			wr_rd = 9'b0;
			dmem_add= 32'b0;
				end
		3'b010: begin
			dmem_add = alu_out[9:0];
			pc_clc = 32'b0;
			wr_rd = 32'b0;
		end
		default:begin
			wr_rd = 32'b0;
			pc_clc = 32'b0;
			dmem_add= 9'b0;
		end
	endcase
end

endmodule 