`timescale 1ns / 1ps

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
		#1000;
		$finish;
	end

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;

		// Wait 100 ns for global reset to finish
		#10;
		reset = 0;
        
		// Add stimulus here

	end
	
	always #1 clk = ~clk;
      
endmodule

