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
	 input wire interrupt, 
	 output wire [31:0] macroscopic_pc, 
	 
    output wire [31:0] i_inst_addr,
	 input wire [31:0] i_inst_rdata,
	 
	 output wire [31:0] m_data_addr,
    input wire [31:0] m_data_rdata,
    output wire [31:0] m_data_wdata,
    output wire [3 :0] m_data_byteen,
	 
	 output wire [31:0] m_int_addr, 
    output wire [3 :0] m_int_byteen, 
    
	 output wire [31:0] m_inst_addr,
    
	 output wire w_grf_we,
    output wire [4:0] w_grf_addr,
    output wire [31:0] w_grf_wdata,
    
	 output wire [31:0] w_inst_addr
);
	
	// CP0 is located at M stage.
	assign macroscopic_pc = PC_M;
	
	assign m_int_addr = m_data_addr;
	
	wire Stall_D, Stall_E;
	
	wire Flush_Delay;
	//assign Flush_Delay = 0;	//delay slot is enable(only for branch/jump, but not for load)
	//assign flush_Delay = Branch_D == 1 && BranchType_D == `BT_beq && IsEq_D;		//Branch delay disabled
	
	
	wire Flush_All;		// all for pipeline register, PC not included
	assign Flush_All = Req;
	
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
	assign NPC_I = Req ? `EXCEPTION_HANDLER_ADDR : (Branch_D ? NPC_D : PC_I + 4);	//to ensure the first instruction can be execute as normal. 
	assign en_PC = Req || ((!Stall_E) && (!Stall_D));
	
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
	wire IsInBD_D;
	PR_I_D PipelineRegister_I_D (
    .clk(clk), 
    .reset(reset_I), 
    .en(en_I), 
    .InstrIn(Instr_I), 
    .PCIn(PC_I), 
    .InstrOut(Instr_D), 
    .PCOut(PC_D), 
	 .IsInBDIn(Branch_D), 		// todo: double check if it is ok to do so.
	 .IsInBDOut(IsInBD_D)
    );
	assign en_I = (!Stall_E) && (!Stall_D);
	assign reset_I = reset || (Flush_Delay && en_I) || Flush_All;
	
	wire NewErrorOccur_I;
	wire [4:0] NewErrorCode_I;
	// for CP0
	wire IntReq_D;
	wire [4:0] ExcCode_D;
	ErrorRegister ER_I (
    .clk(clk), 
    .reset(reset_I), 	//borrowed from pipeline registers
	 .en(en_I), 			//borrowed from pipeline registers
    .IntReqIn(1'b0), 
    .ExcCodeIn(5'b00000), 
    .NewErrorOccur(NewErrorOccur_I), 
    .NewErrorCode(NewErrorCode_I), 
	 .IntReqOut(IntReq_D), 
    .ExcCodeOut(ExcCode_D)   
    );
	assign NewErrorOccur_I = ((PC_I & 32'b0011) != 0) || (PC_I < 32'h3000 || PC_I > 32'h6ffc);
	assign NewErrorCode_I = `EXC_CODE_ADEL;	// only possible cause

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
	wire IsSysCall_D, IsUnknownInstr_D, MightOverFlow_D, IsLoad_D, IsStore_D;
	wire CP0Write_D, IsEret_D;
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
	 .IsSysCall(IsSysCall_D), 
	 .IsUnknownInstr(IsUnknownInstr_D), 
	 .MightOverFlow(MightOverFlow_D), 	//only include calculate type instr, address overflow is not included
	 .IsLoad(IsLoad_D), 
	 .IsStore(IsStore_D),
	 .CP0Write(CP0Write_D), 
	 .IsEret(IsEret_D), 
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
	 .EPC(EPC),
    .NextPC(NPC_D), 
    .PCplus8(PCplus8_D), 
	 .Flush_Delay(Flush_Delay)
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
	wire MightOverFlow_E, IsLoad_E, IsStore_E;
	wire IsInBD_E;
	wire CP0Write_E;
	wire IsEret_E;
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
	 .MightOverFlowIn(MightOverFlow_D), 
	 .IsLoadIn(IsLoad_D), 
	 .IsStoreIn(IsStore_D), 
	 .IsInBDIn(IsInBD_D), 
	 .CP0WriteIn(CP0Write_D), 
	 .IsEretIn(IsEret_D), 
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
	 .MightOverFlowOut(MightOverFlow_E), 
	 .IsLoadOut(IsLoad_E), 
	 .IsStoreOut(IsStore_E), 
	 .IsInBDOut(IsInBD_E), 
	 .CP0WriteOut(CP0Write_E), 
	 .IsEretOut(IsEret_E), 
	 .isSPOut(isSP_E)
    );
	//if Stall_E == 1 then it should not be flushed, but should be flushed until the instr in E stage be moved to enxt stage.
	assign reset_D_E = reset || (Stall_D == 1 && Stall_E == 0) || Flush_All;	
	assign en_D_E = !Stall_E;
	
	wire NewErrorOccur_D;
	wire [4:0] NewErrorCode_D;
	//for CP0
	wire IntReq_E;
	wire [4:0] ExcCode_E;
	ErrorRegister ER_D (
    .clk(clk), 
    .reset(reset_D_E), 
    .en(en_D_E), 
    .IntReqIn(IntReq_D), 
    .ExcCodeIn(ExcCode_D), 
    .NewErrorOccur(NewErrorOccur_D), 
    .NewErrorCode(NewErrorCode_D), 
    .IntReqOut(IntReq_E), 
    .ExcCodeOut(ExcCode_E)
    );
	assign NewErrorOccur_D = IsSysCall_D || IsUnknownInstr_D;
	assign NewErrorCode_D = IsSysCall_D 			? `EXC_CODE_SYSCALL 	: 
									IsUnknownInstr_D 		? `EXC_CODE_RI			: 
																  5'bxxxxx				;
	
	/*----------------------------- E stage --------------------------------*/
	
	wire [31:0] ALUSrcA_E;
	wire [31:0] ALUSrcB_E;
	//ALU
	wire [31:0] ALUout_E;
	wire overflowOccur_E;
	ALU alu (
    .ALUSrcA(ALUSrcA_E), 
    .ALUSrcB(ALUSrcB_E), 
    .ALUop(ALUop_E), 
    .ALUout(ALUout_E), 
	 .overflow(overflowOccur_E)
    );
	assign ALUSrcA_E = Real_RD1_E;
	assign ALUSrcB_E = (IsALUSrcBRD2_E ? Real_RD2_E : ShifterOut_E);
	
	wire [31:0] MDSrcA_E, MDSrcB_E;
	wire MDUen_E;
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
	 .MDUen(MDUen_E), 
    .Busy(Busy_E), 
    .Hi(Hi_E), 
    .Lo(Lo_E)
    );
	assign MDSrcA_E = Real_RD1_E;
	assign MDSrcB_E = Real_RD2_E;
	assign MDUen_E = (!Req) && !(IntReq_E || NewErrorOccur_E);	// if there is no error in E stage and M stage
	
	wire en_E_M, reset_E_M;
	wire [31:0] HiOrLo_E;
	//pipeline register E/M
	wire [31:0] Instr_M, PC_M, RD1_M, RD2_M, PCplus8_M, ALUout_M, HiOrLo_M;
	wire [4:0] RegA1_M, RegA2_M, RegDst_M;
	wire RegWrite_M, MemWrite_M, isSP_M;
	wire [1:0] Tnew_M, MemType_M;
	wire [2:0] RegDataSrc_M;
	wire IsLoad_M, IsStore_M;
	wire IsInBD_M;
	wire CP0Write_M;
	wire IsEret_M;
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
	 .IsLoadIn(IsLoad_E), 
	 .IsStoreIn(IsStore_E), 
	 .IsInBDIn(IsInBD_E), 
	 .CP0WriteIn(CP0Write_E), 
	 .IsEretIn(IsEret_E), 
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
	 .IsLoadOut(IsLoad_M), 
	 .IsStoreOut(IsStore_M), 
	 .IsInBDOut(IsInBD_M), 
	 .CP0WriteOut(CP0Write_M), 
	 .IsEretOut(IsEret_M), 
    .isSPOut(isSP_M)
    );
	assign en_E_M = 1;
	assign reset_E_M = reset || Stall_E || Flush_All;
	assign HiOrLo_E = (IsHi_E ? Hi_E : Lo_E);
	
	wire NewErrorOccur_E;
	wire [4:0] NewErrorCode_E;
	//for CP0
	wire IntReq_M;
	wire [4:0] ExcCode_M;
	ErrorRegister ER_E (
    .clk(clk), 
    .reset(reset_E_M), 
    .en(en_E_M), 
    .IntReqIn(IntReq_E), 
    .ExcCodeIn(ExcCode_E), 
    .NewErrorOccur(NewErrorOccur_E), 
    .NewErrorCode(NewErrorCode_E), 
    .IntReqOut(IntReq_M), 
    .ExcCodeOut(ExcCode_M)
    );
	assign NewErrorOccur_E = (overflowOccur_E && MightOverFlow_E) 
									|| ((IsLoad_E || IsStore_E) && (overflowOccur_E)); 	//didnt check if it is aligned. should be checked in M stage !
	assign NewErrorCode_E = (overflowOccur_E && MightOverFlow_E) 	? `EXC_CODE_OV		:
									(IsLoad_E && overflowOccur_E)				? `EXC_CODE_ADEL	:
									(IsStore_E && overflowOccur_E)			? `EXC_CODE_ADES	:
																						  5'bxxxxx			;
	
	/*----------------------------- M stage --------------------------------*/
	
	wire Fixed_MemWrite_M;
	// I/O bridge
	wire DM_MemWrite_M;
	wire Timer0_MemWrite_M, Timer1_MemWrite_M;
	wire [31:0] MemDataOut_M;
	wire NotAlignedException_M, AddrOutOfRangeException_M, GetTimerValWithHOrBException_M, WriteTimerCountException_M; 
	Bridge bridge (
    .MemWrite(Fixed_MemWrite_M), 
    .MemDataWrite(MemDataIn_M), 
    .MemAddr(DataAddr_M), 
    .MemType(MemType_M), 
    .DM_MemWrite(DM_MemWrite_M), 
    .Timer0_MemWrite(Timer0_MemWrite_M), 
    .Timer1_MemWrite(Timer1_MemWrite_M), 
    .NotAlignedException(NotAlignedException_M), 
    .AddrOutOfRangeException(AddrOutOfRangeException_M), 
    .GetTimerValWithHOrBException(GetTimerValWithHOrBException_M), 
    .WriteTimerCountException(WriteTimerCountException_M), 
	 .DM_MemDataOut_M(DM_MemDataOut_M), 
    .timer0DataOut(timer0DataOut_M), 
    .timer1DataOut(timer1DataOut_M), 
    .MemDataOut(MemDataOut_M)
    );
	assign Fixed_MemWrite_M = (IntReq_M || CombOutsideIntReq_M)? 0 : MemWrite_M;
	
	// timer 0
	wire [31:0] timer0DataOut_M;
	wire IRQ_timer0;
	TC timer0 (
    .clk(clk), 
    .reset(reset), 
    .Addr(DataAddr_M[31:2]), 
    .WE(Timer0_MemWrite_M), 
    .Din(MemDataIn_M), 
    .Dout(timer0DataOut_M), 
    .IRQ(IRQ_timer0)
    );
	
	// timer 11
	wire [31:0] timer1DataOut_M;
	wire IRQ_timer1; 
	TC timer1 (
    .clk(clk), 
    .reset(reset), 
    .Addr(DataAddr_M[31:2]), 
    .WE(Timer1_MemWrite_M), 
    .Din(MemDataIn_M), 
    .Dout(timer1DataOut_M), 
    .IRQ(IRQ_timer1)
    );
	
	wire [31:0] DataAddr_M;
	wire [31:0] DM_MemDataOut_M;
	wire [31:0] MemDataIn_M;
	//DM or IntReqGenerater
	Load_Store_Decoder load_store_decoder (
    .PC_M(PC_M), 
    .MemWrite(DM_MemWrite_M), 		// new change in P7
    .MemType(MemType_M), 
    .MemDataWrite(MemDataIn_M), 
    .MemAddr(DataAddr_M), 
    .m_data_rdata(m_data_rdata), 
    .m_data_addr(m_data_addr), 
    .m_data_wdata(m_data_wdata), 
    .m_data_byteen(m_data_byteen), 
    .m_inst_addr(m_inst_addr), 
	 .m_int_byteen(m_int_byteen), 
    .MemDataOut(DM_MemDataOut_M)
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
	wire reset_M_WB;
	//pipeline register M/WB
	wire [31:0] Instr_WB, RD1_WB, RD2_WB, PCplus8_WB, ALUout_WB, MemDataOut_WB, HiOrLo_WB; 
	wire isSP_WB;
	wire [1:0] Tnew_WB;
	wire [2:0] RegDataSrc_WB;
	wire [31:0] CP0Data_WB;
	PR_M_WB PipelineRegister_M_WB (
    .clk(clk), 
    .reset(reset_M_WB), 
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
	 .CP0DataIn(CP0DataOut_M), 
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
	 .CP0DataOut(CP0Data_WB), 
    .isSPOut(isSP_WB)
    );
	assign en_M_WB = 1;
	assign reset_M_WB = reset || Flush_All;
	
	wire [31:0] DataForward_M;
	assign DataForward_M = (RegDataSrc_M == `REG_SRC_ALU) 	? 	ALUout_M 		:
									(RegDataSrc_M == `REG_SRC_PC) 	? 	PCplus8_M 		:
									(RegDataSrc_M == `REG_SRC_HI_LO)	? 	HiOrLo_M 		:
																					`X_INIT_32		;
	
	//ER_tmp
	wire NewErrorOccur_M;
	wire [4:0] NewErrorCode_M;
	assign NewErrorOccur_M = (IsStore_M || IsLoad_M)
									&& (NotAlignedException_M || AddrOutOfRangeException_M || GetTimerValWithHOrBException_M || WriteTimerCountException_M);
	assign NewErrorCode_M = NewErrorOccur_M ? (IsStore_M ? `EXC_CODE_ADES : `EXC_CODE_ADEL) : 5'bxxxxx;
	
	wire [4:0] CP0Addr_M;
	wire [31:0] CP0DataIn_M;
	wire ExceptionOccur_M;
	wire [4:0] ExcCodeIn_M;
	wire [5:0] HWInt_M;
	wire EXLClr_M;
	//CP0
	wire [31:0] CP0DataOut_M; 
	wire [31:0] EPC; 
	wire Req;	// will only be 1 in the case that Interrupt successful.
	wire CombOutsideIntReq_M;
	CoProcessor_0 CP0 (
    .clk(clk), 
    .reset(reset), 
    .CP0Write(CP0Write_M), 
    .CP0Addr(CP0Addr_M), 
    .CP0DataIn(CP0DataIn_M), 
    .CP0DataOut(CP0DataOut_M), 
    .ExceptionOccur(ExceptionOccur_M), 
    .VPC(PC_M), 
    .IsInBranchDelaySlot(IsInBD_M), 
    .ExcCodeIn(ExcCodeIn_M), 
    .HWInt(HWInt_M), 
    .EXLClr(IsEret_M), 
    .EPC(EPC), 
    .Req(Req), 
	 .CombIntReqOut(CombOutsideIntReq_M)		//is 1 only in case the there is a interrupt from outside or timer.
    );
	//below this two assign should not be used, the CP0 can deal with it inside
	//this should kill mtc0 and eret when exception or intreq occur
	//assign Fixed_CP0Write_M = ExceptionOccur_M ? 1'b0 : CP0Write_M;
	//assign EXLClr_M = ExceptionOccur_M ? 1'b0 : IsEret_M;
	assign CP0DataIn_M = Real_RD2_M;
	assign CP0Addr_M = Instr_M[15:11];	//rd
	assign ExceptionOccur_M = (IntReq_M || NewErrorOccur_M);
	assign ExcCodeIn_M = IntReq_M ? ExcCode_M : NewErrorCode_M;
	assign HWInt_M = {3'b000, interrupt, IRQ_timer1, IRQ_timer0};		//todo:interrupt should be attach to the top port.
	
	/*----------------------------- WB stage -------------------------------*/
	
	// write back
	assign DataWriteBack_WB = 	(RegDataSrc_WB == `REG_SRC_ALU) 	? 	ALUout_WB 		:
										(RegDataSrc_WB == `REG_SRC_MEM) 	? 	MemDataOut_WB 	:
										(RegDataSrc_WB == `REG_SRC_PC) 	? 	PCplus8_WB 		:
										(RegDataSrc_WB == `REG_SRC_HI_LO)? 	HiOrLo_WB 		:
										(RegDataSrc_WB == `REG_SRC_CP0)	? 	CP0Data_WB		:
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
	 .IsEret_D(IsEret_D), 
	 .CP0Write_E(CP0Write_E), 
	 .CP0Write_M(CP0Write_M), 
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