`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:06:32 11/05/2025 
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
    input clk,
    input reset,
    input [31:0] NextPC,
	 output reg [31:0] PC
    );
	
	always@(posedge clk) begin
		if(reset) begin
			PC <= 32'h00003000;
		end else begin
			PC <= NextPC;
		end
	end

endmodule
