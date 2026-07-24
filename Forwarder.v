`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:25:39 11/15/2025 
// Design Name: 
// Module Name:    Forwarder 
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
module Forwarder(
	 input wire [31:0] RD1_D,
	 input wire [31:0] RD2_D,
	 input wire [31:0] RD1_E,
	 input wire [31:0] RD2_E,
	 input wire [31:0] RD1_M,
	 input wire [31:0] RD2_M,
	 
	 input wire  forward_E_to_Real_RD1_D,
	 input wire  forward_E_to_Real_RD2_D,
	 input wire  forward_M_to_Real_RD1_D,
	 input wire  forward_M_to_Real_RD2_D,	 
	 input wire  forward_M_to_Real_RD1_E,
	 input wire  forward_M_to_Real_RD2_E,
	 //no need for WB_to_D, because the register file will do forwarding automaticly.
	 //forwarding from WB to ALU include forwarding from ALU,MEM or PC. so forwarding value should be after the mux of write back.
	 input wire  forward_WB_to_Real_RD1_E,
	 input wire  forward_WB_to_Real_RD2_E,
	 input wire  forward_WB_to_Real_RD1_M,
	 input wire  forward_WB_to_Real_RD2_M,
	 
	 input wire [31:0] PCplus8_E,
	 
	 input wire [31:0] PCplus8_M,
	 input wire [31:0] ALUout_M,
	 input wire [1:0] RegDataSrc_M,
	 
	 input wire [31:0] DataWriteBack_WB,
	 
	 output wire [31:0] Real_RD1_D,
	 output wire [31:0] Real_RD2_D,
	 output wire [31:0] Real_RD1_E,
	 output wire [31:0] Real_RD2_E,
	 output wire [31:0] Real_RD1_M,
	 output wire [31:0] Real_RD2_M
    );
	
	wire [31:0] forward_E, forward_M, forward_WB;
	assign forward_E = PCplus8_E;
	assign forward_M = (RegDataSrc_M == `REG_SRC_PC) ? PCplus8_M : ALUout_M;
	assign forward_WB = DataWriteBack_WB;
	
	
	assign Real_RD1_D = (forward_E_to_Real_RD1_D) ? 
									forward_E :
									(forward_M_to_Real_RD1_D) ?
										forward_M :
										RD1_D;
	assign Real_RD2_D = (forward_E_to_Real_RD2_D) ? 
									forward_E :
									(forward_M_to_Real_RD2_D) ?
										forward_M :
										RD2_D;
	
	assign Real_RD1_E = (forward_M_to_Real_RD1_E) ?
									forward_M :
									(forward_WB_to_Real_RD1_E) ?
										forward_WB :
										RD1_E;
	assign Real_RD2_E = (forward_M_to_Real_RD2_E) ?
									forward_M :
									(forward_WB_to_Real_RD2_E) ?
										forward_WB :
										RD2_E;
										
	assign Real_RD1_M = (forward_WB_to_Real_RD1_M) ? forward_WB : RD1_M;
	assign Real_RD2_M = (forward_WB_to_Real_RD2_M) ? forward_WB : RD2_M;

endmodule
