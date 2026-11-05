module reg_wb2(
				input wire [31:0] w_rd_exemem ,
				input wire [31:0] r_dmem,
				input wire [1:0] reg_wb,
				output wire [31:0] w_rd2 );

assign w_rd2 = (reg_wb == 2'b01 ) ? r_dmem : w_rd_exemem ;

endmodule