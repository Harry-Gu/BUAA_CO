`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:48:02 12/06/2025 
// Design Name: 
// Module Name:    Bridge 
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
module Bridge(
    input wire MemWrite,
    input wire [31:0] MemDataWrite,
    input wire [31:0] MemAddr, 
	 input wire [1:0] MemType, 
	 output reg DM_MemWrite, 
	 output reg Timer0_MemWrite, 
	 output reg Timer1_MemWrite, 
	 output reg NotAlignedException, 
	 output reg AddrOutOfRangeException,
	 output reg GetTimerValWithHOrBException, 
	 output reg WriteTimerCountException, 
	 input wire [31:0] DM_MemDataOut_M, 		//the DM means it is from Load-store decoder, which also include the signal from int request generater.
	 input wire [31:0] timer0DataOut, 
	 input wire [31:0] timer1DataOut, 
	 output reg [31:0] MemDataOut
    );

	always@(*) begin
		//init
		NotAlignedException = 0;
		AddrOutOfRangeException = 0;
		DM_MemWrite = 0;
		Timer0_MemWrite = 0;
		Timer1_MemWrite = 0;
		GetTimerValWithHOrBException = 0;
		WriteTimerCountException = 0;
		MemDataOut = `X_INIT_32;
		// align check
		if(MemType == `MEM_TYPE_H && MemAddr[0] == 1) begin : half_word
			NotAlignedException = 1;
		end else if(MemType == `MEM_TYPE_W && MemAddr[1:0] != 2'b00) begin : word
			NotAlignedException = 1;
		end else begin
			//is aligned:
			if(MemAddr <= 32'h2fff) begin : DM
				DM_MemWrite = MemWrite;
				MemDataOut = DM_MemDataOut_M;
			end else if ((MemAddr >= 32'h7f00 && MemAddr <= 32'h7f0b) || (MemAddr >= 32'h7f10 && MemAddr <= 32'h7f1b)) begin : timer
				// if there is a exception, than the influence of a store instr should not be writen.
				//check if access timer with lh/sh/lb/sb
				if((MemType == `MEM_TYPE_B || MemType == `MEM_TYPE_H)) begin
					GetTimerValWithHOrBException = 1;
				end else if(MemWrite && MemAddr[3:2] == 2) begin
					WriteTimerCountException = 1;
				end else if(MemAddr >= 32'h7f00 && MemAddr <= 32'h7f0b) begin : timer_0
					// figure out ehich timer is hit
					Timer0_MemWrite = MemWrite;
					MemDataOut = timer0DataOut;
				end else begin
					// figure out ehich timer is hit
					Timer1_MemWrite = MemWrite;
					MemDataOut = timer1DataOut;
				end
			end else if(MemAddr >= 32'h7f20 && MemAddr <= 32'h7f23) begin : int_generater
				DM_MemWrite = MemWrite;		// interrupt share the same port with DM.
				MemDataOut = 32'd0;
			end else begin
				//addr out of range
				AddrOutOfRangeException = 1;
			end
		end
	end
	
endmodule
