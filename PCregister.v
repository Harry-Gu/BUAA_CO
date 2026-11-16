`timescale 1ns / 1ps
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
