`timescale 1ns/1ps
// Forwarding test, NO stall needed: dependent instructions run back to back (d1) or 1-2 apart (d2, d3).
// Loads are only used as producers at distance 2 or 3. hex: fwd_nostall_test.hex -> copy to program.hex
module tst_fwd_nostall;
reg clk; integer cycles; integer i;
integer pass_c [0:6]; integer fail_c [0:6];
main_pipe uut (.clk(clk));
always #5 clk = ~clk;
task chk_mem; input integer cat; input [8*40-1:0] label; input integer a; input [31:0] expv; reg [31:0] got;
begin got = {uut.dmem1.dmemory[a+3], uut.dmem1.dmemory[a+2], uut.dmem1.dmemory[a+1], uut.dmem1.dmemory[a]};
  if (got === expv) begin pass_c[cat] = pass_c[cat] + 1; $display("  PASS  %0s  (= %0d)", label, $signed(got)); end
  else begin fail_c[cat] = fail_c[cat] + 1; $display("  FAIL  %0s  (expected %0d, got %0d)", label, $signed(expv), $signed(got)); end
end endtask
initial begin
  clk = 0; cycles = 0;
  for (i = 0; i < 7; i = i + 1) begin pass_c[i] = 0; fail_c[i] = 0; end
  #1;
  uut.dmem1.dmemory[0] = 8'd100;
  uut.dmem1.dmemory[4] = 8'd200;
  uut.dmem1.dmemory[8] = 8'd16;
  uut.dmem1.dmemory[16] = 8'd43;
  uut.dmem1.dmemory[17] = 8'd2;
  while ({uut.dmem1.dmemory[1003],uut.dmem1.dmemory[1002],uut.dmem1.dmemory[1001],uut.dmem1.dmemory[1000]} !== 32'd1 && cycles < 5000) begin @(posedge clk); cycles = cycles + 1; end
  repeat (6) @(posedge clk); #1;
  $display("========== FORWARDING TEST (no stall) ==========");
  if (cycles >= 5000) $display("  TIMEOUT: done flag never set (CPU hung or went off the rails)");
  $display("Cycles to finish: %0d", cycles);
  $display(""); $display("-- R-type -> R-type / I-type --");
  chk_mem(0, "R->R add, rs1 forwarded d1", 256, 32'd36);
  chk_mem(0, "R->R add, rs1 forwarded d2", 260, 32'd36);
  chk_mem(0, "R->R add, rs1 forwarded d3", 264, 32'd36);
  chk_mem(0, "R->R sub, rs2 forwarded d1", 268, 32'd4294967282);
  chk_mem(0, "R->R sub, rs2 forwarded d2", 272, 32'd4294967282);
  chk_mem(0, "R->R sub, rs2 forwarded d3", 276, 32'd4294967282);
  chk_mem(0, "R->I xori, rs1 forwarded d1", 280, 32'd4294967202);
  chk_mem(0, "R->I xori, rs1 forwarded d2", 284, 32'd4294967202);
  chk_mem(0, "R->I xori, rs1 forwarded d3", 288, 32'd4294967202);
  $display(""); $display("-- Several older producers --");
  chk_mem(1, "same reg written 3x, newest wins", 292, 32'd6);
  chk_mem(1, "rs1 d3 + rs2 d2", 296, 32'd14);
  chk_mem(1, "rs1 d2 + rs2 d1", 300, 32'd2);
  chk_mem(1, "back-to-back chain (x1 -> 8)", 304, 32'd16);
  $display(""); $display("-- LUI / AUIPC as producers --");
  chk_mem(2, "LUI -> addi d1", 308, 32'd305418872);
  chk_mem(2, "LUI -> ori d2", 312, 32'd2882396193);
  chk_mem(2, "LUI -> srli d3", 316, 32'd89478400);
  chk_mem(2, "AUIPC -> addi d1", 320, 32'd4412);
  chk_mem(2, "AUIPC -> addi d2", 324, 32'd4420);
  chk_mem(2, "AUIPC -> addi d3", 328, 32'd4432);
  chk_mem(2, "LUI -> add rs2 d1", 332, 32'd28683);
  $display(""); $display("-- Branch compare operands --");
  chk_mem(3, "beq rs2 d1 (taken)", 336, 32'd0);
  chk_mem(3, "bne rs1 d2 (not taken)", 340, 32'd1);
  chk_mem(3, "blt rs1 d1 (taken)", 344, 32'd0);
  chk_mem(3, "bge rs2 d1 (not taken)", 348, 32'd1);
  chk_mem(3, "bltu rs1 d2 (taken)", 352, 32'd0);
  chk_mem(3, "bgeu rs2 d3 (taken)", 356, 32'd0);
  chk_mem(3, "beq rs1 d2 + rs2 d1 (taken)", 360, 32'd0);
  chk_mem(3, "blt rs2 = LUI d1 (taken)", 364, 32'd0);
  $display(""); $display("-- Store data / store address --");
  chk_mem(4, "sw data d1", 64, 32'd77);
  chk_mem(4, "sh data d2", 68, 32'd1234);
  chk_mem(4, "sb data d3", 72, 32'd90);
  chk_mem(4, "sw address d1", 80, 32'd11);
  chk_mem(4, "sw address d2", 84, 32'd11);
  chk_mem(4, "sw address d3 (+4)", 92, 32'd11);
  chk_mem(4, "data d1 + address d2", 96, 32'd33);
  chk_mem(4, "LUI -> store data d1", 100, 32'd305418240);
  chk_mem(4, "AUIPC -> store data d1", 104, 32'd4776);
  $display(""); $display("-- Load result (distance 2, 3 only: no stall) --");
  chk_mem(5, "load -> store data d2", 108, 32'd200);
  chk_mem(5, "load -> store data d3", 112, 32'd100);
  chk_mem(5, "load -> addi d2", 368, 32'd105);
  chk_mem(5, "load -> xori d3", 372, 32'd199);
  chk_mem(5, "load -> add (R-type) d2", 376, 32'd111);
  chk_mem(5, "load -> load base d2", 380, 32'd555);
  chk_mem(5, "load -> beq d2 (taken)", 384, 32'd0);
  $display(""); $display("-- JAL / JALR link register --");
  chk_mem(6, "jal: link used at target", 388, 32'd864);
  chk_mem(6, "jal: skipped instr not executed", 392, 32'd0);
  chk_mem(6, "jalr: base d1, link used at target", 396, 32'd848);
  chk_mem(6, "jalr: skipped instr not executed", 400, 32'd0);
  chk_mem(6, "call/return: return address used at target", 404, 32'd1);
  $display(""); $display("========== SUMMARY ==========");
  $display("R-type -> R-type / I-type                   : %0d passed, %0d failed", pass_c[0], fail_c[0]);
  $display("Several older producers                     : %0d passed, %0d failed", pass_c[1], fail_c[1]);
  $display("LUI / AUIPC as producers                    : %0d passed, %0d failed", pass_c[2], fail_c[2]);
  $display("Branch compare operands                     : %0d passed, %0d failed", pass_c[3], fail_c[3]);
  $display("Store data / store address                  : %0d passed, %0d failed", pass_c[4], fail_c[4]);
  $display("Load result (distance 2, 3 only: no stall)  : %0d passed, %0d failed", pass_c[5], fail_c[5]);
  $display("JAL / JALR link register                    : %0d passed, %0d failed", pass_c[6], fail_c[6]);
  if (fail_c[0]+fail_c[1]+fail_c[2]+fail_c[3]+fail_c[4]+fail_c[5]+fail_c[6]==0) $display("FORWARDING TEST (no stall): PASS"); else $display("FORWARDING TEST (no stall): FAIL");
  $finish;
end
endmodule
