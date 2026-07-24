`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:20:06 11/05/2025 
// Design Name: 
// Module Name:    GRF 
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
module GRF(
    input [4:0] A1,
    input [4:0] A2,
    input RegWrite,
    input [31:0] WriteData,
    input [4:0] WriteAddr,
    input clk,
    input reset,
    input [31:0] CurPC,
	 output [31:0] RD1,
    output [31:0] RD2
    );
	
	reg[31:0] registers[31:0];
	
	//read
	assign RD1 = (A1 == 5'b00000 ? 32'h00000000 : registers[A1]);
	assign RD2 = (A2 == 5'b00000 ? 32'h00000000 : registers[A2]);
	
	//write and reset
	integer i;
	always@(posedge clk) begin
		if(reset) begin
			for(i = 0; i < 32; i = i + 1) begin : initialization
				registers[i] <= 32'h00000000;
			end
		end else begin
			if(RegWrite) begin
				registers[WriteAddr] <= WriteData;
				$display("@%h: $%d <= %h", CurPC, WriteAddr, WriteData);
			end
		end
	
	end

endmodule
