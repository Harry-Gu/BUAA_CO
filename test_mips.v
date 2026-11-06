`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:28:29 11/15/2025
// Design Name:   mips
// Module Name:   D:/my_program/verilog_ISE/P5/test_mips.v
// Project Name:  P5
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mips
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_mips;

	// Inputs
	reg clk;
	reg reset;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk(clk), 
		.reset(reset)
	);

	initial begin
		$dumpfile("wave.vcd");
		$dumpvars(0, test_mips);
		// Initialize Inputs
		clk = 0;
		reset = 1;
		#10 reset = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#10000;
		$finish;

	end
	
	always #5 clk = ~clk;
      
endmodule

