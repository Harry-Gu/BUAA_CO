`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:13:29 11/12/2025 
// Design Name: 
// Module Name:    DataMem 
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
module DataMem(
    input wire [31:0] DataAddr,
    input wire MemWrite,
    input wire [31:0] MemDataIn,
	 input wire [31:0] PC,
	 input wire clk,
	 input wire reset,
    output reg [31:0] MemDataOut
    );
	
	reg [31:0] dm_reg[0:`DM_SIZE - 1];
	
	wire isLegalAddr;
	assign isLegalAddr = (DataAddr < (`DM_SIZE << 2));
	
	always@(*) begin
		if(isLegalAddr) begin
			MemDataOut = dm_reg[(DataAddr >> 2)];
		end else begin
			MemDataOut = 32'h00000000;
		end
	end
	
	integer i;
	always@(posedge clk) begin
		if(reset) begin
			for(i = 0; i < `DM_SIZE; i = i + 1) begin : initialization
				dm_reg[i] <= 32'h00000000;
			end
		end else if(MemWrite) begin
			if(isLegalAddr) begin
				dm_reg[DataAddr[13:2]] <= MemDataIn;
				//$display("@%h: *%h <= %h", PC, DataAddr, MemDataIn);
				$display("%d@%h: *%h <= %h", $time, PC, DataAddr, MemDataIn);
			end else begin
				//error: illegal address
				$display("illegal addr in DM: %d@%h: *%h <= %h", $time, PC, DataAddr, MemDataIn);
			end
		end
	end

endmodule
