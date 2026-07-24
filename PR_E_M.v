`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:26:22 11/15/2025 
// Design Name: 
// Module Name:    PR_E_D 
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
module PR_E_M(
    input wire clk,
    input wire reset,		//!! at E stage, the reset should be 1 only if reset of mips is 0 or (flush_E is 0 and Stall_E is 0).		//i think
    input wire en,
	 
	 input wire [31:0] InstrIn,		// normally wont use it.
    
	 input wire [4:0] RegA1In,			// no use for standard mips datapath
    input wire [4:0] RegA2In,			//	reserve for "load-store" structure
	 input wire RegWriteIn,
	 input wire [4:0] RegDstIn,
	 input wire [1:0] RegDataSrcIn,	//else from MemDataOut
	 input wire MemWriteIn,
	 input wire [1:0] TnewIn,
	 input wire [31:0] PCIn,
	 
	 input wire [31:0] RD1In,		// normally wont use it.
	 input wire [31:0] RD2In,		//	reserve for "load-store" structure
	 
	 input wire [31:0] PCplus8In,
	 input wire [31:0] ALUoutIn,
	 
	 input wire isSPIn,
	 
    output reg [31:0] InstrOut,
	 
	 output reg [4:0] RegA1Out,		// normally wont use it.
    output reg [4:0] RegA2Out,		//	reserve for "load-store" structure
    output reg RegWriteOut,
	 output reg [4:0] RegDstOut,
	 output reg [1:0] RegDataSrcOut,
	 output reg MemWriteOut,
	 output reg [1:0] TnewOut,		//has been automaticlly minus 1.
	 output reg [31:0] PCOut,
	 
	 output reg [31:0] RD1Out,			// normally wont use it.
	 output reg [31:0] RD2Out,			//	reserve for "load-store" structure
	 
	 output reg [31:0] PCplus8Out,
	 output reg [31:0] ALUoutOut,
	 
	 output reg isSPOut
	 //remember to add new signals to initialization in if(reset)!
    );
	 
	 always@(posedge clk) begin
		if(reset) begin
			InstrOut <= 0;
			RegA1Out <= 5'bxxxxx;
			RegA2Out <= 5'bxxxxx;
			RegWriteOut <= 0;
			RegDstOut <= 5'bxxxxx;
			RegDataSrcOut <= 2'bxx;
			MemWriteOut <= 0;
			TnewOut <= 2'bxx;
			PCOut <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			RD1Out <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			RD2Out <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			PCplus8Out <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			ALUoutOut <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			isSPOut <= 0;
		end else if(en) begin
			InstrOut <= InstrIn;
			
			RegA1Out <= RegA1In;
			RegA2Out <= RegA2In;
			RegWriteOut <= RegWriteIn;
			RegDstOut <= RegDstIn;
			RegDataSrcOut <= RegDataSrcIn;
			MemWriteOut <= MemWriteIn;
			
			TnewOut <= (TnewIn == 0 ? 0 : TnewIn - 1);
			PCOut <= PCIn;
			
			RD1Out <= RD1In;
			RD2Out <= RD2In;
			PCplus8Out <= PCplus8In;
			ALUoutOut <= ALUoutIn;
			isSPOut <= isSPIn;
		end
	 end

endmodule
