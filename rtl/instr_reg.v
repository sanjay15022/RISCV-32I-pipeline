module instr_reg(
				input wire clk,
				input wire [9:0] instr_add,
				output reg [31:0] instr
				);
reg [7:0] instr_reg [0:1023] ;

integer i;
initial begin
    for (i = 0; i < 1024; i = i + 1)
        instr_reg[i] = 8'h00;
       end
initial $readmemh("program.hex" , instr_reg);

always @(*) begin // byte allignment
	if(instr_add[1:0]==2'b00) instr = {instr_reg[instr_add+3] , instr_reg[instr_add+2] , instr_reg[instr_add+1] , instr_reg[instr_add]};
	else instr = 32'b0;
end

endmodule