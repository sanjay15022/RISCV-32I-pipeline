module forward_mux( input wire fA1,fB1,fA2,fB2,fC1,fC2,
					input wire reg_write_idexe,reg_write_exemem,reg_write_memwb,
					input wire [31:0] alu_out,alu_out_exemem,alu_out_memwb,
					input wire [31:0] alu_ip1,alu_ip2,w_rd,
					output reg [31:0] alu_ip1_f,alu_ip2_f);

/*always @(*) begin

	casez({fA1,fB1,reg_write_idexe,reg_write_exemem})  // casrres abt lau_ip1 only

		4'b00??:begin
			 	alu_ip1_f = alu_ip1;
		 end
		4'b1?1?: begin
				alu_ip1_f = alu_out;
		end 
		4'b01?1: begin
			alu_ip1_f = alu_out_exemem;
		end
		4'b111?: begin
			alu_ip1_f = alu_out;
		end
		default: alu_ip1_f = alu_ip1;

	endcase

	casez({fA2,fB2,reg_write_idexe,reg_write_exemem}) // cares abt alu_ip2 only

		4'b00??:begin
	 			alu_ip2_f = alu_ip2;
		end
		4'b1?1?: begin
			alu_ip2_f = alu_out;
		end 
		4'b01?1: begin
			alu_ip2_f = alu_out_exemem;
		end
		4'b111?: begin
			alu_ip2_f = alu_out;
		end
		default: alu_ip2_f = alu_ip2;
	endcase
		

end*/

always @(*) begin

    // Operand 1
    if (fA1 && reg_write_idexe)
        alu_ip1_f = alu_out;
    else if (fB1 && reg_write_exemem)
        alu_ip1_f = alu_out_exemem;
    else if(fC1 && reg_write_memwb)
    	alu_ip1_f = alu_out_memwb; //w_rd
    else
        alu_ip1_f = alu_ip1;

    // Operand 2
    if (fA2 && reg_write_idexe)
        alu_ip2_f = alu_out;
    else if (fB2 && reg_write_exemem)
        alu_ip2_f = alu_out_exemem;
    else if(fC2 && reg_write_memwb)
    	alu_ip2_f = alu_out_memwb;        
    else
        alu_ip2_f = alu_ip2; //w_rd

end
endmodule