`timescale 1ns / 1ps
`define BT_beq 2'b00
`define BT_jal 2'b01
`define BT_jr 2'b10

`define ExceptionHandlerAddr 32'h0000_4180
module NPC(
    input [31:0] PC,
    input Branch,
	input IsEret,
	input Req,
	input [31:0] EPC,
    input [1:0] BranchType,
    input ALUout_0,
    input [31:0] ShifterOut,
    input [25:0] Imm26,
    input [31:0] RD1,
    output reg [31:0] NextPC,
	output [31:0] PCplus4
    );

	assign PCplus4 = PC + 4;
	
	always@(*) begin
		if (Req) begin
			NextPC = `ExceptionHandlerAddr;
		end else if (IsEret) begin
			NextPC = EPC;
		end else if (Branch) begin
			case(BranchType)
				`BT_beq:
					begin
						if(ALUout_0) begin
							NextPC = PCplus4 + ShifterOut;
						end else begin
							NextPC = PCplus4;
						end
					end
				`BT_jal:
					begin
						NextPC = {PC[31:28], Imm26, 2'b00};
					end
				`BT_jr:
					begin
						NextPC = RD1;
					end
				default:
					begin
						//should never end up here...
						NextPC = 32'h00000000;
					end
			endcase
		end else begin
			NextPC = PCplus4;
		end
	end

endmodule
