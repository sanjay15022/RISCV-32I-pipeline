`timescale 1ns/1ps
// CRC-32 (IEEE 802.3, reflected, poly 0xEDB88320) testbench for main_pipe.
// Memory map used by the program:
//   dmemory[0..3]   message length in bytes (word)      <- written by this testbench
//   dmemory[4..7]   CRC-32 result (word)                -> written by the CPU
//   dmemory[8..11]  done flag (1 when result is stored) -> written by the CPU
//   dmemory[16..]   message bytes                       <- written by this testbench
// Run options:  +msg=<text>   (default 123456789)    +empty (zero-length message)
module tst_crc32;

reg clk;
integer i, cycles, errors, len, started;
reg [8*60-1:0] s;
reg [7:0] msg [0:59];
reg [7:0] ch;
reg [31:0] expected, result, c;
integer j;

main_pipe uut (.clk(clk));

always #5 clk = ~clk;

// bit-by-bit reference model
function [31:0] crc32_ref;
    input integer n;
    integer a, b;
    reg [31:0] crc;
    begin
        crc = 32'hFFFFFFFF;
        for (a = 0; a < n; a = a + 1) begin
            crc = crc ^ {24'd0, msg[a]};
            for (b = 0; b < 8; b = b + 1)
                crc = crc[0] ? ((crc >> 1) ^ 32'hEDB88320) : (crc >> 1);
        end
        crc32_ref = ~crc;
    end
endfunction

initial begin
    clk = 0; errors = 0; cycles = 0; len = 0; started = 0;
    s = "123456789";
    if ($test$plusargs("empty")) s = 0;
    else i = $value$plusargs("msg=%s", s);

    // unpack the string (leading zero bytes are padding)
    for (i = 59; i >= 0; i = i - 1) begin
        ch = s[8*i +: 8];
        if (ch != 0) started = 1;
        if (started) begin msg[len] = ch; len = len + 1; end
    end

    expected = crc32_ref(len);

    // sanity check of the reference itself against the well-known check value
    if (len == 9 && msg[0] == "1" && msg[8] == "9" && expected !== 32'hCBF43926) begin
        $display("TESTBENCH ERROR: reference model disagrees with CRC32(\"123456789\") = CBF43926");
        $finish;
    end

    #1; // after data_mem's initial block has cleared the array
    uut.dmem1.dmemory[0] = len[7:0];
    uut.dmem1.dmemory[1] = len[15:8];
    uut.dmem1.dmemory[2] = 8'd0;
    uut.dmem1.dmemory[3] = 8'd0;
    for (i = 0; i < len; i = i + 1) uut.dmem1.dmemory[16 + i] = msg[i];

    $display("========== CRC-32 ON PIPELINED RISC-V ==========");
    $display("Message length : %0d bytes", len);

    // run until the CPU sets the done flag (timeout protects against a hang)
    while (uut.dmem1.dmemory[8] === 8'd0 && cycles < 40000) begin
        @(posedge clk);
        cycles = cycles + 1;
    end
    repeat (3) @(posedge clk);
    #1;

    result = {uut.dmem1.dmemory[7], uut.dmem1.dmemory[6],
              uut.dmem1.dmemory[5], uut.dmem1.dmemory[4]};

    $display("Cycles         : %0d", cycles);
    $display("CPU result     : %08h", result);
    $display("Expected       : %08h", expected);

    if (uut.dmem1.dmemory[8] === 8'd0) begin
        $display("TIMEOUT: done flag never set");
        errors = errors + 1;
    end
    if (result !== expected) errors = errors + 1;

    if (errors == 0) $display("CRC32: PASS");
    else             $display("CRC32: FAIL");
    $finish;
end

endmodule
