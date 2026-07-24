`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:45:55 11/15/2025 
// Design Name: 
// Module Name:    PR_D_E 
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
module PR_D_E(
    input wire clk,
    input wire reset,		//!! at E stage, the reset should be 1 only if reset of mips is 0 or (flush_E is 0 and Stall_E is 0).		//i think
    input wire en,
	 
	 input wire [31:0] InstrIn,		// normally wont use it.
    
	 input wire [4:0] RegA1In,
    input wire [4:0] RegA2In,
	 input wire RegWriteIn,
	 input wire [4:0] RegDstIn,
	 input wire [2:0] RegDataSrcIn,	//else from MemDataOut
	 input wire MemWriteIn,
	 input wire IsALUSrcBRD2In,		//else: shifter_out
	 input wire [4:0] ALUopIn,
	 input wire [1:0] TnewIn,
	 input wire [31:0] PCIn,
	 
	 input wire [31:0] RD1In,
	 input wire [31:0] RD2In,
	 
	 input wire [31:0] ShifterOutIn,
	 
	 input wire [31:0] PCplus8In,
	 
	 input wire IsHiIn,
	 input wire IsMDIn,
	 input wire [2:0] MDUopIn,
	 input wire [1:0] MemTypeIn,
	 input wire HiLoWriteIn, 
	 
	 input wire MightOverFlowIn, 	//only include calculate type instr, address overflow is not included
	 input wire IsLoadIn, 
	 input wire IsStoreIn,
	 
	 input wire IsInBDIn, 
	 input wire CP0WriteIn, 
	 input wire IsEretIn,
	 
	 input wire isSPIn,
	 
	 
    output reg [31:0] InstrOut,
	 
	 output reg [4:0] RegA1Out,
    output reg [4:0] RegA2Out,
    output reg RegWriteOut,
	 output reg [4:0] RegDstOut,
	 output reg [2:0] RegDataSrcOut,
	 output reg MemWriteOut,
	 output reg IsALUSrcBRD2Out,
	 output reg [4:0] ALUopOut,
	 output reg [1:0] TnewOut,		//has been automaticlly minus 1.
	 output reg [31:0] PCOut,
	 
	 output reg [31:0] RD1Out,
	 output reg [31:0] RD2Out,
	 
	 output reg [31:0] ShifterOutOut,
	 
	 output reg [31:0] PCplus8Out,
	 
	 output reg IsHiOut,
	 output reg IsMDOut,
	 output reg [2:0] MDUopOut,
	 output reg [1:0] MemTypeOut,
	 output reg HiLoWriteOut, 

	 output reg MightOverFlowOut, 	//only include calculate type instr, address overflow is not included
	 output reg IsLoadOut, 
	 output reg IsStoreOut,
	 
	 output reg IsInBDOut, 
	 output reg CP0WriteOut, 
	 output reg IsEretOut,
	 
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
			RegDataSrcOut <= 3'bxxx;
			MemWriteOut <= 0;
			IsALUSrcBRD2Out <= 1'bx;
			ALUopOut <= 5'bxxxxx;
			TnewOut <= 2'bxx;
			//PCOut <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			RD1Out <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			RD2Out <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			ShifterOutOut <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			PCplus8Out <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			IsHiOut <= 1'bx;
			IsMDOut <= 1'b0;
			MDUopOut <= 3'bxxx;
			MemTypeOut <= 2'bxx;
			HiLoWriteOut <= 0;
			MightOverFlowOut <= 0;
			IsLoadOut <= 0;
			IsStoreOut <= 0;
			//IsInBDOut <= 0;
			CP0WriteOut <= 0;
			IsEretOut <= 0;
			isSPOut <= 0;
			
			PCOut <= PCIn;
			IsInBDOut <= IsInBDIn;
		end else if(en) begin
			InstrOut <= InstrIn;
			
			RegA1Out <= RegA1In;
			RegA2Out <= RegA2In;
			RegWriteOut <= RegWriteIn;
			RegDstOut <= RegDstIn;
			RegDataSrcOut <= RegDataSrcIn;
			MemWriteOut <= MemWriteIn;
			IsALUSrcBRD2Out <= IsALUSrcBRD2In;
			ALUopOut <= ALUopIn;
			
			TnewOut <= (TnewIn == 0 ? 0 : TnewIn - 1);
			PCOut <= PCIn;
			
			RD1Out <= RD1In;
			RD2Out <= RD2In;
			
			ShifterOutOut <= ShifterOutIn;
			PCplus8Out <= PCplus8In;
			
			IsHiOut <= IsHiIn;
			IsMDOut <= IsMDIn;
			MDUopOut <= MDUopIn;
			MemTypeOut <= MemTypeIn;
			HiLoWriteOut <= HiLoWriteIn;
			
			MightOverFlowOut <= MightOverFlowIn;
			IsLoadOut <= IsLoadIn;
			IsStoreOut <= IsStoreIn;
			
			IsInBDOut <= IsInBDIn;
			CP0WriteOut <= CP0WriteIn;
			IsEretOut <= IsEretIn;
			isSPOut <= isSPIn;
		end
	 end

endmodule
