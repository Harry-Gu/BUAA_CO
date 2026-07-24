`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:12:55 11/12/2025 
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
`include "consts.v"
module ALU(
    input wire [31:0] ALUSrcA,
    input wire [31:0] ALUSrcB,
    input wire [4:0] ALUop,
    output reg [31:0] ALUout, 
	 output reg overflow
    );
	 
	 always@(*) begin
		//init
		overflow = 0;
		
		case(ALUop)
			`ALU_add:
				begin
					ALUout = ALUSrcA + ALUSrcB;
					if(ALUSrcA[31] == ALUSrcB[31] && ALUout[31] != ALUSrcA[31]) begin
						overflow = 1;
					end
				end
			`ALU_sub:
				begin
					ALUout = ALUSrcA - ALUSrcB;
					if(ALUSrcA[31] != ALUSrcB[31] && ALUout[31] != ALUSrcA[31]) begin
						overflow = 1;
					end
				end
			`ALU_and:
				ALUout = ALUSrcA & ALUSrcB;
			`ALU_or:
				ALUout = ALUSrcA | ALUSrcB;
			`ALU_isEqual:
				ALUout = (ALUSrcA == ALUSrcB ? 32'h00000001 : 32'h00000000);
			`ALU_isLess:
				ALUout = ($signed(ALUSrcA) < $signed(ALUSrcB) ? 32'h00000001 : 32'h00000000);
			`ALU_isLess_unsigned:
				ALUout = (ALUSrcA < ALUSrcB ? 32'h00000001 : 32'h00000000);
			default:
				ALUout = 32'h00000000;
		endcase
	 end


endmodule
