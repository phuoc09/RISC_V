`timescale 1ns / 1ps
module RISC_V_TB;

    reg clk;
    reg rst_n;

    // Instantiate the RISCV_TOP module
    RISCV_TOP uut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Test sequence
    initial begin
        // Initialize reset
        rst_n = 0;
        #10;
        rst_n = 1;

        // Load values into registers
        uut.registers[1] = 32'h0000000A; // rs1 = 10
        uut.registers[2] = 32'h00000014; // rs2 = 20

        // Load ADD instruction into memory at address 0
        {uut.memory[0], uut.memory[1], uut.memory[2], uut.memory[3]} = 32'b00000000001000001000000110110011; //add rs3,rs1,rs2

        // Wait for some time for the instruction to be fetched and executed
     #9;

        // Check the result
        if (uut.registers[3] == 32'h0000001E) // 10 + 20 = 30 (0x1E)
            $display("Test Passed: ADD instruction");
        else
            $display("Test Failed: ADD instruction");
    end

endmodule
