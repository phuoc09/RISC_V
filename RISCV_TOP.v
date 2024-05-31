module RISCV_TOP (
    input clk, // Tín hiệu đồng hồ
    input [31:0] instr // Lệnh đầu vào
);

    // Định nghĩa các tín hiệu và địa chỉ thanh ghi
    wire [4:0] rs1_addr = instr[19:15];
    wire [4:0] rs2_addr = instr[24:20];
    wire [4:0] rd_addr = instr[11:7];
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] rd_data;

    reg reg_write; // Thay đổi từ wire sang reg

    // Tín hiệu điều khiển ALU
    reg [2:0] alu_ctrl;

    // Instance của các module con
    RegisterFile rf (
        .clk(clk),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .reg_write(reg_write),
        .rs1(rs1_data),
        .rs2(rs2_data)
    );

    ALU alu (
        .rs1(rs1_data),
        .rs2(rs2_data),
        .alu_ctrl(alu_ctrl),
        .rd(rd_data)
    );

    // Đơn vị điều khiển đơn giản
    always @(*) begin
        reg_write = 1'b0; // Đặt giá trị mặc định cho reg_write
        case (opcode)
            7'b0110011: begin // Lệnh R-type
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000000) begin
                            alu_ctrl <= 3'b000; // Lệnh add
                            reg_write <= 1'b1;
                        end else begin
                            alu_ctrl <= 3'bxxx; // Các lệnh khác
                            reg_write <= 1'b0;
                        end
                    end
                    default: begin
                        alu_ctrl <= 3'bxxx;
                        reg_write <= 1'b0;
                    end
                endcase
            end
            default: begin
                alu_ctrl <= 3'bxxx;
                reg_write <= 1'b0;
            end
        endcase
    end

endmodule
