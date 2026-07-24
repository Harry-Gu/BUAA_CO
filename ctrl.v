`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:46:17 11/05/2025 
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
`define ALUadd 5'b00000
`define ALUsub 5'b00001
`define ALUor 5'b00010
`define ALUisEqual 5'b00100

`define BT_beq 2'b00
`define BT_jal 2'b01
`define BT_jr 2'b10
module ctrl(
    input [31:0] Instr,
	 //for GRF
    output reg [4:0] RegA1,		
    output reg [4:0] RegA2,
    output reg RegWrite,
	 output reg IsA1SP,
	 output reg IsA2SP,
	 output reg [4:0] RegDst,
	 output reg IsRegDstSP,
	 output reg IsRegDataFromALU,	//else from MemDataOut
	 output reg IsRegDataSP,
	 //for bit extender
	 output reg IsSigned,
	 //for shifter
	 output reg [1:0] ShifterOp,
	 //for Data memory (DM)
	 output reg MemWrite,
	 output reg IsMemAddrALUout,	//else: SP case
	 output reg IsMemDataRD2,		//else: SP case
	 //for NPC
	 output reg Branch,
	 output reg [1:0] BranchType,
	 //for ALU
	 output reg IsALUSrcARD1,
	 output reg IsALUSrcBRD2,		//else: shifter_out
	 output reg [4:0] ALUop
	 //if you add more control signal, please initial there inside always_comb
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
		 IsA1SP = 1'b0;
		 IsA2SP = 1'b0;
		 RegDst = 5'b00000;
		 IsRegDstSP = 1'b0;
		 IsRegDataFromALU = 1'b1;
		 IsRegDataSP = 1'b0;
		 IsSigned = 1'b0;
		 ShifterOp = 2'b00;
		 MemWrite = 0;
		 IsMemAddrALUout = 1'b1;
		 IsMemDataRD2 = 1'b1;
		 Branch = 0;
		 BranchType = 2'b00;
		 IsALUSrcARD1 = 1'b1;
		 IsALUSrcBRD2 = 1'b1;
		 ALUop = 5'b00000;
		 */
		 
		 //use x initialzation to make faster/lighter comb.
		 ///*
		 RegA1 = 5'bxxxxx;
		 RegA2 = 5'bxxxxx;
		 RegWrite = 0;
		 IsA1SP = 1'bx;
		 IsA2SP = 1'bx;
		 RegDst = 5'bxxxxx;
		 IsRegDstSP = 1'bx;
		 IsRegDataFromALU = 1'bx;
		 IsRegDataSP = 1'bx;
		 IsSigned = 1'bx;
		 ShifterOp = 2'bxx;
		 MemWrite = 0;
		 IsMemAddrALUout = 1'bx;
		 IsMemDataRD2 = 1'bx;
		 Branch = 0;
		 BranchType = 2'bxx;
		 IsALUSrcARD1 = 1'bx;
		 IsALUSrcBRD2 = 1'bx;
		 ALUop = 5'bxxxxx;
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
								IsA1SP = 0;
								//Read 2
								RegA2 = rt;
								IsA2SP = 0;
								//Write
								RegWrite = 1;
								RegDst = rd;
								IsRegDstSP = 0;
								IsRegDataFromALU = 1;
								IsRegDataSP = 0;
								
								//ALU
								IsALUSrcARD1 = 1;
								IsALUSrcBRD2 = 1;
								ALUop = `ALUadd;
							end
						6'b100010, 6'b100011:
							//sub, subu
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								IsA1SP = 0;
								//Read 2
								RegA2 = rt;
								IsA2SP = 0;
								//Write
								RegWrite = 1;
								RegDst = rd;
								IsRegDstSP = 0;
								IsRegDataFromALU = 1;
								IsRegDataSP = 0;
								
								//ALU
								IsALUSrcARD1 = 1;
								IsALUSrcBRD2 = 1;
								ALUop = `ALUsub;
							end
						6'b001000:
							//jr
							begin
								//REGs
								//Read 1
								RegA1 = rs;
								IsA1SP = 0;
								
								//Branch
								Branch = 1;
								BranchType = `BT_jr;	//jr
							end
					endcase
				end
			6'b001101:
				//ori
				begin
					//REGs
					//Read 1
					RegA1 = rs;
					IsA1SP = 0;
					//Write
					RegWrite = 1;
					RegDst = rt;
					IsRegDstSP = 0;
					IsRegDataFromALU = 1;
					IsRegDataSP = 0;
					
					//EXT
					IsSigned = 1'b0;
					//shifter
					ShifterOp = 2'b00;
					
					//ALU
					IsALUSrcARD1 = 1;
					IsALUSrcBRD2 = 0;	//shifter
					ALUop = `ALUor;
				end
			6'b001111:
				//lui
				begin
					//REGs
					//Read 1
					RegA1 = 5'b00000;	//well actually, rs of lui is always 00000...
					IsA1SP = 1'b0;
					//Write
					RegWrite = 1;
					RegDst = rt;
					IsRegDstSP = 0;
					IsRegDataFromALU = 1;	//else: MemDataOut
					IsRegDataSP = 0;
					
					//EXT
					IsSigned = 1'b0;	//lui may cause trouble if it uses x
					//shifetr
					ShifterOp = 2'b10;	//16
					
					//ALU
					IsALUSrcARD1 = 1;
					IsALUSrcBRD2 = 0;		//else: shifter
					ALUop = `ALUor;
				end
			6'b100011:
				//lw
				begin
					//REGs
					//Read 1
					RegA1 = base;
					IsA1SP = 1'b0;
					//Write
					RegWrite = 1;
					RegDst = rt;
					IsRegDstSP = 1'b0;
					IsRegDataFromALU = 1'b0;	//else: MemDataOut
					IsRegDataSP = 1'b0;
					
					//EXT
					IsSigned = 1'b1;
					//shifetr
					ShifterOp = 2'b00;
					
					//MEMs
					MemWrite = 0;	//read
					IsMemAddrALUout = 1'b1;
					
					//ALU
					IsALUSrcARD1 = 1'b1;
					IsALUSrcBRD2 = 1'b0;		//else: shifter
					ALUop = `ALUadd;
				end
			6'b101011:
				//sw
				begin
					//REGs
					//Read 1
					RegA1 = base;
					IsA1SP = 1'b0;
					//Read 2
					RegA2 = rt;
					IsA2SP = 1'b0;
					
					//EXT
					IsSigned = 1'b1;
					//shifetr
					ShifterOp = 2'b00;
					
					//MEMs
					MemWrite = 1;
					IsMemAddrALUout = 1'b1;
					IsMemDataRD2 = 1'b1;
					
					//ALU
					IsALUSrcARD1 = 1'b1;
					IsALUSrcBRD2 = 1'b0;		//else: shifter
					ALUop = `ALUadd;
				end
			6'b000100:
				//beq
				begin
					//REGs
					//Read 1
					RegA1 = rs;
					IsA1SP = 1'b0;
					//Read 2
					RegA2 = rt;
					IsA2SP = 1'b0;
					
					//EXT
					IsSigned = 1'b1;
					//shifetr
					ShifterOp = 2'b01;		//shamt: 2
					
					//Branch
					Branch = 1;
					BranchType = `BT_beq;
					
					//ALU
					IsALUSrcARD1 = 1'b1;
					IsALUSrcBRD2 = 1'b1;		//else: shifter
					ALUop = `ALUisEqual;
				end
			6'b000011:
				//jal
				begin
					//REGs
					//Write
					RegWrite = 1;
					RegDst = 5'b11111;	//$ra
					IsRegDstSP = 1'b0;
					IsRegDataFromALU = 1'bx;	//else: MemDataOut
					IsRegDataSP = 1'b1;	//RegData is PC+4.
				
					//Branch
					Branch = 1;
					BranchType = `BT_jal;
				end
		endcase
	 end


endmodule
/*
					//REGs
					//Read 1
					RegA1 = 5'bxxxxx;
					IsA1SP = 1'bx;
					//Read 2
					RegA2 = 5'bxxxxx;
					IsA2SP = 1'bx;
					//Write
					RegWrite = 0;
					RegDst = 5'bxxxxx;
					IsRegDstSP = 1'bx;
					IsRegDataFromALU = 1'bx;	//else: MemDataOut
					IsRegDataSP = 1'bx;
					
					//EXT
					IsSigned = 1'bx;
					//shifetr
					ShifterOp = 2'bxx;
					
					//MEMs
					MemWrite = 0;
					IsMemAddrALUout = 1'bx;
					IsMemDataRD2 = 1'bx;
					
					//Branch
					Branch = 0;
					BranchType = 2'bxx;
					
					//ALU
					IsALUSrcARD1 = 1'bx;
					IsALUSrcBRD2 = 1'bx;		//else: shifter
					ALUop = 5'bxxxxx;
*/