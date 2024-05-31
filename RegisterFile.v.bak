module RegisterFile (
    input clk, // Tín hiệu đồng hồ
    input [4:0] rs1_addr, // Địa chỉ thanh ghi nguồn 1
    input [4:0] rs2_addr, // Địa chỉ thanh ghi nguồn 2
    input [4:0] rd_addr, // Địa chỉ thanh ghi đích
    input [31:0] rd_data, // Dữ liệu ghi vào thanh ghi đích
    input reg_write, // Tín hiệu ghi thanh ghi
    output [31:0] rs1, // Dữ liệu thanh ghi nguồn 1
    output [31:0] rs2 // Dữ liệu thanh ghi nguồn 2
);

    reg [31:0] registers [31:0]; // 32 thanh ghi 32-bit

    // Đọc dữ liệu từ các thanh ghi
    assign rs1 = registers[rs1_addr];
    assign rs2 = registers[rs2_addr];

    // Ghi dữ liệu vào thanh ghi đích
    always @(posedge clk) begin
        if (reg_write) begin
            registers[rd_addr] <= rd_data;
        end
    end

endmodule
