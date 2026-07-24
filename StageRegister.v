`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:51:56 11/13/2025 
// Design Name: 
// Module Name:    StageRegister 
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
`default_nettype none
module StageRegister(
    input wire clk,
    input wire reset,		//!! at E stage, the reset should be 1 only if reset of mips is 0 or (flush_E is 0 and Stall_E is 0).		//i think
    input wire en,
	 
    input wire [1:0] curStage,
	 
	 input wire [31:0] InstrIn,		// normally wont use it.
    
	 input wire [4:0] RegA1In,
    input wire [4:0] RegA2In,
	 input wire RegWriteIn,
	 input wire [4:0] RegDstIn,
	 input wire [1:0] RegDataSrcIn,	//else from MemDataOut
	 //input wire IsSignedIn,
	 //input wire [1:0] ShifterOpIn,
	 input wire MemWriteIn,
	 //input wire BranchIn,
	 //input wire [1:0] BranchTypeIn,
	 input wire IsALUSrcBRD2In,		//else: shifter_out
	 input wire [4:0] ALUopIn,
	 
	 input wire [31:0] ALUoutIn,
	 
	 input wire [1:0] TnewIn,
	 
	 input wire [31:0] PCIn,
	 
	 input wire isSPIn,
	 
    output reg [31:0] InstrOut,
	 
	 output reg [4:0] RegA1Out,
    output reg [4:0] RegA2Out,
    output reg RegWriteOut,
	 output reg [4:0] RegDstOut,
	 output reg [1:0] RegDataSrcOut,
	 //output reg IsSignedOut,
	 //output reg [1:0] ShifterOpOut,
	 output reg MemWriteOut,
	 //output reg BranchOut,
	 //output reg [1:0] BranchTypeOut,
	 output reg IsALUSrcBRD2Out,
	 output reg [4:0] ALUopOut,
	 
	 output reg [31:0] ALUoutOut,
	 
	 output reg [1:0] TnewOut,		//has been automaticlly minus 1.
	 
	 output reg [31:0] PCOut,
	 
	 output reg isSPOut
	 //remember to add new signals to initialization in if(reset)!
    );
	 
	 always@(posedge clk) begin
		if(reset) begin
			/*
			InstrOut <= 0;
			RegA1Out <= 0;
			RegA2Out <= 0;
			RegWriteOut <= 0;
			RegDstOut <= 0;
			RegDataSrcOut <= `REG_SRC_ALU;		//initial
			IsSignedOut <= 1'b0;
			ShifterOpOut <= 2'b00;
			MemWriteOut <= 0;
			BranchOut <= 0;
			BranchTypeOut <= `BT_jal;
			IsALUSrcBRD2Out <= 1'b0; //from shifter.
			ALUopOut <= `ALUadd;
			TnewOut <= 0;
			PCOut <= `PC_INIT;
			isSPOut <= 0;
			*/
			InstrOut <= 0;
			RegA1Out <= 5'bxxxxx;
			RegA2Out <= 5'bxxxxx;
			RegWriteOut <= 0;
			RegDstOut <= 5'bxxxxx;
			RegDataSrcOut <= 2'bxx;
			//IsSignedOut <= 1'bx;
			//ShifterOpOut <= 2'bxx;
			MemWriteOut <= 0;
			//BranchOut <= 0;
			//BranchTypeOut <= 2'bxx;
			IsALUSrcBRD2Out <= 1'bx;
			ALUopOut <= 5'bxxxxx;
			TnewOut <= 2'bxx;
			PCOut <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			isSPOut <= 0;
		end else if(en) begin
			InstrOut <= InstrIn;
			
			RegA1Out <= RegA1In;
			RegA2Out <= RegA2In;
			RegWriteOut <= RegWriteIn;
			RegDstOut <= RegDstIn;
			RegDataSrcOut <= RegDataSrcIn;
			//IsSignedOut <= IsSignedIn;
			//ShifterOpOut <= ShifterOpIn;
			MemWriteOut <= MemWriteIn;
			//BranchOut <= BranchIn;
			//BranchTypeOut <= BranchTypeIn;
			IsALUSrcBRD2Out <= IsALUSrcBRD2In;
			ALUopOut <= ALUopIn;
			
			TnewOut <= (TnewIn == 0 ? 0 : TnewIn - 1);
			
			PCOut <= PCIn;
			
			isSPOut <= isSPIn;
		end
	 end

endmodule
