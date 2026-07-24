`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:11:43 11/12/2025 
// Design Name: 
// Module Name:    InstrMem 
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
module InstrMem(
    input wire [31:0] IMAddr,
    output reg [31:0] CurInstr
    );
	
	reg [31:0] im_reg [0 : `IM_SIZE - 1];
	initial begin
		$readmemh("code.txt", im_reg);
	end
	
	wire isLegalAddr;
	assign isLegalAddr = (IMAddr >= 32'h00003000 && IMAddr < 32'h00003000 + (`IM_SIZE << 2));
	
	always@(*) begin
		if(isLegalAddr) begin
			CurInstr = im_reg[(IMAddr - 32'h00003000) >> 2];
		end else begin
			CurInstr = 32'h00000000;
		end
	end
endmodule
