module alu(
			input wire [31:0] alu_ip1,
			input wire [31:0] alu_ip2,
			input wire [3:0] alu_ctrl,
			output reg [31:0] alu_out,
			output reg neg_flag,
			output reg zero_flag);

wire signed [31:0] alu_ip1_s = alu_ip1;
wire signed [31:0] alu_ip2_s = alu_ip2;
reg signed [31:0] alu_out_s;

always @(*) begin

        neg_flag=1'b0;
        zero_flag= 1'b0;

		case(alu_ctrl)
		4'b0000: alu_out = alu_ip1 + alu_ip2;                         // add / addi
        4'b0001: begin
             alu_out = alu_ip1 - alu_ip2; 
             alu_out_s = alu_out;
            if (alu_out_s == 0) begin
               zero_flag= 1'b1;
               end
            else if (alu_out_s < 0) begin
              neg_flag = 1'b1; 
              end 
        end                    // sub
        4'b0010: alu_out = alu_ip1 << alu_ip2[4:0];                   // sll / slli
        4'b0011: alu_out = (alu_ip1_s < alu_ip2_s) ? 32'd1 : 32'd0;       // slt / slti
        4'b0100: alu_out = (alu_ip1 < alu_ip2) ? 32'd1 : 32'd0;       // sltu / sltiu
        4'b0101: alu_out = alu_ip1 ^ alu_ip2;                         // xor / xori
        4'b0110: alu_out = alu_ip1 >> alu_ip2[4:0];                   // srl / srli
        4'b0111: alu_out = alu_ip1_s >>> alu_ip2[4:0];                  // sra / srai
        4'b1000: alu_out = alu_ip1 | alu_ip2;                         // or / ori
        4'b1001: alu_out = alu_ip1 & alu_ip2;                         // and / andi
        default: alu_out = 32'b0;
	endcase	
end

endmodule