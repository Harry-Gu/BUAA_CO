`timescale 1ns / 1ps

`define CP0_SR CP0_registers[12]
`define CP0_CAUSE CP0_registers[13]
`define CP0_EPC CP0_registers[14]

`define CP0_EXL `CP0_SR[1]
`define CP0_EXC_CODE `CP0_CAUSE[6:2]

module CP0(
	input wire clk, 
	input wire reset, 
	input wire IsExceptionOccur,
	input wire CP0Write,
	input wire [4:0] CP0Add,
	input wire [31:0] CP0In,
	output wire [31:0] CP0Out,
	input wire [31:0] VPC, 
	input wire [4:0] ExcCodeIn, 
	input wire EXLClr, 
	output wire [31:0] EPCOut, 
	output wire Req	
	);

	reg [31:0] CP0_registers [31:0];
	
	always@(posedge clk) begin
		if (reset) begin : initialization
			integer i;
			for (i = 0; i < 32; i = i + 1) begin
				CP0_registers[i] <= 0;
			end
		end else if (Req) begin
			`CP0_EXC_CODE <= ExcCodeIn;
			`CP0_EXL <= 1;
			`CP0_EPC <= VPC;
		end else if (CP0Write) begin
			CP0_registers[CP0Add] <= CP0In;
		end else if (EXLClr) begin
			`CP0_EXL <= 0;
		end
	end

	assign Req = IsExceptionOccur && !reset && !`CP0_EXL;
	
	assign CP0Out = CP0_registers[CP0Add];
	
	assign EPCOut = `CP0_EPC;

endmodule

