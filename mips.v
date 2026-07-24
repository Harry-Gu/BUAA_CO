`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:04:23 11/12/2025 
// Design Name: 
// Module Name:    mips 
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
//this setting will be used for all *.v on online judgement.
`default_nettype none
module mips(
    input wire clk,
    input wire reset,
    input wire [31:0] i_inst_rdata,
    input wire [31:0] m_data_rdata,
    output wire [31:0] i_inst_addr,
    output wire [31:0] m_data_addr,
    output wire [31:0] m_data_wdata,
    output wire [3 :0] m_data_byteen,
    output wire [31:0] m_inst_addr,
    output wire w_grf_we,
    output wire [4:0] w_grf_addr,
    output wire [31:0] w_grf_wdata,
    output wire [31:0] w_inst_addr
);
	
	wire Stall_D, Stall_E;
	
	wire flush_Delay;
	assign flush_Delay = 0;	//delay slot is enable(only for branch/jump, but not for load)
	//assign flush_Delay = Branch_D == 1 && BranchType_D == `BT_beq && IsEq_D;		//Branch delay disabled
	
	wire [31:0] Real_RD1_D;
	wire [31:0] Real_RD2_D;
	wire [31:0] Real_RD1_E;
	wire [31:0] Real_RD2_E;
	wire [31:0] Real_RD1_M;
	wire [31:0] Real_RD2_M;
	
	
	/*----------------------------- I stage --------------------------------*/

	wire [31:0] NPC_I;
	wire en_PC;
	//PC register
	wire [31:0] PC_I;
	PCregister PCregister (
    .clk(clk), 
    .reset(reset), 
	 .en(en_PC),
    .NextPC(NPC_I), 
    .PC(PC_I)
    );
	//( if use NPC_D as NPC_I, the first instr will be exectued unexpectedly.)
	assign NPC_I = (Branch_D ? NPC_D : PC_I + 4);	//to ensure the first instruction can be execute as normal. 
	assign en_PC = (!Stall_E) && (!Stall_D);
	
	//IM
	wire [31:0] Instr_I;
	assign i_inst_addr = PC_I;
	assign Instr_I = i_inst_rdata;
	
	/*
	//IM_P5
	InstrMem im (
    .IMAddr(PC_I), 
    .CurInstr(Instr_I)
    );
	*/
	
	wire en_I;
	wire reset_I;
	//pipline register I/D
	wire [31:0] Instr_D;
	wire [31:0] PC_D;
	PR_I_D PipelineRegister_I_D (
    .clk(clk), 
    .reset(reset_I), 
    .en(en_I), 
    .InstrIn(Instr_I), 
    .PCIn(PC_I), 
    .InstrOut(Instr_D), 
    .PCOut(PC_D)
    );
	assign en_I = (!Stall_E) && (!Stall_D);
	assign reset_I = reset || (flush_Delay && en_I);

	/*----------------------------- D stage --------------------------------*/
	
	//controller
	wire [4:0] RegA1_D, RegA2_D, RegDst_D, ALUop_D;
	wire RegWrite_D, IsSigned_D, MemWrite_D, Branch_D, IsALUSrcBRD2_D, isSP_D;
	wire [1:0] ShifterOp_D;
	wire [2:0] RegDataSrc_D, BranchType_D;
	wire [1:0] Tuse_rs_D, Tuse_rt_D, Tnew_D;
	wire IsHi_D, IsMD_D, HiLoWrite_D;
	wire [2:0] MDUop_D;
	wire [1:0] MemType_D;
 	ctrl controller (
    .Instr(Instr_D), 
    .RegA1(RegA1_D), 
    .RegA2(RegA2_D), 
    .RegWrite(RegWrite_D), 
    .RegDst(RegDst_D), 
    .RegDataSrc(RegDataSrc_D), 
    .IsSigned(IsSigned_D), 
    .ShifterOp(ShifterOp_D), 
    .MemWrite(MemWrite_D), 
    .Branch(Branch_D), 
    .BranchType(BranchType_D), 
    .IsALUSrcBRD2(IsALUSrcBRD2_D), 
    .ALUop(ALUop_D), 
    .Tuse_rs(Tuse_rs_D), 
    .Tuse_rt(Tuse_rt_D), 
    .Tnew(Tnew_D), 
	 .IsHi(IsHi_D), 
    .IsMD(IsMD_D), 
    .MDUop(MDUop_D), 
    .MemType(MemType_D), 
    .HiLoWrite(HiLoWrite_D), 
    .isSP(isSP_D)
    );
	
	wire [31:0] DataWriteBack_WB, PC_WB;	//the assign of it is in WB stage.
	wire RegWrite_WB;
	wire [4:0] RegDst_WB;
	//GRF
	wire [31:0] RD1_D;
	wire [31:0] RD2_D;
	GRF registers (
    .A1(RegA1_D), 
    .A2(RegA2_D), 
    .RegWrite(RegWrite_WB), 
    .WriteData(DataWriteBack_WB), 
    .WriteAddr(RegDst_WB), 
    .clk(clk), 
    .reset(reset), 
    .CurPC(PC_WB), 
    .RD1(RD1_D), 
    .RD2(RD2_D),
	 .w_grf_we(w_grf_we), 
    .w_grf_addr(w_grf_addr), 
    .w_grf_wdata(w_grf_wdata), 
    .w_inst_addr(w_inst_addr)
    );
	
	wire [31:0] IsEqSrcA_D, IsEqSrcB_D;
	// IsEq (for branch)
	wire IsEq_D;
	IsEq IsEq (
    .IsEqSrcA(IsEqSrcA_D), 
    .IsEqSrcB(IsEqSrcB_D), 
    .IsEq(IsEq_D)
    );
	//forwarding from E should have higher priority than from M stage.
	assign IsEqSrcA_D = Real_RD1_D;
	assign IsEqSrcB_D = Real_RD2_D;
	
	wire [15:0] Imm16_D;
	//EXT
	wire [31:0] Imm32_D;
	BitExtender ext (
    .Imm16(Imm16_D), 
    .IsSigned(IsSigned_D), 
    .Imm32(Imm32_D)
    );
	assign Imm16_D = Instr_D[15:0];
	
	wire [31:0] ShifterIn_D;
	//shifter
	wire [31:0] ShifterOut_D;
	shifter shifter (
    .ShifterIn(ShifterIn_D), 
    .ShifterOp(ShifterOp_D), 
    .ShifterOut(ShifterOut_D)
    );
	assign ShifterIn_D = Imm32_D;
	
	wire [25:0] Imm26_D;
	wire [31:0] RD1_for_jr_D;
	//NPC
	wire [31:0] NPC_D, PCplus8_D;	//return address
	NPC npc (
    .PC(PC_D), 
    .Branch(Branch_D), 
    .BranchType(BranchType_D), 
    .isEq(IsEq_D), 
    .ShifterOut(ShifterOut_D), 
    .Imm26(Imm26_D), 
    .RD1(RD1_for_jr_D), 
    .NextPC(NPC_D), 
    .PCplus8(PCplus8_D)
    );
	assign Imm26_D = Instr_D[25:0];
	// also include jalr
	assign RD1_for_jr_D = Real_RD1_D;
	
	wire reset_D_E, en_D_E;
	//pipeline register D/E
	wire [31:0] Instr_E, PC_E, RD1_E, RD2_E, ShifterOut_E, PCplus8_E;
	wire [4:0] RegA1_E, RegA2_E, RegDst_E, ALUop_E;
	wire RegWrite_E, MemWrite_E, IsALUSrcBRD2_E, isSP_E, IsHi_E, IsMD_E;
	wire [1:0] Tnew_E, MemType_E;
	wire [2:0] RegDataSrc_E;
	wire [2:0] MDUop_E;
	wire HiLoWrite_E;
	PR_D_E PipelineRegister_D_E (
    .clk(clk), 
    .reset(reset_D_E), 
    .en(en_D_E), 
    .InstrIn(Instr_D), 
    .RegA1In(RegA1_D), 
    .RegA2In(RegA2_D), 
    .RegWriteIn(RegWrite_D), 
    .RegDstIn(RegDst_D), 
    .RegDataSrcIn(RegDataSrc_D), 
    .MemWriteIn(MemWrite_D), 
    .IsALUSrcBRD2In(IsALUSrcBRD2_D), 
    .ALUopIn(ALUop_D), 
    .TnewIn(Tnew_D), 
    .PCIn(PC_D), 
    .RD1In(Real_RD1_D),
    .RD2In(Real_RD2_D), 
	 .ShifterOutIn(ShifterOut_D), 
	 .PCplus8In(PCplus8_D), 
	 .IsHiIn(IsHi_D), 
    .IsMDIn(IsMD_D), 
    .MDUopIn(MDUop_D), 
    .MemTypeIn(MemType_D), 
	 .HiLoWriteIn(HiLoWrite_D), 
	 .isSPIn(isSP_D), 
    .InstrOut(Instr_E), 
    .RegA1Out(RegA1_E), 
    .RegA2Out(RegA2_E), 
    .RegWriteOut(RegWrite_E), 
    .RegDstOut(RegDst_E), 
    .RegDataSrcOut(RegDataSrc_E), 
    .MemWriteOut(MemWrite_E), 
    .IsALUSrcBRD2Out(IsALUSrcBRD2_E), 
    .ALUopOut(ALUop_E), 
    .TnewOut(Tnew_E), 
    .PCOut(PC_E), 
    .RD1Out(RD1_E), 
    .RD2Out(RD2_E),
	 .ShifterOutOut(ShifterOut_E),
	 .PCplus8Out(PCplus8_E), 
	 .IsHiOut(IsHi_E), 
    .IsMDOut(IsMD_E), 
    .MDUopOut(MDUop_E), 
    .MemTypeOut(MemType_E), 
	 .HiLoWriteOut(HiLoWrite_E),
	 .isSPOut(isSP_E)
    );
	//if Stall_E == 1 then it should not be flushed, but should be flushed until the instr in E stage be moved to enxt stage.
	assign reset_D_E = reset || (Stall_D == 1 && Stall_E == 0);	
	assign en_D_E = !Stall_E;
	
	/*----------------------------- E stage --------------------------------*/
	
	wire [31:0] ALUSrcA_E;
	wire [31:0] ALUSrcB_E;
	//ALU
	wire [31:0] ALUout_E;
	ALU alu (
    .ALUSrcA(ALUSrcA_E), 
    .ALUSrcB(ALUSrcB_E), 
    .ALUop(ALUop_E), 
    .ALUout(ALUout_E)
    );
	assign ALUSrcA_E = Real_RD1_E;
	assign ALUSrcB_E = (IsALUSrcBRD2_E ? Real_RD2_E : ShifterOut_E);
	
	wire [31:0] MDSrcA_E, MDSrcB_E;
	// MDU
	wire Busy_E;
	wire [31:0] Hi_E, Lo_E;
	Mul_Div MDU (
    .clk(clk), 
    .reset(reset), 
    .SrcA(MDSrcA_E), 
    .SrcB(MDSrcB_E),
    .MDUop(MDUop_E), 
	 .HiLoWrite(HiLoWrite_E),
	 .IsHi(IsHi_E),
    .Start(IsMD_E), 
    .Busy(Busy_E), 
    .Hi(Hi_E), 
    .Lo(Lo_E)
    );
	assign MDSrcA_E = Real_RD1_E;
	assign MDSrcB_E = Real_RD2_E;
	
	wire en_E_M, reset_E_M;
	wire [31:0] HiOrLo_E;
	//pipeline register E/M
	wire [31:0] Instr_M, PC_M, RD1_M, RD2_M, PCplus8_M, ALUout_M, HiOrLo_M;
	wire [4:0] RegA1_M, RegA2_M, RegDst_M;
	wire RegWrite_M, MemWrite_M, isSP_M;
	wire [1:0] Tnew_M, MemType_M;
	wire [2:0] RegDataSrc_M;
	PR_E_M PipelineRegister_E_M (
    .clk(clk), 
    .reset(reset_E_M), 
    .en(en_E_M), 
    .InstrIn(Instr_E), 
    .RegA1In(RegA1_E), 
    .RegA2In(RegA2_E), 
    .RegWriteIn(RegWrite_E), 
    .RegDstIn(RegDst_E), 
    .RegDataSrcIn(RegDataSrc_E), 
    .MemWriteIn(MemWrite_E), 
    .TnewIn(Tnew_E), 
    .PCIn(PC_E), 
    .RD1In(Real_RD1_E), 
    .RD2In(Real_RD2_E), 
    .PCplus8In(PCplus8_E),
    .ALUoutIn(ALUout_E), 
	 .HiOrLoIn(HiOrLo_E),
	 .MemTypeIn(MemType_E),
    .isSPIn(isSP_E), 
    .InstrOut(Instr_M), 
    .RegA1Out(RegA1_M), 
    .RegA2Out(RegA2_M), 
    .RegWriteOut(RegWrite_M), 
    .RegDstOut(RegDst_M), 
    .RegDataSrcOut(RegDataSrc_M), 
    .MemWriteOut(MemWrite_M), 
    .TnewOut(Tnew_M), 
    .PCOut(PC_M), 
    .RD1Out(RD1_M), 
    .RD2Out(RD2_M), 
    .PCplus8Out(PCplus8_M), 
    .ALUoutOut(ALUout_M),
	 .HiOrLoOut(HiOrLo_M),
	 .MemTypeOut(MemType_M),
    .isSPOut(isSP_M)
    );
	assign en_E_M = 1;
	assign reset_E_M = reset || Stall_E;
	assign HiOrLo_E = (IsHi_E ? Hi_E : Lo_E);
	
	/*----------------------------- M stage --------------------------------*/
	
	//DM
	wire [31:0] DataAddr_M;
	wire [31:0] MemDataOut_M;
	wire [31:0] MemDataIn_M;
	Load_Store_Decoder load_store_decoder (
    .PC_M(PC_M), 
    .MemWrite(MemWrite_M), 
    .MemType(MemType_M), 
    .MemDataWrite(MemDataIn_M), 
    .MemAddr(DataAddr_M), 
    .m_data_rdata(m_data_rdata), 
    .m_data_addr(m_data_addr), 
    .m_data_wdata(m_data_wdata), 
    .m_data_byteen(m_data_byteen), 
    .m_inst_addr(m_inst_addr), 
    .MemDataOut(MemDataOut_M)
    );
	assign DataAddr_M = ALUout_M;
	assign MemDataIn_M = Real_RD2_M;
	/*
	//DM_P5
	wire [31:0] DataAddr_M;
	wire [31:0] MemDataOut_M;
	wire [31:0] MemDataIn_M;
	DataMem dm (
    .DataAddr(DataAddr_M), 
    .MemWrite(MemWrite_M), 
    .MemDataIn(MemDataIn_M), 
    .PC(PC_M), 
    .clk(clk), 
    .reset(reset), 
    .MemDataOut(MemDataOut_M)
    );
	assign DataAddr_M = ALUout_M;
	assign MemDataIn_M = Real_RD2_M;
	*/
	
	wire en_M_WB;
	//pipeline register M/WB
	wire [31:0] Instr_WB, RD1_WB, RD2_WB, PCplus8_WB, ALUout_WB, MemDataOut_WB, HiOrLo_WB; 
	wire isSP_WB;
	wire [1:0] Tnew_WB;
	wire [2:0] RegDataSrc_WB;
	PR_M_WB PipelineRegister_M_WB (
    .clk(clk), 
    .reset(reset), 
    .en(en_M_WB), 
    .InstrIn(Instr_M), 
    .RegWriteIn(RegWrite_M), 
    .RegDstIn(RegDst_M), 
    .RegDataSrcIn(RegDataSrc_M), 
    .TnewIn(Tnew_M), 
    .PCIn(PC_M), 
    .RD1In(Real_RD1_M), 
    .RD2In(Real_RD2_M), 
    .PCplus8In(PCplus8_M), 
    .ALUoutIn(ALUout_M), 
    .MemDataOutIn(MemDataOut_M), 
	 .HiOrLoIn(HiOrLo_M), 
    .isSPIn(isSP_M), 
    .InstrOut(Instr_WB), 
    .RegWriteOut(RegWrite_WB), 
    .RegDstOut(RegDst_WB), 
    .RegDataSrcOut(RegDataSrc_WB), 
    .TnewOut(Tnew_WB), 
    .PCOut(PC_WB), 
    .RD1Out(RD1_WB), 
    .RD2Out(RD2_WB), 
    .PCplus8Out(PCplus8_WB), 
    .ALUoutOut(ALUout_WB), 
    .MemDataOutOut(MemDataOut_WB), 
	 .HiOrLoOut(HiOrLo_WB), 
    .isSPOut(isSP_WB)
    );
	assign en_M_WB = 1;
	
	wire [31:0] DataForward_M;
	assign DataForward_M = (RegDataSrc_M == `REG_SRC_ALU) 	? 	ALUout_M 		:
									(RegDataSrc_M == `REG_SRC_PC) 	? 	PCplus8_M 		:
									(RegDataSrc_M == `REG_SRC_HI_LO)	? 	HiOrLo_M 		:
																					`X_INIT_32		;
	
	/*----------------------------- WB stage -------------------------------*/
	
	// write back
	assign DataWriteBack_WB = 	(RegDataSrc_WB == `REG_SRC_ALU) 	? 	ALUout_WB 		:
										(RegDataSrc_WB == `REG_SRC_MEM) 	? 	MemDataOut_WB 	:
										(RegDataSrc_WB == `REG_SRC_PC) 	? 	PCplus8_WB 		:
										(RegDataSrc_WB == `REG_SRC_HI_LO)? 	HiOrLo_WB 		:
																						`X_INIT_32		;
																		  
	/*----------------------------Harzard handler---------------------------*/
	
	 
	// hazard handler
	wire forward_E_to_Real_RD1_D;
	wire forward_E_to_Real_RD2_D;
	wire forward_M_to_Real_RD1_D;
	wire forward_M_to_Real_RD2_D;
	wire forward_M_to_Real_RD1_E;
	wire forward_M_to_Real_RD2_E;
	wire forward_WB_to_Real_RD1_E;
	wire forward_WB_to_Real_RD2_E;
	wire forward_WB_to_Real_RD1_M;
	wire forward_WB_to_Real_RD2_M;
	HazardHandler hazardHandler (
    .RegA1_D(RegA1_D), 
    .Tuse_RD1_D(Tuse_rs_D), 
    .RegA2_D(RegA2_D), 
    .Tuse_RD2_D(Tuse_rt_D), 
    .isD_SP(isSP_D), 
    .isE_SP(isSP_E), 
    .isM_SP(isSP_M), 
    .isWB_SP(isSP_WB), 
    .RegA1_E(RegA1_E), 
    .RegA2_E(RegA2_E), 
    .RegA1_M(RegA1_M), 
    .RegA2_M(RegA2_M), 
    .RegDst_E(RegDst_E), 
    .RegWrite_E(RegWrite_E), 
    .Tnew_E(Tnew_E), 
    .RegDst_M(RegDst_M), 
    .RegWrite_M(RegWrite_M), 
    .Tnew_M(Tnew_M), 
    .RegDst_WB(RegDst_WB), 
    .RegWrite_WB(RegWrite_WB), 
	 .HiLoWrite_D(HiLoWrite_D), 
	 .RegDataSrc_D(RegDataSrc_D), 
    .IsMD_E(IsMD_E), 
    .Busy_E(Busy_E), 
    .Stall_D(Stall_D), 
    .Stall_E(Stall_E), 
    .forward_E_to_Real_RD1_D(forward_E_to_Real_RD1_D), 
    .forward_E_to_Real_RD2_D(forward_E_to_Real_RD2_D), 
    .forward_M_to_Real_RD1_D(forward_M_to_Real_RD1_D), 
    .forward_M_to_Real_RD2_D(forward_M_to_Real_RD2_D), 
    .forward_M_to_Real_RD1_E(forward_M_to_Real_RD1_E), 
    .forward_M_to_Real_RD2_E(forward_M_to_Real_RD2_E), 
    .forward_WB_to_Real_RD1_E(forward_WB_to_Real_RD1_E), 
    .forward_WB_to_Real_RD2_E(forward_WB_to_Real_RD2_E), 
    .forward_WB_to_Real_RD1_M(forward_WB_to_Real_RD1_M), 
    .forward_WB_to_Real_RD2_M(forward_WB_to_Real_RD2_M)
    );
	
	//forwarder
	Forwarder forwarder (
    .RD1_D(RD1_D), 
    .RD2_D(RD2_D), 
    .RD1_E(RD1_E), 
    .RD2_E(RD2_E), 
    .RD1_M(RD1_M), 
    .RD2_M(RD2_M), 
    .forward_E_to_Real_RD1_D(forward_E_to_Real_RD1_D), 
    .forward_E_to_Real_RD2_D(forward_E_to_Real_RD2_D), 
    .forward_M_to_Real_RD1_D(forward_M_to_Real_RD1_D), 
    .forward_M_to_Real_RD2_D(forward_M_to_Real_RD2_D), 
    .forward_M_to_Real_RD1_E(forward_M_to_Real_RD1_E), 
    .forward_M_to_Real_RD2_E(forward_M_to_Real_RD2_E), 
    .forward_WB_to_Real_RD1_E(forward_WB_to_Real_RD1_E), 
    .forward_WB_to_Real_RD2_E(forward_WB_to_Real_RD2_E), 
    .forward_WB_to_Real_RD1_M(forward_WB_to_Real_RD1_M), 
    .forward_WB_to_Real_RD2_M(forward_WB_to_Real_RD2_M), 
    .PCplus8_E(PCplus8_E), 
    .DataForward_M(DataForward_M),
    .DataForward_WB(DataWriteBack_WB), 
    .Real_RD1_D(Real_RD1_D), 
    .Real_RD2_D(Real_RD2_D), 
    .Real_RD1_E(Real_RD1_E), 
    .Real_RD2_E(Real_RD2_E), 
    .Real_RD1_M(Real_RD1_M), 
    .Real_RD2_M(Real_RD2_M)
    );
	
endmodule