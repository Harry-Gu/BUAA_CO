`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:54:27 11/15/2025 
// Design Name: 
// Module Name:    PR_M_WB 
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
`include "consts.v"
module PR_M_WB(
    input wire clk,
    input wire reset,		//!! at E stage, the reset should be 1 only if reset of mips is 0 or (flush_E is 0 and Stall_E is 0).		//i think
    input wire en,
	 
	 input wire [31:0] InstrIn,		// normally wont use it.
    
	 input wire RegWriteIn,
	 input wire [4:0] RegDstIn,
	 input wire [2:0] RegDataSrcIn,	//else from MemDataOut
	 
	 input wire [1:0] TnewIn,
	 
	 input wire [31:0] PCIn,
	 
	 input wire [31:0] RD1In,		// normally wont use it.
	 input wire [31:0] RD2In,		// normally wont use it.
	 
	 input wire [31:0] PCplus8In,
	 input wire [31:0] ALUoutIn,
	 input wire [31:0] MemDataOutIn,
	 input wire [31:0] HiOrLoIn,
	 
	 input wire isSPIn,
	 
    
	 output reg [31:0] InstrOut,
	 
    output reg RegWriteOut,
	 output reg [4:0] RegDstOut,
	 output reg [2:0] RegDataSrcOut,
	 
	 output reg [1:0] TnewOut,		//has been automaticlly minus 1.
	 
	 output reg [31:0] PCOut,
	 
	 output reg [31:0] RD1Out,			// normally wont use it.
	 output reg [31:0] RD2Out,			// normally wont use it.
	 
	 output reg [31:0] PCplus8Out,
	 output reg [31:0] ALUoutOut,
	 output reg [31:0] MemDataOutOut,
	 output reg [31:0] HiOrLoOut,
	 
	 output reg isSPOut
	 //remember to add new signals to initialization in if(reset)!
    );
	 
	 always@(posedge clk) begin
		if(reset) begin
			InstrOut <= 0;
			
			RegWriteOut <= 0;
			RegDstOut <= 5'bxxxxx;
			RegDataSrcOut <= 3'bxxx;
			
			TnewOut <= 2'bxx;

			PCOut <= `X_INIT_32;
			
			RD1Out <= `X_INIT_32;
			RD2Out <= `X_INIT_32;
			
			PCplus8Out <= `X_INIT_32;
			ALUoutOut <= `X_INIT_32;
			MemDataOutOut <= `X_INIT_32;
			HiOrLoOut <= `X_INIT_32;
			isSPOut <= 0;
		end else if(en) begin
			InstrOut <= InstrIn;
			
			RegWriteOut <= RegWriteIn;
			RegDstOut <= RegDstIn;
			RegDataSrcOut <= RegDataSrcIn;
			
			TnewOut <= (TnewIn == 0 ? 0 : TnewIn - 1);
			
			PCOut <= PCIn;
			
			RD1Out <= RD1In;
			RD2Out <= RD2In;
			
			PCplus8Out <= PCplus8In;
			ALUoutOut <= ALUoutIn;
			MemDataOutOut <= MemDataOutIn;
			HiOrLoOut <= HiOrLoIn;
			
			isSPOut <= isSPIn;
		end
	 end

endmodule