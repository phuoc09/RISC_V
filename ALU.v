module ALU (
    input [31:0] rs1, // Đầu vào thanh ghi nguồn 1
    input [31:0] rs2, // Đầu vào thanh ghi nguồn 2
    input [2:0] alu_ctrl, // Tín hiệu điều khiển ALU
    output reg [31:0] rd // Đầu ra thanh ghi đích
);

    always @(*) begin
        case (alu_ctrl)
            3'b000: rd <= rs1 + rs2; // Lệnh add
            default: rd <= 32'b0; // Mặc định
        endcase
    end

endmodule
