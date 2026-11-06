module ctrl_unit (
					input wire [6:0] opcode,
					input wire [2:0] funct3,
					input wire [6:0] funct7,
					output reg [3:0] alu_ctrl,
					output reg alu_src1,
					output reg alu_src2,
					output reg [2:0] imm_sel,
					output reg [1:0] reg_wb,
					output reg [3:0] alu_out_flow,
					output reg reg_read,
					output reg reg_write,
					output reg dmem_read,
					output reg dmem_write,
					output reg branch,
					output reg jalr,
					output reg jump,
					output reg f1_enb,
					output reg f2_enb,
					output reg reg_read2
					 );

always @(*) begin
		alu_src1 = 1'b0;
		alu_src2 = 1'b0;
		imm_sel = 3'b0;
		reg_write = 1'b0;
		reg_read = 1'b0;
		dmem_write = 1'b0;
		dmem_read = 1'b0;
		alu_ctrl = 4'b0000;
		reg_wb = 2'b00;
		alu_out_flow = 4'b0000;
		branch = 1'b0;
		jalr = 1'b0;
		jump = 1'b0;
		f1_enb = 1'b0;
		f2_enb = 1'b0;
		reg_read2 = 1'b0;

	case(opcode)
			7'b0110011: begin /// r type

						alu_src1 = 1'b0;
						alu_src2 = 1'b0;
						reg_wb = 2'b00;
						alu_out_flow = 4'b0000;
						reg_write = 1'b1;
						reg_read = 1'b1;
						f1_enb = 1'b1;
						f2_enb = 1'b1;
						reg_read2 = 1'b1;

				case(funct3)
					3'b000: begin
							if(funct7 == 7'b0) alu_ctrl = 4'b0000; //add
							else if(funct7 == 7'b0100000) alu_ctrl = 4'b0001; //sub
					end
					3'b001: begin //sll
						alu_ctrl = 4'b0010;
					end
					3'b010: begin  //slt
						alu_ctrl = 4'b0011;
					end
					3'b011: begin //sltu
						alu_ctrl = 4'b0100;
					end
					3'b100: begin //xor
						alu_ctrl = 4'b0101;
					end
					3'b101: begin 
						if(funct7 == 7'b0) alu_ctrl = 4'b0110; //srl
						else if(funct7 == 7'b0100000) alu_ctrl = 4'b0111; //sra
					end
					3'b110: begin //or
						alu_ctrl = 4'b1000;
					end
					3'b111: begin //and
						alu_ctrl = 4'b1001;
					end																				
				endcase 
			end

			7'b0010011: begin ///imm arithmetic tpye 
				
						alu_src1 = 1'b0;
						alu_src2 = 1'b1;
						reg_wb = 2'b00;
						alu_out_flow = 4'b0000;
						reg_write = 1'b1;
						reg_read = 1'b1;
						imm_sel = 3'b000;
						f1_enb = 1'b1;
						f2_enb = 1'b0;
						reg_read2 = 1'b0;

				case(funct3)
					3'b000: begin
						alu_ctrl = 4'b0000; //addi
					end
					3'b001: begin //slli
						alu_ctrl = 4'b0010;
					end
					3'b010: begin  //slti
						alu_ctrl = 4'b0011;
					end
					3'b011: begin //sltui
						alu_ctrl = 4'b0100;
					end
					3'b100: begin //xori
						alu_ctrl = 4'b0101;
					end
					3'b101: begin 
						if(funct7[5] == 1'b0) alu_ctrl = 4'b0110; //srli
						else if(funct7[5] == 1'b1) alu_ctrl = 4'b0111; //srai
					end
					3'b110: begin //ori
						alu_ctrl = 4'b1000;
					end
					3'b111: begin //andi
						alu_ctrl = 4'b1001;
					end																				
				endcase 

			end

			7'b0000011:  begin //load tpye

					alu_src1 = 1'b0;
					alu_src2 = 1'b1;
					alu_ctrl = 4'b0000;
					reg_wb = 2'b01;
					dmem_read = 1'b1;
					reg_read = 1'b1;
					reg_write = 1'b1;
					alu_out_flow = 3'b010;
					imm_sel = 3'b000;
					f1_enb = 1'b1;
					f2_enb = 1'b0;

			end

			7'b1100111: begin //jalr
			if(funct3 == 3'b000) begin	
				alu_src1 = 1'b0;
				alu_src2 = 1'b1;
				alu_ctrl = 4'b0000;				
				imm_sel = 3'b000;
				alu_out_flow = 3'b001;
				reg_write = 1'b1;
				reg_read = 1'b1; 
				reg_wb = 2'b10;
				jalr = 1'b1;
				f1_enb = 1'b1;
				f2_enb = 1'b0;
				reg_read2 = 1'b0;

				end
			end

			7'b0100011: begin ///store type 
				
				alu_src1 = 1'b0;
				alu_src2 = 1'b1;
				alu_out_flow = 3'b010;
				alu_ctrl = 4'b0000;
				dmem_read = 1'b0;
				dmem_write = 1'b1;
				reg_read = 1'b1;
				reg_write = 1'b0;
				reg_wb = 2'b00;
				imm_sel = 3'b001;
				f1_enb = 1'b1;
				f2_enb = 1'b1;
				reg_read2 = 1'b1;

			end

			7'b1100011: begin ///branch

				alu_src1 = 1'b1;
				alu_src2 = 1'b1;
				imm_sel = 3'b011;
				alu_ctrl = 4'b0000;
				alu_out_flow = 3'b001;
				reg_read = 1'b1;
				branch = 1'b1;
				jalr = 1'b0;
				f1_enb = 1'b1;
				f2_enb = 1'b1;
				reg_read2 = 1'b1;

			end

			7'b1101111: begin /// j type
				
				alu_src1 = 1'b1;
				alu_src2 = 1'b1;
				alu_out_flow = 3'b001;
				jump = 1'b1;
				reg_read = 1'b0;
				reg_write = 1'b1;
				reg_wb = 2'b10;
				imm_sel = 3'b100;
				jalr = 1'b0;
				f1_enb = 1'b0;
				f2_enb = 1'b0;
				reg_read2 = 1'b0;

			end

			7'b0110111: begin ///u type LUI
				
				reg_wb = 2'b11;
				reg_write = 1'b1;
				f1_enb = 1'b0;
				f2_enb = 1'b0;
				reg_read2 = 1'b0;

			end

			7'b0010111: begin ///u type auipc
				
				imm_sel = 3'b010;
				reg_write = 1'b1;
				alu_src1 = 1'b1;
				alu_src2 = 1'b1;
				alu_out_flow = 3'b000;
				alu_ctrl = 4'b0000;
				reg_wb = 2'b00;
				f1_enb = 1'b0;
				f2_enb = 1'b0;
				reg_read2 = 1'b0;

			end

			7'b0001111: begin ///FENCE
				
			end

			7'b1110011: begin ///ECALL
				
			end

			7'b1110011: begin ///EBREAK
				
			end

	endcase
end

endmodule