`timescale 1ns/1ps

module tst_forward_all;
    reg clk;
    integer pass_count, fail_count;
    integer fA1_count, fA2_count, fB1_count, fB2_count, fC1_count, fC2_count;

    main_pipe uut(.clk(clk));
    always #5 clk = ~clk;

    task check_reg;
        input [4:0] regno;
        input [31:0] expected;
        input [8*32-1:0] label;
        begin
            if (uut.register1.register[regno] === expected) begin
                $display("PASS %-32s x%0d = %h", label, regno,
                         uut.register1.register[regno]);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL %-32s x%0d expected %h got %h", label,
                         regno, expected, uut.register1.register[regno]);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Count which forwarding path is actually selected.
    always @(posedge clk) begin
        #1;
        if (uut.f1_enb && uut.fA1 && uut.reg_write_idexe)
            fA1_count = fA1_count + 1;
        if (uut.f2_enb && uut.fA2 && uut.reg_write_idexe)
            fA2_count = fA2_count + 1;

        if (uut.f1_enb && !uut.fA1 && uut.fB1 && uut.reg_write_exemem)
            fB1_count = fB1_count + 1;
        if (uut.f2_enb && !uut.fA2 && uut.fB2 && uut.reg_write_exemem)
            fB2_count = fB2_count + 1;

        if (uut.f1_enb && !uut.fA1 && !uut.fB1 &&
            uut.fC1 && uut.reg_write_memwb)
            fC1_count = fC1_count + 1;
        if (uut.f2_enb && !uut.fA2 && !uut.fB2 &&
            uut.fC2 && uut.reg_write_memwb)
            fC2_count = fC2_count + 1;
    end

    initial begin
        clk = 0;
        pass_count = 0;
        fail_count = 0;
        fA1_count = 0; fA2_count = 0;
        fB1_count = 0; fB2_count = 0;
        fC1_count = 0; fC2_count = 0;

        // Initial register values
        #1;
        uut.register1.register[1] = 32'd100;
        uut.register1.register[2] = 32'd200;
        uut.register1.register[3] = 32'd300;
        uut.register1.register[4] = 32'd400;

        // 29 instructions + pipeline drain
        repeat (40) @(posedge clk);
        #2;

        $display("\n========== FORWARDING TEST RESULTS ==========");
        check_reg(6,  32'd107, "A1: I-type rs1");
        check_reg(8,  32'd507, "A2: R-type rs2");
        check_reg(11, 32'd112, "B1: I-type rs1");
        check_reg(14, 32'd513, "B2: R-type rs2");
        check_reg(18, 32'd119, "C1: I-type rs1");
        check_reg(22, 32'd519, "C2: R-type rs2");
        check_reg(24, 32'd303, "Priority: A over B/C");
        check_reg(28, 32'd351, "Both: C1 and B2 together");
        check_reg(31, 32'd359, "Both: A1 and A2 together");

        $display("\nForwarding path selections:");
        $display("A1=%0d  A2=%0d  B1=%0d  B2=%0d  C1=%0d  C2=%0d",
                 fA1_count, fA2_count, fB1_count, fB2_count,
                 fC1_count, fC2_count);
        $display("TOTAL: %0d PASS, %0d FAIL", pass_count, fail_count);
        $finish;
    end
endmodule
