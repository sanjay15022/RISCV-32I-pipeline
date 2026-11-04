`timescale 1ns/1ps
// I-type forwarding test for main_pipe (hex: itype_fwd_test.hex -> copy to program.hex).
// I-type instructions whose rs1 (or load/JALR base) is produced 1, 2 or 3 instructions earlier, NO NOP padding.
// Expected values come from a sequential RV32I model.
module tst_itype_fwd;
reg clk; integer cycles; integer i;
integer pass_c [0:5]; integer fail_c [0:5];
main_pipe uut (.clk(clk));
always #5 clk = ~clk;
task chk_mem; input integer cat; input [8*40-1:0] label; input integer a; input [31:0] expv; reg [31:0] got;
begin got = {uut.dmem1.dmemory[a+3], uut.dmem1.dmemory[a+2], uut.dmem1.dmemory[a+1], uut.dmem1.dmemory[a]};
  if (got === expv) begin pass_c[cat] = pass_c[cat] + 1; $display("  PASS  %0s  (= %0d)", label, $signed(got)); end
  else begin fail_c[cat] = fail_c[cat] + 1; $display("  FAIL  %0s  (expected %0d, got %0d)", label, $signed(expv), $signed(got)); end
end endtask
initial begin
  clk = 0; cycles = 0;
  for (i = 0; i < 6; i = i + 1) begin pass_c[i] = 0; fail_c[i] = 0; end
  #1;
  uut.dmem1.dmemory[0] = 8'd100;
  uut.dmem1.dmemory[8] = 8'd16;
  uut.dmem1.dmemory[16] = 8'd43;
  uut.dmem1.dmemory[17] = 8'd2;
  uut.dmem1.dmemory[204] = 8'd239;
  uut.dmem1.dmemory[205] = 8'd190;
  uut.dmem1.dmemory[206] = 8'd173;
  uut.dmem1.dmemory[207] = 8'd222;
  while ({uut.dmem1.dmemory[1003],uut.dmem1.dmemory[1002],uut.dmem1.dmemory[1001],uut.dmem1.dmemory[1000]} !== 32'd1 && cycles < 3000) begin @(posedge clk); cycles = cycles + 1; end
  repeat (6) @(posedge clk); #1;
  $display("========== I-TYPE FORWARDING TEST ==========");
  if (cycles >= 3000) $display("  TIMEOUT: done flag never set (CPU hung or went off the rails)");
  $display("Cycles to finish: %0d", cycles);
  $display(""); $display("-- I-type ALU, rs1 from ALU result (d1) --");
  chk_mem(0, "addi d1", 128, 32'd1311);
  chk_mem(0, "slti d1", 136, 32'd1);
  chk_mem(0, "sltiu d1", 144, 32'd1);
  chk_mem(0, "xori d1", 152, 32'd2042);
  chk_mem(0, "ori d1", 160, 32'd1013);
  chk_mem(0, "andi d1", 168, 32'd1699);
  chk_mem(0, "slli d1", 176, 32'd16032);
  chk_mem(0, "srli d1", 184, 32'd67108848);
  chk_mem(0, "srai d1", 192, 32'd4294967288);
  $display(""); $display("-- I-type ALU, rs1 from ALU result (d2) --");
  chk_mem(1, "addi d2", 200, 32'd1943);
  chk_mem(1, "andi d2", 208, 32'd1731);
  chk_mem(1, "slli d2", 216, 32'd170496);
  chk_mem(1, "srai d2", 224, 32'd4294967295);
  $display(""); $display("-- I-type ALU, rs1 at d3 (WB / fC path) --");
  chk_mem(2, "addi d3", 232, 32'd1533);
  chk_mem(2, "xori d3", 240, 32'd1702);
  chk_mem(2, "srai d3", 248, 32'd4294967198);
  $display(""); $display("-- I-type with LUI producer (d1, d2, d3) --");
  chk_mem(3, "lui -> addi d1", 256, 32'd305418872);
  chk_mem(3, "lui -> ori d2", 264, 32'd2882396193);
  chk_mem(3, "lui -> srli d3", 272, 32'd89478400);
  $display(""); $display("-- Load / JALR base from ALU result --");
  chk_mem(4, "lw base d1", 280, 32'd3735928559);
  chk_mem(4, "lbu base d2", 288, 32'd190);
  chk_mem(4, "lh base d3", 296, 32'd4294958765);
  chk_mem(4, "jalr base d1: link", 304, 32'd612);
  chk_mem(4, "jalr base d1: flush ok", 312, 32'd4294958765);
  chk_mem(4, "jalr base d2: link", 320, 32'd640);
  chk_mem(4, "jalr base d2: flush ok", 328, 32'd4294958765);
  chk_mem(4, "jalr base d3: link", 336, 32'd672);
  chk_mem(4, "jalr base d3: flush ok", 344, 32'd4294958765);
  $display(""); $display("========== SUMMARY ==========");
  $display("I-type ALU, rs1 from ALU result (d1)    : %0d passed, %0d failed", pass_c[0], fail_c[0]);
  $display("I-type ALU, rs1 from ALU result (d2)    : %0d passed, %0d failed", pass_c[1], fail_c[1]);
  $display("I-type ALU, rs1 at d3 (WB / fC path)    : %0d passed, %0d failed", pass_c[2], fail_c[2]);
  $display("I-type with LUI producer (d1, d2, d3)   : %0d passed, %0d failed", pass_c[3], fail_c[3]);
  $display("Load / JALR base from ALU result        : %0d passed, %0d failed", pass_c[4], fail_c[4]);
  if (fail_c[0]+fail_c[1]+fail_c[3]+fail_c[4]==0) $display("I-TYPE FORWARDING (ALU/LUI/base, d1-d2): PASS"); else $display("I-TYPE FORWARDING (ALU/LUI/base, d1-d2): FAIL");
  if (fail_c[2]==0) $display("d3 / WRITE-THROUGH: PASS"); else $display("d3 / WRITE-THROUGH: FAIL");
  $finish;
end
endmodule
