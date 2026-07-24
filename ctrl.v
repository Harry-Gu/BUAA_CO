`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:05:48 11/12/2025 
// Design Name: 
// Module Name:    ctrl 
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
`include "instrs.v"
`default_nettype none
module ctrl(
    input wire [31:0] Instr,
	 //for GRF
    output reg [4:0] RegA1,
    output reg [4:0] RegA2,
    output reg RegWrite,
	 output reg [4:0] RegDst,
	 output reg [2:0] RegDataSrc,	//ALU, MEM, PC, HI/LO or CP0?
	 //for bit extender
	 output reg IsSigned,
	 //for shifter
	 output reg [1:0] ShifterOp,
	 //for Data memory (DM)
	 output reg MemWrite,
	 //for NPC
	 output reg Branch,
	 output reg [2:0] BranchType,
	 //for ALU
	 output reg IsALUSrcBRD2,		//else: shifter_out
	 output reg [4:0] ALUop,
	 
	 output reg [1:0] Tuse_rs,
	 output reg [1:0] Tuse_rt,
	 output reg [1:0] Tnew,
	 
	 output reg IsHi,
	 output reg IsMD, 
	 output reg [2:0] MDUop,
	 output reg [1:0] MemType,
	 output reg HiLoWrite, 
	 
	 output reg IsSysCall, 
	 output reg IsUnknownInstr, 
	 output reg MightOverFlow, 	//only include calculate type instr, address overflow is not included
	 output reg IsLoad, 
	 output reg IsStore, 
	 
	 output reg CP0Write, 
	 output reg IsEret, 
	 
	 output reg isSP
	 //if you add more control signal, please initialize them inside always_comb
    );
	 
	 wire [5:0] op;
	 wire [5:0] funct;
	 wire [4:0] shamt;
	 wire [4:0] rs;
	 wire [4:0] rt;
	 wire [4:0] rd;
	 wire [4:0] base;
	 
	 //R type
	 assign op = Instr[31:26];
	 assign rs = Instr[25:21];
	 assign rt = Instr[20:16];
	 assign rd = Instr[15:11];
	 assign shamt = Instr[10:6];
	 assign funct = Instr[5:0];
	 assign base = rs;		//base = rs
	 
	 //I type
	 wire [15:0]imm16;
	 assign imm16 = Instr[15:0];
	 
	 //J type
	 wire [25:0] imm26;
	 assign imm26 = Instr[25:0];
	 
	 always@(*) begin
		//initialization in case latch structure occurs.
		/*
		 RegA1 = 5'b00000;
		 RegA2 = 5'b00000;
		 RegWrite = 0;
		 RegDst = 5'b00000;
		 RegDataSrc = `REG_SRC_ALU;
		 IsSigned = 1'b0;
		 ShifterOp = 2'b00;
		 MemWrite = 0;
		 Branch = 0;
		 BranchType = 2'b00;
		 IsALUSrcBRD2 = 1'b1;
		 ALUop = 5'b00000;
		 isSP = 0;
		 */
		 
		 //use x initialzation to make faster/lighter comb.
		 ///*
		 RegA1 = 5'bxxxxx;
		 RegA2 = 5'bxxxxx;
		 RegWrite = 0;
		 RegDst = 5'bxxxxx;
		 RegDataSrc = 3'bxxx;
		 IsSigned = 1'bx;
		 ShifterOp = 2'bxx;
		 MemWrite = 0;
		 Branch = 0;
		 BranchType = 3'bxxx;
		 IsALUSrcBRD2 = 1'bx;
		 ALUop = 5'bxxxxx;
		 Tuse_rs = 2'b11;	
		 Tuse_rt = 2'b11;
		 Tnew = 2'b00;
		 IsHi = 1'bx;
		 IsMD = 0;  	//Start signal for MDU should be set to 0 if MDU wont be used.
		 MDUop = 3'bxxx;
		 MemType = 2'bxx;
		 HiLoWrite = 0;
		 IsSysCall = 0;
		 IsUnknownInstr = 0;
		 MightOverFlow = 0;
		 IsLoad = 0;
		 IsStore = 0;
		 CP0Write = 0;
		 IsEret = 0;
		 isSP = 0;		//set isSP to 1, if the new instr cannot fit in the normal ones.
		 //*/
		case(op)
			6'b000000:
				//R-type
				begin
					case(funct)
						`FUNCT_ADD:
							//add
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								//Read 2
								RegA2 = rt;
								//Write
								RegWrite = 1;
								RegDst = rd;
								RegDataSrc = `REG_SRC_ALU;
								
								//ALU
								IsALUSrcBRD2 = 1;
								ALUop = `ALU_add;
								MightOverFlow = 1;
								
								//T
								Tuse_rs = 1;
								Tuse_rt = 1;
								Tnew = 2;
							end
						`FUNCT_ADDU:
							//addu
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								//Read 2
								RegA2 = rt;
								//Write
								RegWrite = 1;
								RegDst = rd;
								RegDataSrc = `REG_SRC_ALU;
								
								//ALU
								IsALUSrcBRD2 = 1;
								ALUop = `ALU_add;
								MightOverFlow = 0;	//unsigned
								
								//T
								Tuse_rs = 1;
								Tuse_rt = 1;
								Tnew = 2;
							end
						`FUNCT_SUB:
							//sub
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								//Read 2
								RegA2 = rt;
								//Write
								RegWrite = 1;
								RegDst = rd;
								RegDataSrc = `REG_SRC_ALU;
								
								//ALU
								IsALUSrcBRD2 = 1;
								ALUop = `ALU_sub;
								MightOverFlow = 1;
								
								//T
								Tuse_rs = 1;
								Tuse_rt = 1;
								Tnew = 2;
							end
						`FUNCT_SUBU:
							//subu
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								//Read 2
								RegA2 = rt;
								//Write
								RegWrite = 1;
								RegDst = rd;
								RegDataSrc = `REG_SRC_ALU;
								
								//ALU
								IsALUSrcBRD2 = 1;
								ALUop = `ALU_sub;
								MightOverFlow = 0;		//unsigned
								
								//T
								Tuse_rs = 1;
								Tuse_rt = 1;
								Tnew = 2;
							end
						`FUNCT_AND:
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								//Read 2
								RegA2 = rt;
								//Write
								RegWrite = 1;
								RegDst = rd;
								RegDataSrc = `REG_SRC_ALU;
								
								//ALU
								IsALUSrcBRD2 = 1;		//else: shifter
								ALUop = `ALU_and;
								
								//T
								Tuse_rs = 1;
								Tuse_rt = 1;
								Tnew = 2;
							end
						`FUNCT_OR:
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								//Read 2
								RegA2 = rt;
								//Write
								RegWrite = 1;
								RegDst = rd;
								RegDataSrc = `REG_SRC_ALU;
								
								//ALU
								IsALUSrcBRD2 = 1;		//else: shifter
								ALUop = `ALU_or;
								
								//T
								Tuse_rs = 1;
								Tuse_rt = 1;
								Tnew = 2;
							end
						`FUNCT_SLT:
						//set on less than
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								//Read 2
								RegA2 = rt;
								//Write
								RegWrite = 1;
								RegDst = rd;
								RegDataSrc = `REG_SRC_ALU;
								
								//ALU
								IsALUSrcBRD2 = 1;		//else: shifter
								ALUop = `ALU_isLess;
								
								//T
								Tuse_rs = 1;
								Tuse_rt = 1;
								Tnew = 2;
							end
						`FUNCT_SLTU:
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								//Read 2
								RegA2 = rt;
								//Write
								RegWrite = 1;
								RegDst = rd;
								RegDataSrc = `REG_SRC_ALU;
								
								//ALU
								IsALUSrcBRD2 = 1;		//else: shifter
								ALUop = `ALU_isLess_unsigned;
								
								//T
								Tuse_rs = 1;
								Tuse_rt = 1;
								Tnew = 2;
							end
						`FUNCT_MULT:
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								//Read 2
								RegA2 = rt;
								
								//MDU
								//Calc
								IsMD = 1;
								MDUop = `MDU_mul;
								
								//T
								Tuse_rs = 1;
								Tuse_rt = 1;
							end
						`FUNCT_MULTU:
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								//Read 2
								RegA2 = rt;
								
								//MDU
								//Calc
								IsMD = 1;
								MDUop = `MDU_mulu;
								
								//T
								Tuse_rs = 1;
								Tuse_rt = 1;
							end
						`FUNCT_DIV:
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								//Read 2
								RegA2 = rt;
								
								//MDU
								//Calc
								IsMD = 1;
								MDUop = `MDU_div;
								
								//T
								Tuse_rs = 1;
								Tuse_rt = 1;
							end
						`FUNCT_DIVU:
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								//Read 2
								RegA2 = rt;
								
								//MDU
								//Calc
								IsMD = 1;
								MDUop = `MDU_divu;
								
								//T
								Tuse_rs = 1;
								Tuse_rt = 1;
							end
						`FUNCT_MFHI:
							begin
								//REGs
								//Write
								RegWrite = 1;
								RegDst = rd;
								RegDataSrc = `REG_SRC_HI_LO;
								
								//MDU
								//Move
								HiLoWrite = 0;
								IsHi = 1;
								
								//T
								Tnew = 2;
							end
						`FUNCT_MFLO:
							begin
								//REGs
								//Write
								RegWrite = 1;
								RegDst = rd;
								RegDataSrc = `REG_SRC_HI_LO;
								
								//MDU
								//Move
								HiLoWrite = 0;
								IsHi = 0;
								
								//T
								Tnew = 2;
							end
						`FUNCT_MTHI:
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								
								//MDU
								//Move
								HiLoWrite = 1;
								IsHi = 1;
								
								//T
								Tuse_rs = 1;
							end
						`FUNCT_MTLO:
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								
								//MDU
								//Move
								HiLoWrite = 1;
								IsHi = 0;
								
								//T
								Tuse_rs = 1;
							end
						`FUNCT_JR:
							//jr
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								
								//Branch
								Branch = 1;
								BranchType = `BT_jr;	//jr
								
								//T
								Tuse_rs = 0;
							end
						`FUNCT_JALR:
							//jalr
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								//Write
								RegWrite = 1;
								RegDst = rd;		//jalr rd, rs
								RegDataSrc = `REG_SRC_PC;
								
								//Branch
								Branch = 1;
								BranchType = `BT_jr;	//jr
								
								//T
								Tuse_rs = 0;
								Tnew = 1;
							end
						`FUNCT_SYSCALL:
							begin
								//syscall
								IsSysCall = 1;
							end
						`FUNCT_NOP:
							begin
								IsUnknownInstr = 0;		//do nothing
							end
						default:
							begin
								IsUnknownInstr = 1;
							end
					endcase
				end
				
			`OP_LUI:
				//lui
				begin
					//REGs
					//Read 1
					RegA1 = 5'b00000;	//well actually, rs of lui is always 00000...
					//Write
					RegWrite = 1;
					RegDst = rt;
					RegDataSrc = `REG_SRC_ALU;
					
					//EXT
					IsSigned = 1'b0;	//lui may cause trouble if it uses x
					//shifetr
					ShifterOp = `SHIFTER_MOD_16;	//16
					
					//ALU
					IsALUSrcBRD2 = 0;		//else: shifter
					ALUop = `ALU_or;
					
					//T
					Tuse_rs = 1;
					Tnew = 2;
				end
			`OP_ADDI:
				begin
					//REGs
					//Read 1
					RegA1 = rs;
					//Write
					RegWrite = 1;
					RegDst = rt;
					RegDataSrc = `REG_SRC_ALU;
					
					//EXT
					IsSigned = 1;		//addiu still use signed extend !
					//shifetr
					ShifterOp = `SHIFTER_MOD_0;
					
					//ALU
					IsALUSrcBRD2 = 0;		//else: shifter
					ALUop = `ALU_add;
					MightOverFlow = 1;
					
					//T
					Tuse_rs = 1;
					Tnew = 2;
				end
			`OP_ADDIU:
			//u in ADDIU means it wont trap when overflow, but still use sign-ext.
				begin
					//REGs
					//Read 1
					RegA1 = rs;
					//Write
					RegWrite = 1;
					RegDst = rt;
					RegDataSrc = `REG_SRC_ALU;
					
					//EXT
					IsSigned = 1;		//addiu still use signed extend !
					//shifetr
					ShifterOp = `SHIFTER_MOD_0;
					
					//ALU
					IsALUSrcBRD2 = 0;		//else: shifter
					ALUop = `ALU_add;
					MightOverFlow = 0;
					
					//T
					Tuse_rs = 1;
					Tnew = 2;
				end
			`OP_ANDI:
			//this is andi , NOT addi !!!
				begin
					//REGs
					//Read 1
					RegA1 = rs;
					//Write
					RegWrite = 1;
					RegDst = rt;
					RegDataSrc = `REG_SRC_ALU;
					
					//EXT
					IsSigned = 1'b0;
					//shifter
					ShifterOp = `SHIFTER_MOD_0;
					
					//ALU
					IsALUSrcBRD2 = 0;	//shifter
					ALUop = `ALU_and;
					
					//T
					Tuse_rs = 1;
					Tnew = 2;
				end
			`OP_ORI:
				//ori
				begin
					//REGs
					//Read 1
					RegA1 = rs;
					//Write
					RegWrite = 1;
					RegDst = rt;
					RegDataSrc = `REG_SRC_ALU;
					
					//EXT
					IsSigned = 1'b0;
					//shifter
					ShifterOp = `SHIFTER_MOD_0;
					
					//ALU
					IsALUSrcBRD2 = 0;	//shifter
					ALUop = `ALU_or;
					
					//T
					Tuse_rs = 1;
					Tnew = 2;
				end
			`OP_LB:
				begin
					//REGs
					//Read 1
					RegA1 = base;
					//Write
					RegWrite = 1;
					RegDst = rt;
					RegDataSrc = `REG_SRC_MEM;
					
					//EXT
					IsSigned = 1;
					//shifetr
					ShifterOp = `SHIFTER_MOD_0;
					
					//MEMs
					MemWrite = 0;	//read
					MemType = `MEM_TYPE_B;
					IsLoad = 1;
					
					//ALU
					IsALUSrcBRD2 = 0;		//else: shifter
					ALUop = `ALU_add;
					
					//T
					Tuse_rs = 1;
					Tnew = 3;
				end
			`OP_LH:
				begin
					//REGs
					//Read 1
					RegA1 = base;
					//Write
					RegWrite = 1;
					RegDst = rt;
					RegDataSrc = `REG_SRC_MEM;
					
					//EXT
					IsSigned = 1'b1;
					//shifetr
					ShifterOp = `SHIFTER_MOD_0;
					
					//MEMs
					MemWrite = 0;	//read
					MemType = `MEM_TYPE_H;
					IsLoad = 1;
					
					//ALU
					IsALUSrcBRD2 = 1'b0;		//else: shifter
					ALUop = `ALU_add;
					
					//T
					Tuse_rs = 1;
					Tnew = 3;
				end
			`OP_LW:
				//lw
				begin
					//REGs
					//Read 1
					RegA1 = base;
					//Write
					RegWrite = 1;
					RegDst = rt;
					RegDataSrc = `REG_SRC_MEM;
					
					//EXT
					IsSigned = 1'b1;
					//shifetr
					ShifterOp = `SHIFTER_MOD_0;
					
					//MEMs
					MemWrite = 0;	//read
					MemType = `MEM_TYPE_W;
					IsLoad = 1;
					
					//ALU
					IsALUSrcBRD2 = 1'b0;		//else: shifter
					ALUop = `ALU_add;
					
					//T
					Tuse_rs = 1;
					Tnew = 3;
				end
			`OP_SB:
				begin
					//REGs
					//Read 1
					RegA1 = base;
					//Read 2
					RegA2 = rt;
					
					//EXT
					IsSigned = 1'b1;
					//shifetr
					ShifterOp = `SHIFTER_MOD_0;
					
					//MEMs
					MemWrite = 1;
					MemType = `MEM_TYPE_B;
					IsStore = 1;
					
					//ALU
					IsALUSrcBRD2 = 1'b0;		//else: shifter
					ALUop = `ALU_add;
					
					//T
					Tuse_rs = 1;
					Tuse_rt = 2;
				end
			`OP_SH:
				begin
					//REGs
					//Read 1
					RegA1 = base;
					//Read 2
					RegA2 = rt;
					
					//EXT
					IsSigned = 1'b1;
					//shifetr
					ShifterOp = `SHIFTER_MOD_0;
					
					//MEMs
					MemWrite = 1;
					MemType = `MEM_TYPE_H;
					IsStore = 1;
					
					//ALU
					IsALUSrcBRD2 = 1'b0;		//else: shifter
					ALUop = `ALU_add;
					
					//T
					Tuse_rs = 1;
					Tuse_rt = 2;
				end
			`OP_SW:
				//sw
				begin
					//REGs
					//Read 1
					RegA1 = base;
					//Read 2
					RegA2 = rt;
					
					//EXT
					IsSigned = 1'b1;
					//shifetr
					ShifterOp = `SHIFTER_MOD_0;
					
					//MEMs
					MemWrite = 1;
					MemType = `MEM_TYPE_W;
					IsStore = 1;
					
					//ALU
					IsALUSrcBRD2 = 1'b0;		//else: shifter
					ALUop = `ALU_add;
					
					//T
					Tuse_rs = 1;
					Tuse_rt = 2;
				end
			`OP_BEQ:
				//beq
				begin
					//REGs
					//Read 1
					RegA1 = rs;
					//Read 2
					RegA2 = rt;
					
					//EXT
					IsSigned = 1'b1;
					//shifetr
					ShifterOp = `SHIFTER_MOD_2;		//shamt: 2
					
					//Branch
					Branch = 1;
					BranchType = `BT_beq;
					
					//ALU
					IsALUSrcBRD2 = 1'b1;		//else: shifter
					ALUop = `ALU_isEqual;
					
					//T
					Tuse_rs = 0;
					Tuse_rt = 0;
				end
			`OP_BNE:
				begin
					//REGs
					//Read 1
					RegA1 = rs;
					//Read 2
					RegA2 = rt;
					
					//EXT
					IsSigned = 1'b1;
					//shifetr
					ShifterOp = `SHIFTER_MOD_2;		//shamt: 2
					
					//Branch
					Branch = 1;
					BranchType = `BT_bne;
					
					//ALU
					IsALUSrcBRD2 = 1'b1;		//else: shifter
					ALUop = `ALU_isEqual;
					
					//T
					Tuse_rs = 0;
					Tuse_rt = 0;
				end
			`OP_JAL:
				//jal
				begin
					//REGs
					//Write
					RegWrite = 1;
					RegDst = 5'b11111;	//$ra
					RegDataSrc = `REG_SRC_PC;
				
					//Branch
					Branch = 1;
					BranchType = `BT_jal;
					
					//T
					Tnew = 1;
				end
			`OP_J:
				//jal
				begin
					//Branch
					Branch = 1;
					BranchType = `BT_jal;
				end
			`OP_CP0:
				//CP0
				begin
					case(rs)
						`CP0_OP_MFC0:
							begin
								//REGs
								//Write
								RegWrite = 1;
								RegDst = rt;
								RegDataSrc = `REG_SRC_CP0;
								
								//T
								Tnew = 3;
							end
						`CP0_OP_MTC0:
							begin
								//REGs
								//Read 2
								RegA2 = rt;
								
								// SP !!!!!!!!!!!!
								RegDst = rd;	//just for forwarding proccess.
								
								//CP0
								CP0Write = 1;
								
								//T
								Tuse_rt = 2;
							end
						`CP0_OP_ERET:
							begin
								//Branch
								Branch = 1;
								BranchType = `BT_eret;
								
								//CP0
								IsEret = 1;
							end
					endcase
				end
			default:
				begin
					IsUnknownInstr = 1;
				end
		endcase
	 end


endmodule
/*
					//REGs
					//Read 1
					RegA1 = 5'bxxxxx;
					//Read 2
					RegA2 = 5'bxxxxx;
					//Write
					RegWrite = 0;
					RegDst = 5'bxxxxx;
					RegDataSrc = 3'bxxx;
					
					//EXT
					IsSigned = 1'bx;
					//shifetr
					ShifterOp = 2'bxx;
					
					//MEMs
					MemWrite = 0;
					MemType = 2'bxx;
					IsLoad = 0;
					IsStore = 0;
					
					//MDU
					//Calc
					IsMD = 0;
					MDUop = 3'bxxx;
					//Move
					HiLoWrite = 0;
					IsHi = 1'bx;
					
					//Branch
					Branch = 0;
					BranchType = 3'bxxx;
					
					//ALU
					IsALUSrcBRD2 = 1'bx;		//else: shifter
					ALUop = 5'bxxxxx;
					MightOverFlow = 0;
					
					//syscall
					IsSysCall = 0;
					
					//CP0
					CP0Write = 0;
					IsEret = 0;
					
					//T
					Tuse_rs = ?;
					Tuse_rt = ?;
					Tnew = ?;
*/