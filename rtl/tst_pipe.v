`timescale 1ns/1ps
// Merge sort test for the single-cycle CPU (top module: main).
// No changes to your CPU files needed.
module tb_merge_sort_sc;
    reg clk;
    integer i, errors, cycles;
    reg signed [31:0] expected [0:7];
    reg signed [31:0] got;

    main uut (.clk(clk));

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("merge_sort_sc.vcd");
        $dumpvars(0, tb_merge_sort_sc);

        expected[0] = -9;  expected[1] = -5; expected[2] = 0;  expected[3] = 3;
        expected[4] = 4;   expected[5] = 7;  expected[6] = 12; expected[7] = 12;

        // instr_reg loads program.hex at time 0; replace it with the merge sort
        // program (one byte per line, little-endian) before the first clock edge.
        #1;
        for (i = 0; i < 1024; i = i + 1) uut.instr_reg1.instr_reg[i] = 8'h00;
        $readmemh("merge_sort_single_bytes.hex", uut.instr_reg1.instr_reg, 0, 219);

        $display("======== MERGE SORT (single-cycle) ========");

        // program writes 1 to byte address 124 when finished
        cycles = 0;
        while (uut.dmem1.dmemory[124] !== 8'd1 && cycles < 5000) begin
            @(posedge clk);
            cycles = cycles + 1;
        end
        #1;

        if (cycles >= 5000) begin
            $display("FAIL: timeout, program never finished (PC = %h)", uut.pc);
            $finish;
        end

        errors = 0;
        for (i = 0; i < 8; i = i + 1) begin
            got = {uut.dmem1.dmemory[4*i+3], uut.dmem1.dmemory[4*i+2],
                   uut.dmem1.dmemory[4*i+1], uut.dmem1.dmemory[4*i]};
            $display("A[%0d] = %0d", i, got);
            if (got !== expected[i]) begin
                $display("  MISMATCH: expected %0d", expected[i]);
                errors = errors + 1;
            end
        end

        if (errors == 0) $display("PASS: merge sort correct after %0d cycles", cycles);
        else             $display("FAIL: %0d mismatches", errors);
        $finish;
    end
endmodule
