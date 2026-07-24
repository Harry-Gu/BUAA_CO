`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:15:32 11/12/2025 
// Design Name: 
// Module Name:    shifter 
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
module shifter(
    input wire [31:0] ShifterIn,
    input wire [1:0] ShifterOp,
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
