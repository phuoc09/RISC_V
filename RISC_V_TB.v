module RISCV_Simple_tb;

    // Inputs
    reg clk;
    reg [31:0] instr;

    // Wires
    wire [31:0] rs1_data, rs2_data, rd_data;
    wire reg_write;

    // Instantiate the DUT (Device Under Test)
    RISCV_TOP dut (
        .clk(clk),
        .instr(instr)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period of 10 time units
    end

    // Test procedure
    initial begin
        // Initialize registers in the Register File (for testing purpose)
        dut.rf.registers[1] = 10;
        dut.rf.registers[2] = 20;
		  dut.rf.registers[3] = 0;
        // Apply test instruction: add x3, x1, x2 (x3 = x1 + x2)
        instr = 32'b00000000001000001000000110110011;

        // Wait for a few clock cycles to ensure the instruction is processed
        #20;

        // Check the result
        if (dut.rf.registers[3] == 30) begin
            $display("Test Passed: x3 = %d", dut.rf.registers[3]);
        end else begin
            $display("Test Failed: x3 = %d", dut.rf.registers[3]);
        end

        // End simulation
        $stop;
    end

endmodule
