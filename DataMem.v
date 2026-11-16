`timescale 1ns / 1ps
//DM_SIZE is counted by word (4-byte).
`define DM_SIZE (3072)
module DataMem(
    input [31:0] DataAddr,
    input MemWrite,
    input [31:0] MemDataIn,
	input [31:0] PC,
	input clk,
	input reset,
	input Req,
    output reg [31:0] MemDataOut,
	output Misaligned 
    );
	
	reg [31:0] dm_reg[0:`DM_SIZE - 1];
	
	wire isLegalAddr;
	assign isLegalAddr = (DataAddr < (`DM_SIZE << 2)) && DataAddr[1:0] == 2'b00;
	
	assign Misaligned = !isLegalAddr;
	
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
		end else if(MemWrite && !Req) begin
			if(isLegalAddr) begin
				dm_reg[DataAddr[13:2]] <= MemDataIn;
				$display("@%h: *%h <= %h", PC, DataAddr, MemDataIn);
			end else begin
				//error: illegal address
				$display("illegal addr in DM: @%h: *%h <= %h", PC, DataAddr, MemDataIn);
			end
		end
	end

endmodule
