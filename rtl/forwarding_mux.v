module forward_mux( input wire fA1,fB1,fA2,fB2,fC1,fC2,
					input wire reg_write_idexe,reg_write_exemem,reg_write_memwb,
					input wire [31:0] w_rd1,w_rd2,
					input wire [31:0] alu_ip1,alu_ip2,w_rd,
					output reg [31:0] alu_ip1_f,alu_ip2_f,

					// for forwarding 
					input wire f1_enb,f2_enb);

always @(*) begin

	if (f1_enb) begin  //f1_enb is 1 if theres a possibility of having data hazard that can be solved using forwarding 
	    // Operand 1
	    if (fA1 && reg_write_idexe)
	        alu_ip1_f = w_rd1;
	    else if (fB1 && reg_write_exemem)
	        alu_ip1_f = w_rd2;
	    else if(fC1 && reg_write_memwb)
	    	alu_ip1_f = w_rd; //w_rd
	    else
	        alu_ip1_f = alu_ip1;
	end

	else alu_ip1_f = alu_ip1;

	if (f2_enb) begin
	    // Operand 2
	    if (fA2 && reg_write_idexe)
	        alu_ip2_f = w_rd1;
	    else if (fB2 && reg_write_exemem)
	        alu_ip2_f = w_rd2;
	    else if(fC2 && reg_write_memwb)
	    	alu_ip2_f = w_rd;        
	    else
	        alu_ip2_f = alu_ip2; //w_rd
	end

	else alu_ip2_f = alu_ip2;


end
endmodule