`timescale 1ns / 1ps
module shifter(
    input [31:0] ShifterIn,
    input [1:0] ShifterOp,
    output reg [31:0] ShifterOut
    );

	always@(*) begin
		case(ShifterOp)
			2'b00:
				ShifterOut = ShifterIn;
			2'b01:
				ShifterOut = ShifterIn << 2;
			2'b10:
				ShifterOut = ShifterIn << 16;
			default:
				ShifterOut = ShifterIn;
		endcase
	end
	
endmodule
