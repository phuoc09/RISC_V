module RISCV_TOP (
    input clk,	 // Tín hiệu đồng hồ
	 input rst_n
);
	 wire [31:0] inst; 
    // Định nghĩa các tín hiệu và địa chỉ thanh ghi
    wire [4:0] AddrA = inst[19:15];
    wire [4:0] AddrB = inst[24:20];
    wire [4:0] AddrD = inst[11:7];
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];

    wire [31:0] DataA;
    wire [31:0] DataB;
    reg [31:0] DataD;

    reg RegWEn;
    reg [31:0] registers [0:31]; // 32 thanh ghi
	 reg[31:0] PC;
    // Bộ nhớ RAM 4KB
    reg [7:0] memory[0:4095];
	 
	 //tang thanh ghi PC
	 always@(posedge clk or negedge rst_n ) begin
	 if (~rst_n) begin
	 PC<=0;
	 end else
	 PC<=PC+4;
	 end
	 //IMEM
	 assign inst={memory[PC],memory[PC+1],memory[PC+2],memory[PC+3]};
    // Tín hiệu điều khiển ALU
    reg [2:0] alu_ctrl;

    // Đọc dữ liệu từ các thanh ghi
    assign DataA = registers[AddrA];
    assign DataB = registers[AddrB];
	
    // ALU operation
    always @(DataA or DataB  ) begin
        case (opcode)
            7'b0110011: begin
				case ({funct7,funct3})
					10'b0000000000: DataD=DataA+DataB;
					10'b0100000000: DataD=DataA-DataB;
					10'b0000000001: DataD=DataA<<DataB;
					10'b0000000001: DataD=(DataA<DataB)?1:0;
					
					default DataD = 32'b0;
				endcase
				end
            default: DataD = 32'b0; // Mặc định
        endcase
    end

    // Ghi dữ liệu vào thanh ghi đích
    always @(posedge clk) begin
        if (RegWEn) begin
            registers[AddrD] <= DataD;
        end
    end

    // Đơn vị điều khiển đơn giản
    always @(clk) begin
        RegWEn = 1'b0; // Đặt giá trị mặc định cho RegWEn
        alu_ctrl = 3'bxxx; // Giá trị mặc định cho alu_ctrl
        case (opcode)
            7'b0110011: begin // Lệnh R-type
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000000) begin
                            alu_ctrl = 3'b000; // Lệnh add
                            RegWEn = 1'b1;
                        end
                    end
                endcase
            end
        endcase
    end

endmodule
