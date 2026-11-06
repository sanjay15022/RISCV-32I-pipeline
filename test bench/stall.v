`timescale 1ns/1ps
module tst_stall;
    reg clk;
    integer pass_count, fail_count;

    main_pipe uut(.clk(clk));
    always #5 clk = ~clk;

    task check_reg;
        input integer reg_num;
        input [31:0] expected;
        input [8*48-1:0] test_name;
        begin
            if (uut.register1.register[reg_num] === expected) begin
                $display("PASS %0s : x%0d = %h", test_name, reg_num,
                         uut.register1.register[reg_num]);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL %0s : x%0d expected %h got %h", test_name,
                         reg_num, expected, uut.register1.register[reg_num]);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task check_mem;
        input integer addr;
        input [31:0] expected;
        input [8*48-1:0] test_name;
        reg [31:0] actual;
        begin
            actual = {
                uut.dmem1.dmemory[addr+3],
                uut.dmem1.dmemory[addr+2],
                uut.dmem1.dmemory[addr+1],
                uut.dmem1.dmemory[addr]
            };
            if (actual === expected) begin
                $display("PASS %0s : MEM[%0d] = %h", test_name, addr, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL %0s : MEM[%0d] expected %h got %h",
                         test_name, addr, expected, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        pass_count = 0;
        fail_count = 0;

        // The final JAL x0,0 loops, so the program cannot run away.
        repeat (40) @(posedge clk);
        #1;

        $display("\\n===== RV32I LOAD-USE STALL TEST =====");
        check_reg(6,  32'd84, "LW -> ADD immediate dependency");
        check_reg(7,  32'd42, "LW -> SW store-data source");
        check_reg(8,  32'd64, "LW -> SW store-base source");
        check_reg(9,  32'd42, "LW -> BEQ comparison source");
        check_reg(10, 32'd0,  "Wrong-path instruction skipped");
        check_reg(11, 32'd7,  "Branch target executed");
        check_reg(12, 32'd1,  "Instruction after branch target");
        check_mem(68, 32'd84, "LW -> ADD result stored");
        check_mem(72, 32'd42, "LW -> SW store data");
        

        $display("\\nTOTAL: %0d PASS, %0d FAIL", pass_count, fail_count);
        $finish;
    end
endmodule
