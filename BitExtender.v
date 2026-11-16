`timescale 1ns / 1ps
module BitExtender(
    input [15:0] Imm16,
    input IsSigned,
    output [31:0] Imm32
    );
	
	assign Imm32 = IsSigned == 1 ?
						{{16{Imm16[15]}}, Imm16}:
						{16'h0000, Imm16};

endmodule
