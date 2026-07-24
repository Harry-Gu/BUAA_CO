`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:12:14 12/05/2025 
// Design Name: 
// Module Name:    ErrorRegister 
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
module ErrorRegister(
    input wire clk,
    input wire reset,
	 input wire en, 
	 input wire IntReqIn, 
    input wire [4:0] ExcCodeIn,
	 input wire NewErrorOccur, 
    input wire [4:0] NewErrorCode, 
	 output reg IntReqOut, 
	 output reg [4:0] ExcCodeOut
    );
	
	
	always@(posedge clk) begin
		if(reset) begin
			ExcCodeOut <= 0;
			IntReqOut <= 0;
		end else if(en) begin
			if(!IntReqIn && NewErrorOccur) begin
				ExcCodeOut <= NewErrorCode;
				IntReqOut <= 1;
			end else begin
				ExcCodeOut <= ExcCodeIn;
				IntReqOut <= IntReqIn;
			end
		end
	end

endmodule
