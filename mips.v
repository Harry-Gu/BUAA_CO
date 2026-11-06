`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:17:27 11/05/2025 
// Design Name: 
// Module Name:    misp 
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
`define ALUadd 5'b00000
`define ALUsub 5'b00001
`define ALUor 5'b00010
`define ALUisEqual 5'b00100

`define BT_beq 2'b00
`define BT_jal 2'b01
`define BT_jr 2'b10

//this setting will be used for all *.v on online judgement.
//`default_nettype none
module mips(
    input wire clk,
    input wire reset
    );
	 
	 wire [5:0] op;
	 wire [5:0] funct;
	 wire [4:0] shamt;
	 wire [4:0] rs;
	 wire [4:0] rt;
	 wire [4:0] rd;
	 wire [4:0] base;
	 wire [31:0] CurInstr;
	 wire [31:0] PCplus4;
	 wire [31:0] PC;
	 wire [31:0] ShifterOut;
	 wire [31:0] ALUout;
	 wire [31:0] MemDataOut;
	 
	 //R type
	 assign op = CurInstr[31:26];
	 assign rs = CurInstr[25:21];
	 assign rt = CurInstr[20:16];
	 assign rd = CurInstr[15:11];
	 assign shamt = CurInstr[10:6];
	 assign funct = CurInstr[5:0];
	 assign base = rs;		//base = rs
	 
	 //I type
	 wire [15:0]imm16;
	 assign imm16 = CurInstr[15:0];
	 
	 //J type
	 wire [25:0] imm26;
	 assign imm26 = CurInstr[25:0];
	 
	
	//CTRL
	wire [31:0] Instr;
	wire [4:0] RegA1;
	wire [4:0] RegA2;
	wire RegWrite, IsA1SP, IsA2SP;
	wire [4:0] RegDst;
	wire IsRegDstSP, IsRegDataFromALU, IsRegDataSP, IsSigned;
	wire [1:0] ShifterOp;
	wire MemWrite, IsMemAddrALUout, IsMemDataRD2, Branch;
	wire [1:0] BranchType;
	wire IsALUSrcARD1, IsALUSrcBRD2;
	wire [4:0] ALUop;
	ctrl controller (
    .Instr(Instr), 
    .RegA1(RegA1), 
    .RegA2(RegA2), 
    .RegWrite(RegWrite), 
    .IsA1SP(IsA1SP), 
    .IsA2SP(IsA2SP), 
    .RegDst(RegDst), 
    .IsRegDstSP(IsRegDstSP), 
    .IsRegDataFromALU(IsRegDataFromALU), 
    .IsRegDataSP(IsRegDataSP), 
    .IsSigned(IsSigned), 
    .ShifterOp(ShifterOp), 
    .MemWrite(MemWrite), 
    .IsMemAddrALUout(IsMemAddrALUout), 
    .IsMemDataRD2(IsMemDataRD2), 
    .Branch(Branch), 
    .BranchType(BranchType), 
    .IsALUSrcARD1(IsALUSrcARD1), 
    .IsALUSrcBRD2(IsALUSrcBRD2), 
    .ALUop(ALUop)
    );
	assign Instr = CurInstr;	//IM
	
	//GRF
	wire [4:0] A1;
	wire [4:0] A2;
	wire [31:0] WriteData;
	wire [4:0] WriteAddr;
	wire [31:0] CurPC;
	wire [31:0] RD1;
	wire [31:0] RD2;
	GRF registers (
    .A1(A1), 
    .A2(A2), 
    .RegWrite(RegWrite), 
    .WriteData(WriteData), 
    .WriteAddr(WriteAddr), 
    .clk(clk), 
    .reset(reset), 
    .CurPC(CurPC), 
    .RD1(RD1), 
    .RD2(RD2)
    );
	assign A1 = (IsA1SP ? 0 : RegA1);	//CTRL
	assign A2 = (IsA2SP ? 0 : RegA2);	//CTRL
	//assign RegWrite = RegWrite;		//CTRL
	assign WriteData = (IsRegDataSP ? 
								(Branch == 1 && BranchType == `BT_jal ? PCplus4 : 32'h00000000) :					//SP: has been used for "jal".
								(IsRegDataFromALU ? ALUout : MemDataOut));
	assign WriteAddr = (IsRegDstSP ? 5'b00000 : RegDst);		//SP
	//assign clk = clk;
	//assign reset = reset;
	assign CurPC = PC;
	 
	//PC register
	wire [31:0] NextPC;
	PCregister PCregister (
    .clk(clk), 
    .reset(reset), 
    .NextPC(NextPC), 
    .PC(PC)
    );
	//assign clk = clk;
	//assign reset = reset;
	//assign NextPC = NextPC;
	 
	//EXT
	wire [15:0]Imm16;
	wire [31:0] Imm32;
	BitExtender ext (
    .Imm16(Imm16), 
    .IsSigned(IsSigned), 
    .Imm32(Imm32)
    );
	assign Imm16 = imm16;
	//assign IsSigned = IsSigned;
	
	//ALU
	wire [31:0] ALUSrcA;
	wire [31:0] ALUSrcB;
	ALU alu (
    .ALUSrcA(ALUSrcA), 
    .ALUSrcB(ALUSrcB), 
    .ALUop(ALUop), 
    .ALUout(ALUout)
    );
	assign ALUSrcA = (IsALUSrcARD1 ? RD1 : 32'h00000000);
	assign ALUSrcB = (IsALUSrcBRD2 ? RD2 : ShifterOut);
	//assign ALUop = ALUop;
	
	//shifter
	wire [31:0] ShifterIn;
	shifter shifter (
    .ShifterIn(ShifterIn), 
    .ShifterOp(ShifterOp), 
    .ShifterOut(ShifterOut)
    );
	assign ShifterIn = Imm32;
	//assign ShifterOp = ShifterOp;
	
	//NPC
	wire ALUout_0;
	wire [25:0] Imm26;
	NPC npc (
    .PC(PC), 
    .Branch(Branch), 
    .BranchType(BranchType), 
    .ALUout_0(ALUout_0), 
    .ShifterOut(ShifterOut), 
    .Imm26(Imm26), 
    .RD1(RD1), 
    .NextPC(NextPC), 
    .PCplus4(PCplus4)
    );
	//assign PC = PC;
	//assign Branch = Branch;
	//assign BranchType = BranchType;
	assign ALUout_0 = ALUout[0];
	//assign ShifterOut = ShifterOut;
	assign Imm26 = imm26;
	//assign RD1 = RD1;
	
	
	//IM
	wire [31:0] IMAddr;
	InstrMem im (
    .IMAddr(IMAddr), 
    .CurInstr(CurInstr)
    );
	assign IMAddr = PC;
	
	//DM
	wire [31:0] DataAddr;
	wire [31:0] MemDataIn;
	DataMem dm (
    .DataAddr(DataAddr), 
    .MemWrite(MemWrite), 
    .MemDataIn(MemDataIn), 
    .PC(PC), 
    .clk(clk), 
    .reset(reset), 
    .MemDataOut(MemDataOut)
    );
	assign DataAddr = (IsMemAddrALUout ? ALUout : 32'h00000000);	//else: SP	
	//assign MemWrite = MemWrite;
	assign MemDataIn = (IsMemDataRD2 ? RD2 : 32'h00000000);	//else: SP
	//assign PC = PC;
	//assign clk = clk;
	//assign reset = reset;
	 
endmodule
