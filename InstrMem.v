`timescale 1ns / 1ps
`define IM_SIZE (4096)
module InstrMem(
    input [31:0] IMAddr,
    output reg [31:0] CurInstr,
	output Misaligned
    );
	
	reg [31:0] im_reg [0 : `IM_SIZE - 1];
	initial begin
		$readmemh("code.txt", im_reg);
	end
	
	wire isLegalAddr;
	assign isLegalAddr = (IMAddr >= 32'h00003000 && IMAddr < 32'h00003000 + (`IM_SIZE << 2)) && IMAddr[1:0] == 2'b00;
	
	assign Misaligned = !isLegalAddr;
	
	always@(*) begin
		if(isLegalAddr) begin
			CurInstr = im_reg[(IMAddr - 32'h00003000) >> 2];
		end else begin
			CurInstr = 32'h00000000;
		end
	end
endmodule
