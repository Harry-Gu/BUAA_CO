`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:21:06 11/15/2025 
// Design Name: 
// Module Name:    NPC 
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
`default_nettype none
module NPC(
    input wire [31:0] PC,
    input wire Branch,
    input wire [1:0] BranchType,
    input wire isEq,
    input wire [31:0] ShifterOut,
    input wire [25:0] Imm26,
    input wire [31:0] RD1,
    output reg [31:0] NextPC,
	 output wire [31:0] PCplus8
    );

	// behavior of beq, jal, jr, jalr in a delay slot is unpredictable.
	wire [31:0] PCplus4;
	assign PCplus4 = PC + 4;
	
	assign PCplus8 = PC + 8;	// PC @D + 4 == PC @I + 8
	
	always@(*) begin
		if(Branch) begin
			case(BranchType)
				`BT_beq:
					begin
						if(isEq) begin
							NextPC = PCplus4 + ShifterOut;
						end else begin
							NextPC = PCplus8;
						end
					end
				`BT_jal:
					begin
						NextPC = {PC[31:28], Imm26, 2'b00};	//might act differently if PC@D adn PC@I has different [31:28] bits.
					end
				`BT_jr:
					//including jalr and jr.
					begin
						NextPC = RD1;
					end
				default:
					begin
						//should never end up here...
						NextPC = `PC_INIT;
					end
			endcase
		end else begin
			NextPC = PCplus8;
		end
	end

endmodule
