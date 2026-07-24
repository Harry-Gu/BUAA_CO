`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:37:52 11/14/2025 
// Design Name: 
// Module Name:    BitExtender 
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
module BitExtender(
    input wire [15:0] Imm16,
    input wire IsSigned,
    output wire [31:0] Imm32
    );
	
	assign Imm32 = IsSigned == 1 ?
						{{16{Imm16[15]}}, Imm16}:
						{16'h0000, Imm16};

endmodule