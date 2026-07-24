`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:10:47 11/05/2025 
// Design Name: 
// Module Name:    ALU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define ALUadd 5'b00000
`define ALUsub 5'b00001
`define ALUor 5'b00010
`define ALUisEqual 5'b00100
module ALU(
    input [31:0] ALUSrcA,
    input [31:0] ALUSrcB,
    input [4:0] ALUop,
    output reg [31:0] ALUout
    );
	 
	 always@(*) begin
		case(ALUop)
			`ALUadd:
				ALUout = ALUSrcA + ALUSrcB;
			`ALUsub:
				ALUout = ALUSrcA - ALUSrcB;
			`ALUor:
				ALUout = ALUSrcA | ALUSrcB;
			`ALUisEqual:
				ALUout = (ALUSrcA == ALUSrcB ? 32'h00000001 : 32'h00000000);
			default:
				ALUout = 32'h00000000;
		endcase
	 end


endmodule
