`timescale 1ns / 1ps
`define ALUadd 5'b00000
`define ALUsub 5'b00001
`define ALUor 5'b00010
`define ALUisEqual 5'b00100
module ALU(
    input [31:0] ALUSrcA,
    input [31:0] ALUSrcB,
    input [4:0] ALUop,
    output reg [31:0] ALUout,
	output reg Overflow
    );
	 
	 always@(*) begin
		Overflow = 0;
		case(ALUop)
			`ALUadd:
				begin
					ALUout = ALUSrcA + ALUSrcB;
					Overflow = (ALUSrcA[31] == ALUSrcB[31]) && (ALUSrcA[31] != ALUout[31]);
				end
			`ALUsub:
				begin
					ALUout = ALUSrcA - ALUSrcB;
					Overflow = (ALUSrcA[31] != ALUSrcB[31]) && (ALUSrcA[31] != ALUout[31]);

				end
			`ALUor:
				ALUout = ALUSrcA | ALUSrcB;
			`ALUisEqual:
				ALUout = (ALUSrcA == ALUSrcB ? 32'h00000001 : 32'h00000000);
			default:
				ALUout = 32'h00000000;
		endcase
	 end


endmodule
