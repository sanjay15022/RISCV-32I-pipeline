module pc_nxt_mux(
			input wire [31:0] alu_out,
			input wire jalr,
			output wire [31:0] pc_clc);

assign pc_clc = (jalr == 1'b0) ? alu_out : {alu_out[31:1] , 1'b0} ;

endmodule 