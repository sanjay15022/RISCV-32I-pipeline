module pc(
			input wire clk,
			output reg [31:0] pc,
			input wire [31:0] pc_clc,
			input wire branch_future,
			input wire branch_ok,
			input wire jump_future,
			input wire jalr_future,
			output wire [31:0] pc_plus4);

wire [31:0] pc_nxt;
initial pc = 32'd0;

assign pc_plus4 = pc+4;

always @(posedge clk) begin
	if(branch_future==1'b1 && branch_ok == 1'b1 ) pc <= pc_clc;
	else if(jump_future ==1'b1) pc <= pc_clc;
	else if(jalr_future == 1'b1) pc <= pc_clc;
	else pc <= pc+4;
end

endmodule