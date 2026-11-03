`timescale 1ns/1ps

module tst_pipe;

reg clk;

integer errors;

main_pipe uut (
    .clk(clk)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    errors = 0;

    $display("==================================");
    $display("     R-TYPE FORWARDING TEST");
    $display("==================================");

    // Allow the pipeline to execute all instructions
    repeat(12) @(posedge clk);
    #1;

    $display("\nFINAL REGISTER VALUES");

    $display("x1 = %h", uut.register1.register[1]);
    $display("x2 = %h", uut.register1.register[2]);
    $display("x3 = %h", uut.register1.register[3]);
    $display("x4 = %h", uut.register1.register[4]);
    $display("x5 = %h", uut.register1.register[5]);
    $display("x6 = %h", uut.register1.register[6]);
    $display("x7 = %h", uut.register1.register[7]);

    $display("\nRESULT CHECK");

    if (uut.register1.register[1] !== 32'd10)
        begin $display("FAIL: x1"); errors = errors + 1; end
    else $display("PASS: x1");

    if (uut.register1.register[2] !== 32'd20)
        begin $display("FAIL: x2"); errors = errors + 1; end
    else $display("PASS: x2");

    if (uut.register1.register[3] !== 32'd30)
        begin $display("FAIL: x3"); errors = errors + 1; end
    else $display("PASS: x3");

    if (uut.register1.register[4] !== 32'd20)
        begin $display("FAIL: x4"); errors = errors + 1; end
    else $display("PASS: x4");

    if (uut.register1.register[5] !== 32'd20)
        begin $display("FAIL: x5"); errors = errors + 1; end
    else $display("PASS: x5");

    if (uut.register1.register[6] !== 32'd30)
        begin $display("FAIL: x6"); errors = errors + 1; end
    else $display("PASS: x6");

    if (uut.register1.register[7] !== 32'd10)
        begin $display("FAIL: x7"); errors = errors + 1; end
    else $display("PASS: x7");

    $display("\n==================================");

    if (errors == 0)
        $display("R-TYPE FORWARDING: PASS");
    else
        $display("R-TYPE FORWARDING: FAIL (%0d errors)", errors);

    $display("==================================");

    $finish;
end

endmodule