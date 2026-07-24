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
//`default_nettype none
module ctrl(
    input wire[31:0] Instr,
	 //for GRF
    output reg [4:0] RegA1,
    output reg [4:0] RegA2,
    output reg RegWrite,
	 output reg [4:0] RegDst,
	 output reg [1:0] RegDataSrc,	//ALU, MEM or PC ?
	 //for bit extender
	 output reg IsSigned,
	 //for shifter
	 output reg [1:0] ShifterOp,
	 //for Data memory (DM)
	 output reg MemWrite,
	 //for NPC
	 output reg Branch,
	 output reg [1:0] BranchType,
	 //for ALU
	 output reg IsALUSrcBRD2,		//else: shifter_out
	 output reg [4:0] ALUop,
	 
	 output reg [1:0] Tuse_rs,
	 output reg [1:0] Tuse_rt,
	 output reg [1:0] Tnew,
	 
	 
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
		 RegDataSrc = 2'bxx;
		 IsSigned = 1'bx;
		 ShifterOp = 2'bxx;
		 MemWrite = 0;
		 Branch = 0;
		 BranchType = 2'bxx;
		 IsALUSrcBRD2 = 1'bx;
		 ALUop = 5'bxxxxx;
		 Tuse_rs = 2'b11;	
		 Tuse_rt = 2'b11;
		 Tnew = 2'b00;
		 isSP = 0;		//set isSP to 1, if the new instr cannot fit in the normal ones.
		 //*/
		case(op)
			6'b000000:
				//R-type
				begin
					case(funct)
						6'b100000, 6'b100001:
							//add, addu
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
								ALUop = `ALUadd;
								
								//T
								Tuse_rs = 1;
								Tuse_rt = 1;
								Tnew = 2;
							end
						6'b100010, 6'b100011:
							//sub, subu
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
								ALUop = `ALUsub;
								
								//T
								Tuse_rs = 1;
								Tuse_rt = 1;
								Tnew = 2;
							end
						6'b001000:
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
						6'b001001:
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
						
					endcase
				end
			6'b001101:
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
					ShifterOp = 2'b00;
					
					//ALU
					IsALUSrcBRD2 = 0;	//shifter
					ALUop = `ALUor;
					
					//T
					Tuse_rs = 1;
					Tnew = 2;
				end
			6'b001111:
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
					ShifterOp = 2'b10;	//16
					
					//ALU
					IsALUSrcBRD2 = 0;		//else: shifter
					ALUop = `ALUor;
					
					//T
					Tuse_rs = 1;
					Tnew = 2;
				end
			6'b100011:
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
					ShifterOp = 2'b00;
					
					//MEMs
					MemWrite = 0;	//read
					
					//ALU
					IsALUSrcBRD2 = 1'b0;		//else: shifter
					ALUop = `ALUadd;
					
					//T
					Tuse_rs = 1;
					Tnew = 3;
				end
			6'b101011:
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
					ShifterOp = 2'b00;
					
					//MEMs
					MemWrite = 1;
					
					//ALU
					IsALUSrcBRD2 = 1'b0;		//else: shifter
					ALUop = `ALUadd;
					
					//T
					Tuse_rs = 1;
					Tuse_rt = 2;
				end
			6'b000100:
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
					ShifterOp = 2'b01;		//shamt: 2
					
					//Branch
					Branch = 1;
					BranchType = `BT_beq;
					
					//ALU
					IsALUSrcBRD2 = 1'b1;		//else: shifter
					ALUop = `ALUisEqual;
					
					//T
					Tuse_rs = 0;
					Tuse_rt = 0;
				end
			6'b000011:
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
					RegDataSrc = 2'bxx;
					
					//EXT
					IsSigned = 1'bx;
					//shifetr
					ShifterOp = 2'bxx;
					
					//MEMs
					MemWrite = 0;
					
					//Branch
					Branch = 0;
					BranchType = 2'bxx;
					
					//ALU
					IsALUSrcBRD2 = 1'bx;		//else: shifter
					ALUop = 5'bxxxxx;
*/