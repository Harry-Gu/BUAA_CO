`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:23:54 11/13/2025 
// Design Name: 
// Module Name:    HazardHandler 
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
module HazardHandler(
	 input wire [4:0] RegA1_D,
	 input wire [1:0] Tuse_RD1_D,
    input wire [4:0] RegA2_D,
	 input wire [1:0] Tuse_RD2_D,		//seperate Tuse of rs and rt, for the special case like "store"
	 
	 input wire isD_SP,					//set it to 1 if there is a special case to decide whether to stall or not.
	 input wire isE_SP,
	 input wire isM_SP,
	 input wire isWB_SP,
	 
    input wire [4:0] RegA1_E,
    input wire [4:0] RegA2_E,	//if use shifter or others, this should be set to 5'b00000
	 
	 input wire [4:0] RegA1_M,
	 input wire [4:0] RegA2_M,
	 
	 //no need for Tuse at E stage, because if stall needed should have been handled at D stage.
	 
	 input wire [4:0] RegDst_E,
    input wire RegWrite_E,
	 input wire [1:0] Tnew_E,
	 
    input wire [4:0] RegDst_M,
    input wire RegWrite_M,
	 input wire [1:0] Tnew_M,
	 
	 input wire [4:0] RegDst_WB,
	 input wire RegWrite_WB,	
	 //dont need Tnew because it is cetainly 0.
	 
	 
    output reg Stall_D,
	 output reg Stall_E,	//with the mips standard instructions, it should always be 0.
	 output reg forward_E_to_Real_RD1_D,
	 output reg forward_E_to_Real_RD2_D,
	 output reg forward_M_to_Real_RD1_D,
	 output reg forward_M_to_Real_RD2_D,	 
	 output reg forward_M_to_Real_RD1_E,
	 output reg forward_M_to_Real_RD2_E,
	 //no need for WB_to_D, because the register file will do forwarding automaticly.
	 //forwarding from WB to ALU include forwarding from ALU,MEM or PC. so forwarding value should be after the mux of write back.
	 output reg forward_WB_to_Real_RD1_E,
	 output reg forward_WB_to_Real_RD2_E,
	 output reg forward_WB_to_Real_RD1_M,
	 output reg forward_WB_to_Real_RD2_M
	 //when you add a new output, remember to initialize them!!!
    );
	 
	 
	 /*
		example:
		
		lw $t0, 0($t1)
		sub $t0, $t2, $t3
		//if here has a code with the usage of $t0, the value shall be $t2 - $t3
		//so if RegDst of stage M and stage WB are both $t0, then we should set forward to be from stage M.
		
	 */
	
	always@(*) begin
		//initialization
		Stall_D = 0;
		Stall_E = 0;
		forward_E_to_Real_RD1_D = 0;
		forward_E_to_Real_RD2_D = 0;
		
		forward_M_to_Real_RD1_D = 0;
		forward_M_to_Real_RD2_D = 0;
		forward_M_to_Real_RD1_E = 0;
		forward_M_to_Real_RD2_E = 0;
		
		forward_WB_to_Real_RD1_E = 0;
		forward_WB_to_Real_RD2_E = 0;
		forward_WB_to_Real_RD1_M = 0;
		forward_WB_to_Real_RD2_M = 0;
		
		//E -> D
		// forwarding from E stage should have higher priority than forwarding from M stage!
		if(isE_SP) begin
			//E(SP) -> D
		end else begin
			if(isD_SP) begin
				//E -> D(SP)
			end else begin
				if(RegWrite_E && RegDst_E != 0) begin
					if(RegA1_D == RegDst_E) begin
						if(Tnew_E > Tuse_RD1_D) begin
							Stall_D = 1;
						end else begin
							if(Tuse_RD1_D == 0) begin
								forward_E_to_Real_RD1_D = 1;
							end
						end
					end
					
					if(RegA2_D == RegDst_E) begin
						if(Tnew_E > Tuse_RD2_D) begin
							Stall_D = 1;
						end else begin
							if(Tuse_RD2_D == 0) begin
								forward_E_to_Real_RD2_D = 1;
							end
						end
					end
				end
			end
		end
		
		
		//M -> ?
		if(isM_SP) begin
			//M(SP) -> ?
		end else begin
			if(RegWrite_M && RegDst_M != 0) begin
				//M -> D
				if(isD_SP) begin
					//M -> D(SP)
				end else begin
					if(RegA1_D == RegDst_M && !(RegWrite_E && RegDst_E == RegDst_M)) begin		//add && !(RegWrite_E && RegDst_E == RegDst_M)
						if(Tnew_M > Tuse_RD1_D) begin
							Stall_D = 1;
						end else begin
							if(Tuse_RD1_D == 0) begin
								forward_M_to_Real_RD1_D = 1;
							end
						end
					end
					
					if(RegA2_D == RegDst_M && !(RegWrite_E && RegDst_E == RegDst_M)) begin		//add && !(RegWrite_E && RegDst_E == RegDst_M)
						if(Tnew_M > Tuse_RD2_D) begin
							Stall_D = 1;
						end else begin
							if(Tuse_RD2_D == 0) begin
								forward_M_to_Real_RD2_D = 1;
							end
						end
					end
				end
				
				//M -> E
				if(isE_SP) begin
					//M -> E(SP)
				end else begin
					if(RegA1_E == RegDst_M) begin
						forward_M_to_Real_RD1_E = 1;
					end
					if(RegA2_E == RegDst_M) begin
						forward_M_to_Real_RD2_E = 1;
					end
				end
				
			end
		end
		
		
		//WB -> ?
		//well there aint no SP case in WB, i think.
		//but i still leave it here
		if(isWB_SP) begin
			//WB(SP) -> ? 	// honestly, i dont think this could be useful, so you may just copy those things below if isSP is used.
		end else begin
			if(isE_SP) begin
				//WB -> E(SP)
			end else begin
				if(RegWrite_WB && RegDst_WB != 0) begin
					if(RegA1_E == RegDst_WB && !(RegWrite_M && RegDst_M == RegDst_WB)) begin		//add && !(RegWrite_M && RegDst_M == RegDst_WB)
						forward_WB_to_Real_RD1_E = 1;
					end
					if(RegA2_E == RegDst_WB && !(RegWrite_M && RegDst_M == RegDst_WB)) begin		//add && !(RegWrite_M && RegDst_M == RegDst_WB)
						forward_WB_to_Real_RD2_E = 1;
					end
				end
			end
			
			//WB -> M
			if(isM_SP) begin
				//WB -> M(SP)
			end else begin
				if(RegWrite_WB && RegDst_WB != 0) begin
					if(RegA1_M == RegDst_WB) begin
						forward_WB_to_Real_RD1_M = 1;
					end
					if(RegA2_M == RegDst_WB) begin
						forward_WB_to_Real_RD2_M = 1;
					end
				end
			end
		end
	end


endmodule