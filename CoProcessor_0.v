`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:24:00 12/06/2025 
// Design Name: 
// Module Name:    CoProcessor_0 
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
`define CP0_SR CP0_registers[12]
`define CP0_CAUSE CP0_registers[13]
`define CP0_EPC CP0_registers[14]

`define CP0_INT_MASK `CP0_SR[15:10]
`define CP0_EXL `CP0_SR[1]
`define CP0_IE `CP0_SR[0]
`define CP0_BD `CP0_CAUSE[31]
`define CP0_IP `CP0_CAUSE[15:10]
`define CP0_EXC_CODE `CP0_CAUSE[6:2]
module CoProcessor_0(
    input wire clk,
    input wire reset,
    input wire CP0Write,
    input wire [4:0] CP0Addr,
    input wire [31:0] CP0DataIn,
    output reg [31:0] CP0DataOut,		//remember to change the comb of CP0DataOut below !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	 input wire ExceptionOccur, 
    input wire [31:0] VPC,
    input wire IsInBranchDelaySlot,
    input wire [4:0] ExcCodeIn,
    input wire [5:0] HWInt,
    input wire EXLClr,
    output wire [31:0] EPC,
    output reg Req, 
	 output wire CombIntReqOut
    );
	assign CombIntReqOut = not_exception_int_req;
	reg not_exception_int_req;
	//register file of CP0
	reg [31:0] CP0_registers[31:0];
	//assign CP0DataOut = CP0_registers[CP0Addr];
	assign EPC = `CP0_EPC;
	always@(posedge clk) begin
		if(reset) begin : reset_proccess
			integer i;
			for(i=0;i<32;i=i+1) begin
				CP0_registers[i] <= 0;
			end
		end else begin
			`CP0_IP <= HWInt;
			if(Req) begin
				`CP0_EPC <= (IsInBranchDelaySlot ? VPC - 4 : VPC);
				`CP0_EXL <= 1;
				`CP0_BD <= IsInBranchDelaySlot;
				if(not_exception_int_req) begin
					// interrupt or timer
					`CP0_EXC_CODE <= 5'b00000;
				end else begin
					//exception
					`CP0_EXC_CODE <= ExcCodeIn;
				end
			end else if(CP0Write) begin
				//only if there is no Req can CP0 be written
				CP0_registers[CP0Addr] <= CP0DataIn;
			end else if(EXLClr) begin
				//only if there is no Req can EXL be written (eret executed)
				// maybe we should reconsider the order of these "if"
				`CP0_EXL <= 0;
			end
		end
	end
	
	// comb : Req?
	always@(*) begin
		Req = 0;
		not_exception_int_req = 0;
		if(!`CP0_EXL) begin
			if(`CP0_IE && (`CP0_INT_MASK & HWInt) != 6'b000000) begin
				// interrupt
				Req = 1;
				not_exception_int_req = 1;		//should set Req to 1 at the same time.
			end else if(ExceptionOccur) begin
				//exception
				Req = 1;
			end
		end
	end
	
	// comb : CP0DataOut
	always@(*) begin
		CP0DataOut = 32'h0;
		case(CP0Addr)
			12:
				// SR
				begin
					CP0DataOut[15:10] = CP0_registers[12][15:10];
					CP0DataOut[1:0] = CP0_registers[12][1:0];
				end
			13:
				// CAUSE
				begin
					CP0DataOut[31] = CP0_registers[13][31];
					CP0DataOut[15:10] = CP0_registers[13][15:10];
					CP0DataOut[6:2] = CP0_registers[13][6:2];
				end
			14:
				//EPC
				begin
					CP0DataOut = CP0_registers[14];
				end
			default:
				begin
					CP0DataOut = 32'h0;
				end
		endcase
	end
	


endmodule
