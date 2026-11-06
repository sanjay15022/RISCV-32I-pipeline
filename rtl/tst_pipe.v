`timescale 1ns/1ps
// ============================================================================
//  tst_stall.v  -  load-use STALL / hazard-unit testbench for main_pipe
//  Program: program.hex (147 instrs, listing in program.lst)
//
//  What is checked
//   1. Per test case: the instruction in ID (pc_ifid) is stalled EXACTLY the
//      expected number of times (1 for a load-use, 0 for negative cases,
//      3 for the loop case).
//   2. No stray stalls anywhere else, stall never X, no stall deadlock.
//   3. Final architectural state (x1..x31 + data memory) matches a golden
//      RV32I ISS. x31 is a poison counter: any instruction executing in a
//      branch/jump shadow makes it non-zero.
//
//  Run:  iverilog -o sim <rtl files> tst_stall.v && vvp sim  [+trace]
// ============================================================================
module tst_stall;

reg clk = 0;
always #5 clk = ~clk;

main_pipe uut (.clk(clk));

localparam [31:0] END_PC = 32'h00000240;
localparam integer EXP_TOTAL = 26;

integer stall_at [0:255];        // stall cycles seen, indexed by pc_ifid[9:2]
integer stall_total = 0, stall_run = 0, cycle = 0;
integer pass_cnt = 0, fail_cnt = 0, tagged_actual = 0, i;
reg     trace;

initial begin
    for (i = 0; i < 256; i = i + 1) stall_at[i] = 0;
    trace = $test$plusargs("trace");
    $dumpfile("tst_stall.vcd");
    $dumpvars(0, tst_stall);
end

// ---- monitor: sample on negedge so all combinational logic has settled -----
always @(negedge clk) begin
    cycle = cycle + 1;
    if (uut.stall === 1'bx) begin
        $display("FAIL: stall is X at cycle %0d", cycle);
        fail_cnt = fail_cnt + 1;
    end
    if (uut.stall === 1'b1) begin
        stall_at[uut.pc_ifid[9:2]] = stall_at[uut.pc_ifid[9:2]] + 1;
        stall_total = stall_total + 1;
        stall_run   = stall_run + 1;
        if (stall_run > 2) begin
            $display("FAIL: stall stuck high (deadlock) at ID pc=%h", uut.pc_ifid);
            $finish;
        end
    end else
        stall_run = 0;
    if (trace)
        $display("cyc %4d | IF pc=%h | ID pc=%h instr=%h | EX instr=%h | stall=%b",
                 cycle, uut.pc, uut.pc_ifid, uut.instr_ifid, uut.instr_idexe, uut.stall);
end

// ---- check helpers ---------------------------------------------------------
task check_case(input [31:0] pc, input integer exp, input [8*48:1] name);
    begin
        tagged_actual = tagged_actual + stall_at[pc[9:2]];
        if (stall_at[pc[9:2]] == exp) begin
            $display("PASS  %-46s @%h  stalls=%0d", name, pc[15:0], exp);
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("FAIL  %-46s @%h  stalls exp=%0d got=%0d",
                     name, pc[15:0], exp, stall_at[pc[9:2]]);
            fail_cnt = fail_cnt + 1;
        end
    end
endtask

task check_reg(input [4:0] r, input [31:0] exp);
    begin
        if (uut.register1.register[r] === exp) pass_cnt = pass_cnt + 1;
        else begin
            $display("FAIL  x%0d exp=%h got=%h%s", r, exp, uut.register1.register[r],
                     (r == 31) ? "   <-- shadow instr executed (flush broken)" : "");
            fail_cnt = fail_cnt + 1;
        end
    end
endtask

task check_mem(input integer a, input [31:0] exp);
    reg [31:0] got;
    begin
        got = {uut.dmem1.dmemory[a+3], uut.dmem1.dmemory[a+2],
               uut.dmem1.dmemory[a+1], uut.dmem1.dmemory[a]};
        if (got === exp) pass_cnt = pass_cnt + 1;
        else begin
            $display("FAIL  MEM[%0d] exp=%h got=%h", a, exp, got);
            fail_cnt = fail_cnt + 1;
        end
    end
endtask

// ---- main sequence ---------------------------------------------------------
initial begin
    $display("\n================ RV32I PIPELINE STALL TEST ================");
    // run until "jal x0, END" reaches EX, with a timeout
    fork : run
        begin wait (uut.instr_idexe != 0 && uut.pc_idexe == END_PC); disable run; end
        begin repeat (3000) @(posedge clk);
              $display("FAIL: timeout - END never reached"); fail_cnt = fail_cnt + 1;
              disable run; end
    join
    repeat (10) @(posedge clk);       // drain pipeline
    #1;

    $display("\n---------------- per-case stall checks ----------------");
    check_case(32'h0050, 1, "S01 load->ALU rs1 (add)");
    check_case(32'h005c, 1, "S02 load->ALU rs2 only (sub)");
    check_case(32'h0068, 1, "S03 load->ALU rs1&rs2 same reg");
    check_case(32'h0074, 1, "S04 load->I-type (addi)");
    check_case(32'h0080, 1, "S05 load->ALU rd==rs1");
    check_case(32'h008c, 1, "S06 load->store data rs2");
    check_case(32'h0094, 1, "S07 load->store base rs1");
    check_case(32'h009c, 1, "S08 load->store base&data");
    check_case(32'h00a4, 1, "S09a load->load addr (chain 1)");
    check_case(32'h00a8, 1, "S09b load->load addr (chain 2)");
    check_case(32'h00ac, 1, "S09c load->ALU (chain 3)");
    check_case(32'h00bc, 1, "S10 stall + fwd MEM&WB together");
    check_case(32'h00c8, 1, "S11a back-to-back pair 1");
    check_case(32'h00d0, 1, "S11b back-to-back pair 2");
    check_case(32'h00e0, 1, "S12a lb->use (sign ext)");
    check_case(32'h00ec, 1, "S12b lbu->use (zero ext)");
    check_case(32'h00f8, 1, "S12c lh->use");
    check_case(32'h0104, 1, "S12d lhu->use");
    check_case(32'h0110, 1, "S13 load->branch rs1 (taken)");
    check_case(32'h0128, 1, "S14 load->branch rs2 (not taken)");
    check_case(32'h0138, 1, "S15 load->branch rs2 (taken, signed)");
    check_case(32'h0148, 1, "S16 load->jalr base");
    check_case(32'h0164, 3, "S17 load-use inside loop (x3)");
    check_case(32'h0184, 1, "S18 load-use right at branch target");
    check_case(32'h0190, 0, "N01 independent instr after load");
    check_case(32'h0194, 0, "N01b use at distance 2 (MEM fwd)");
    check_case(32'h01a8, 0, "N02 use at distance 3 (WB fwd)");
    check_case(32'h01b4, 0, "N03 load into x0 then read x0");
    check_case(32'h01c0, 0, "N04 LUI, imm bits==rd in rs1 field");
    check_case(32'h01cc, 0, "N05 I-type, imm bits==rd in rs2 field");
    check_case(32'h01d8, 0, "N06 load, imm bits==rd in rs2 field");
    check_case(32'h01e8, 0, "N07 JAL, imm bits==rd in rs2 field");
    check_case(32'h01f4, 0, "N08 AUIPC, imm bits==rd in rs1 field");
    check_case(32'h0200, 0, "N09 WAW only (load rd overwritten)");
    check_case(32'h020c, 0, "N10 ALU->ALU (EX fwd, no stall)");
    check_case(32'h0218, 0, "N11 store->load same addr");

    $display("\n---------------- global stall checks ----------------");
    if (stall_total - tagged_actual == 0) begin
        $display("PASS  no stray stalls outside the test cases"); pass_cnt = pass_cnt + 1;
    end else begin
        $display("FAIL  %0d stray stall cycle(s) at untested PCs:", stall_total - tagged_actual);
        fail_cnt = fail_cnt + 1;
    end
    if (stall_total == EXP_TOTAL) begin
        $display("PASS  total stall cycles = %0d", stall_total); pass_cnt = pass_cnt + 1;
    end else begin
        $display("FAIL  total stall cycles exp=%0d got=%0d", EXP_TOTAL, stall_total);
        fail_cnt = fail_cnt + 1;
    end

    $display("\n---------------- architectural state ----------------");
    check_reg( 1, 32'h00000100);
    check_reg( 2, 32'h0000002a);
    check_reg( 3, 32'h00000200);
    check_reg( 4, 32'h00000000);
    check_reg( 5, 32'h0000ff80);
    check_reg( 6, 32'h0000ff80);
    check_reg( 7, 32'h0000002a);
    check_reg( 8, 32'h0000002a);
    check_reg( 9, 32'h00050000);
    check_reg(10, 32'h0000002a);
    check_reg(11, 32'h0000002a);
    check_reg(12, 32'h0000002a);
    check_reg(13, 32'h0000014c);
    check_reg(14, 32'h00000204);
    check_reg(15, 32'h000801f4);
    check_reg(16, 32'h0000002a);
    check_reg(17, 32'h00000007);
    check_reg(18, 32'h00000005);
    check_reg(19, 32'h0000000a);
    check_reg(20, 32'h0000002a);
    check_reg(21, 32'h00000063);
    check_reg(22, 32'h0000004d);
    check_reg(23, 32'h00000054);
    check_reg(24, 32'h00000000);
    check_reg(25, 32'hffffff80);
    check_reg(26, 32'hffffff83);
    check_reg(27, 32'h00000000);
    check_reg(28, 32'h00000000);
    check_reg(29, 32'h00000000);
    check_reg(30, 32'h00000000);
    check_reg(31, 32'h00000000);
    check_mem(256, 32'h0000002a);
    check_mem(260, 32'hffffff80);
    check_mem(264, 32'h00000110);
    check_mem(268, 32'h00000204);
    check_mem(272, 32'h00000118);
    check_mem(276, 32'h00000154);
    check_mem(280, 32'h00000007);
    check_mem(284, 32'h00000000);
    check_mem(288, 32'h00000258);
    check_mem(292, 32'h00000000);
    check_mem(512, 32'h0000002a);
    check_mem(516, 32'hffffffd6);
    check_mem(520, 32'h0000002a);
    check_mem(524, 32'h00000032);
    check_mem(528, 32'h0000002b);
    check_mem(532, 32'h0000002a);
    check_mem(536, 32'h00000008);
    check_mem(540, 32'hffffffaa);
    check_mem(544, 32'h0000002c);
    check_mem(548, 32'hffffff83);
    check_mem(552, 32'hffffff80);
    check_mem(556, 32'h00000080);
    check_mem(560, 32'hffffff80);
    check_mem(564, 32'h0000ff80);
    check_mem(568, 32'h0000000d);
    check_mem(572, 32'h0000000e);
    check_mem(576, 32'h0000014c);
    check_mem(580, 32'h0000007e);
    check_mem(584, 32'h00000000);
    check_mem(588, 32'h0000002b);
    check_mem(592, 32'h00000054);
    check_mem(596, 32'h00000000);
    check_mem(600, 32'h00050000);
    check_mem(604, 32'h0000000b);
    check_mem(608, 32'h00000204);
    check_mem(612, 32'h000801f4);
    check_mem(616, 32'h00000007);
    check_mem(620, 32'h0000000a);
    check_mem(624, 32'h0000002a);
    check_mem(628, 32'h0000002a);
    check_mem(632, 32'h00000063);
    check_mem(636, 32'h0000004d);
    $display("(registers x1-x31 and data memory compared against golden ISS)");

    $display("\n===========================================================");
    $display("  TOTAL PASS : %0d", pass_cnt);
    $display("  TOTAL FAIL : %0d", fail_cnt);
    $display("  CYCLES     : %0d   STALL CYCLES : %0d", cycle, stall_total);
    $display("  RESULT     : %s", (fail_cnt == 0) ? "*** ALL TESTS PASSED ***" : "*** FAILURES ***");
    $display("===========================================================\n");
    $finish;
end

endmodule