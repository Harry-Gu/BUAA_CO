`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:09:34 11/20/2025
// Design Name:   Mul_Div
// Module Name:   D:/my_program/verilog_ISE/P6/P6/test_MD.v
// Project Name:  P6
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Mul_Div
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_MD;

	// Inputs
	reg clk;
	reg reset;
	reg [31:0] SrcA;
	reg [31:0] SrcB;
	reg IsMDSrcSigned;
	reg Start;
	reg IsMul;

	// Outputs
	wire Busy;
	wire [31:0] Hi;
	wire [31:0] Lo;

	// Instantiate the Unit Under Test (UUT)
	Mul_Div uut (
		.clk(clk), 
		.reset(reset), 
		.SrcA(SrcA), 
		.SrcB(SrcB), 
		.IsMDSrcSigned(IsMDSrcSigned), 
		.Start(Start), 
		.IsMul(IsMul), 
		.Busy(Busy), 
		.Hi(Hi), 
		.Lo(Lo)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		SrcA = 32'h8000_0000;
		SrcB = -1;
		IsMDSrcSigned = 1;
		Start = 1;
		IsMul = 0;
		
		#2 Start = 0;
		
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
   
	always #1 clk = ~clk;
endmodule

