`timescale 1ns/1ps
module tst_full_forwarding;
 reg clk; integer pass_count,fail_count;
 main_pipe uut(.clk(clk));
 always #5 clk=~clk;
 task cr; input [4:0] n; input [31:0] e; input [8*42-1:0] s;
 begin
  if(uut.register1.register[n]===e) begin
   $display("PASS %-42s x%0d = %08h",s,n,uut.register1.register[n]); pass_count=pass_count+1;
  end else begin
   $display("FAIL %-42s x%0d expected %08h got %08h",s,n,e,uut.register1.register[n]); fail_count=fail_count+1;
  end
 end endtask
 task cm; input integer a; input [31:0] e; input [8*42-1:0] s; reg [31:0] g;
 begin
  g={uut.dmem1.dmemory[a+3],uut.dmem1.dmemory[a+2],uut.dmem1.dmemory[a+1],uut.dmem1.dmemory[a]};
  if(g===e) begin $display("PASS %-42s MEM[%0d]=%08h",s,a,g); pass_count=pass_count+1; end
  else begin $display("FAIL %-42s MEM[%0d] expected %08h got %08h",s,a,e,g); fail_count=fail_count+1; end
 end endtask
 initial begin
  clk=0; pass_count=0; fail_count=0;
  // No NOP/stall instructions. Every load consumer has one independent instruction in between.
  repeat(150) @(posedge clk); #2;
  $display("\n===== RV32I FULL FORWARDING TEST =====");
  cm(240,32'd102,"R-type result");
  cm(244,32'd103,"R-type -> I-type");
  cm(248,32'd205,"Two forwarded R operands");
  cm(252,32'd208,"ADDI result");
  cm(256,32'd80,"ANDI result");

  cr(17,0,"BEQ skipped instruction");
  cr(18,0,"BNE skipped instruction");
  cr(19,0,"BLT skipped instruction");
  cr(20,0,"BGE skipped instruction");
  cr(21,0,"BLTU skipped instruction");
  cr(22,0,"BGEU skipped instruction");
  cr(23,1,"BEQ target");
  cr(24,2,"BNE target");
  cr(25,3,"BLT target");
  cr(26,4,"BGE target");
  cr(27,5,"BLTU target");
  cr(28,6,"BGEU target");

  cm(180,32'h12345000,"LUI result");
  cm(184,32'h12345678,"LUI -> ADDI");
  cm(188,32'h000010cc,"AUIPC result");
  cm(192,32'h000010d1,"AUIPC -> ADDI");

  cr(3,32'd232,"JAL link -> ADDI");
  cr(30,32'd248,"JALR forwarded target base");
  cr(31,32'd244,"JALR link PC+4");
  cr(2,32'd245,"JALR link -> ADDI");

  cm(164,32'h0000005a,"SW forwarded store data");
  cm(168,32'h01230033,"SB and SH byte lanes");
  cm(200,32'h0000005a,"Computed store address forwarding");
  cm(176,32'hffffff80,"LW -> SW store data");

  cr(5,32'hffffff80,"LB sign extension");
  cr(6,32'hffffff80,"LB -> I-type");
  cr(7,32'd128,"LBU zero extension");
  cr(8,32'd128,"LBU -> I-type");
  cr(9,32'hffffff80,"LH sign extension");
  cr(10,32'hffffff80,"LH -> I-type");
  cr(11,32'h0000ff80,"LHU zero extension");
  cr(12,32'h0000ff80,"LHU -> I-type");
  cr(13,32'hffffff80,"LW result");
  cr(14,32'hffffff80,"LW -> I-type");
  cr(15,32'hffffff80,"LW -> SW data source");

  $display("\nTOTAL: %0d PASS, %0d FAIL",pass_count,fail_count); $finish;
 end
endmodule
