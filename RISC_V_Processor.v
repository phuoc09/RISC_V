module RISC_V_Processor (
    input clk,
    input rst_n,
    output reg [31:0] addr,
    output reg [31:0] dataout,
    input [31:0] datain,
    output reg we
);

// Instruction Memory (for simplicity, using a small array here)
reg [31:0] IMEM [0:1023];

// Data Memory (for simplicity, using a small array here)
reg [31:0] DMEM [0:1023];

// Program Counter
reg [31:0] pc;

// Fetch Stage
reg [31:0] instruction;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc <= 32'b0;
    end else begin
        instruction <= IMEM[pc >> 2];
        pc <= pc + 4;
    end
end

// Decode Stage
wire [6:0] opcode = instruction[6:0];
wire [4:0] rd = instruction[11:7];
wire [2:0] func3 = instruction[14:12];
wire [4:0] rs1 = instruction[19:15];
wire [4:0] rs2 = instruction[24:20];
wire [6:0] func7 = instruction[31:25];
wire [31:0] imm = {{20{instruction[31]}}, instruction[31:20]}; // Sign-extended immediate

// Register File
reg [31:0] reg_file [0:31];
wire [31:0] opA = reg_file[rs1];
wire [31:0] opB = (ALUSrc) ? imm : reg_file[rs2];

// Control Unit
wire RegWrite, MemRead, MemWrite, ALUSrc, MemToReg;

control_unit cu (
    .opcode(opcode),
    .RegWrite(RegWrite),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .MemToReg(MemToReg)
);

// Execute Stage
reg [31:0] res;

always @(opcode, func7, func3, opA, opB) begin
    case (opcode)
        7'b0110011: begin // R-type
            case ({func7, func3})
                10'b0000000_000: res = opA + opB; // ADD
                10'b0100000_000: res = opA - opB; // SUB
                // Add more R-type instructions as needed
                default: res = 32'b0;
            endcase
        end
        7'b0010011: begin // I-type
            case (func3)
                3'b000: res = opA + opB; // ADDI
                // Add more I-type instructions as needed
                default: res = 32'b0;
            endcase
        end
        // Add more instruction types as needed
        default: res = 32'b0;
    endcase
end

// Memory Access Stage
always @(MemRead, MemWrite, res, reg_file, rs2) begin
    if (MemRead) begin
        addr = res;
        dataout = DMEM[addr >> 2];
        we = 1'b0; // Disable write operation
    end else if (MemWrite) begin
        addr = res;
        DMEM[addr >> 2] = reg_file[rs2];
        we = 1'b1; // Enable write operation
    end else begin
        addr = 32'b0;
        dataout = 32'b0;
        we = 1'b0; // Disable write operation by default
    end
end

// Write-Back Stage
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        integer i;
        for (i = 0; i < 32; i = i + 1) begin
            reg_file[i] <= 32'b0;
        end
    end else begin
        if (RegWrite) begin
            if (MemToReg) begin
                reg_file[rd] <= DMEM[addr >> 2];
            end else begin
                reg_file[rd] <= res;
            end
        end
    end
end

endmodule

// Control Unit Definition
module control_unit (
    input [6:0] opcode,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg ALUSrc,
    output reg MemToReg
);

always @(opcode) begin
    case (opcode)
        7'b0110011: begin // R-type
            RegWrite = 1;
            MemRead = 0;
            MemWrite = 0;
            ALUSrc = 0;
            MemToReg = 0;
        end
        7'b0010011: begin // I-type (e.g., ADDI)
            RegWrite = 1;
            MemRead = 0;
            MemWrite = 0;
            ALUSrc = 1;
            MemToReg = 0;
      end
	endcase
end
endmodule
