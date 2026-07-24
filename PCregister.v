`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:14:48 11/12/2025 
// Design Name: 
// Module Name:    PCregister 
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
module PCregister(
    input wire clk,
    input wire reset,
	 input wire en,
    input wire [31:0] NextPC,
	 output reg [31:0] PC
    );
	
	always@(posedge clk) begin
		if(reset) begin
			PC <= 32'h00003000;
		end else if(en) begin
			PC <= NextPC;
		end
	end

endmodule

