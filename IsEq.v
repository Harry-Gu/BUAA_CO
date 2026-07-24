`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:51:50 11/15/2025 
// Design Name: 
// Module Name:    IsEq 
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
module IsEq(
    input wire [31:0] IsEqSrcA,
    input wire [31:0] IsEqSrcB,
    output wire IsEq
    );
	
	assign IsEq = (IsEqSrcA == IsEqSrcB);

endmodule
