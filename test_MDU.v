`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:04:18 11/22/2025
// Design Name:   Mul_Div
// Module Name:   D:/my_program/verilog_ISE/P6/P6/test_MDU.v
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

module test_MDU;

	// Inputs
	reg clk;
	reg reset;
	reg [31:0] SrcA;
	reg [31:0] SrcB;
	reg [2:0] MDUop;
	reg Start;

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
		.MDUop(MDUop), 
		.Start(Start), 
		.Busy(Busy), 
		.Hi(Hi), 
		.Lo(Lo)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		SrcA = 12345679;
		SrcB = -9;
		MDUop = 3'b000;
		Start = 0;
		
		#12 reset = 0;
		Start = 1;
		
		#10 Start = 0;
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
	
	always #5 clk = ~clk;
      
endmodule

