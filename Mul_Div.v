`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:04:25 11/20/2025 
// Design Name: 
// Module Name:    Mul_Div 
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
module Mul_Div(
	 input wire clk,
	 input wire reset,
    input wire [31:0] SrcA,
    input wire [31:0] SrcB,
	 input wire [2:0] MDUop,	//dont use this, use op_reg instead.
	 input wire HiLoWrite, 
	 input wire IsHi, 
    input wire Start,
    input wire MDUen, 
	 output wire Busy,
    output reg [31:0] Hi,
    output reg [31:0] Lo
    );
	
	reg [31:0] A, B;
	reg [2:0] op_reg;
	reg [31:0] cycleLeft;
	reg [31:0] result_Hi, result_Lo;
	
	wire [31:0] delay_cycle;
	
	assign Busy = (cycleLeft != 0);
	
	always@(posedge clk) begin
		if(reset) begin
			Hi <= 0;
			Lo <= 0;
			cycleLeft <= 0;
		end else if(MDUen) begin
			if(Start) begin
				A <= SrcA;
				B <= SrcB;
				op_reg <= MDUop;
				cycleLeft <= delay_cycle;
			end else begin
				if(HiLoWrite) begin
					cycleLeft <= 0;
					if(IsHi) begin
						Hi <= SrcA;
					end else begin
						Lo <= SrcA;
					end
				end else begin
					if(cycleLeft == 1) begin
						Hi <= result_Hi;
						Lo <= result_Lo;
					end
					cycleLeft <= (cycleLeft <= 0 ? 0 : cycleLeft - 1);
				end
			end
		end
	end
	
	always@(*) begin
		case(op_reg)
			`MDU_mul:
				begin : mul_calc
					reg [63:0] mul_result;
					mul_result = $signed(A) * $signed(B);
					result_Hi = mul_result[63:32];
					result_Lo = mul_result[31:0];
				end
			`MDU_mulu:
				begin : mulu_calc
					reg [63:0] mulu_result;
					mulu_result = A * B;
					result_Hi = mulu_result[63:32];
					result_Lo = mulu_result[31:0];
				end
			`MDU_div:
				begin
					result_Hi = $signed(A) % $signed(B);
					result_Lo = $signed(A) / $signed(B);		//got some problem when calc (INT_MIN / -1)
				end
			`MDU_divu:
				begin
					result_Hi = A % B;
					result_Lo = A / B;
				end
			//if you need to add new op, remember to change delay_cycle comb also!!
			default:
				begin
					result_Hi = `X_INIT_32;
					result_Lo = `X_INIT_32;
				end
		endcase
	end
	
	//change this as well !!!!
	assign delay_cycle = (MDUop == `MDU_mul) 		? 5 	:
								(MDUop == `MDU_mulu) 	? 5 	:
								(MDUop == `MDU_div) 		? 10 	:
								(MDUop == `MDU_divu) 	? 10 	:
														`X_INIT_32	;

endmodule
