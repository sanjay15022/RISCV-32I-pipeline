module register (
				input wire clk,
				input wire reg_read,
				input wire reg_write,
				input wire [4:0] rs1,
				input wire [4:0] rs2,
				input wire [4:0] rd,
				output wire [31:0] r_rs1,
				output wire [31:0] r_rs2,
				input wire [31:0] w_rd);

reg [31:0] register [0:31];

integer i;
	initial for (i=0; i<32; i=i+1)
		register[i] = 32'd0;

assign r_rs1 = (reg_read == 1'b1) ? register[rs1] : 32'd0;
assign r_rs2 = (reg_read == 1'b1) ? register[rs2] : 32'd0;

always @(posedge clk ) begin
	if((reg_write == 1'b1) && (rd!=5'd0)) register[rd] <= w_rd;
end

endmodule