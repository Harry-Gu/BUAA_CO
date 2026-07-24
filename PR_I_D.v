`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:18:20 11/15/2025 
// Design Name: 
// Module Name:    PR_I_D 
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
module PR_I_D(
    input wire clk,
    input wire reset,		//!! at E stage, the reset should be 1 only if reset of mips is 0 or (flush_E is 0 and Stall_E is 0).		//i think
    input wire en,
	 
	 input wire [31:0] InstrIn,		
	 input wire [31:0] PCIn,
	 
    output reg [31:0] InstrOut,
	 output reg [31:0] PCOut
	 
	 //remember to add new signals to initialization in if(reset)!
    );
	 
	 always@(posedge clk) begin
		if(reset) begin
			InstrOut <= 0;
			PCOut <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
		end else if(en) begin
			InstrOut <= InstrIn;
			PCOut <= PCIn;
		end
	 end

endmodule
