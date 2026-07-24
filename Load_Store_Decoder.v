`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:31:53 11/20/2025 
// Design Name: 
// Module Name:    Load_Store_Decoder 
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
module Load_Store_Decoder(
	 input wire [31:0] PC_M,
    input wire MemWrite,
    input wire [1:0] MemType,
    input wire [31:0] MemDataWrite,
    input wire [31:0] MemAddr,
	 input wire [31:0] m_data_rdata,
    output reg [31:0] m_data_addr,
    output reg [31:0] m_data_wdata,
    output reg [3 :0] m_data_byteen,
    output reg [31:0] m_inst_addr,
	 output reg [3 :0] m_int_byteen, 
	 output reg [31:0] MemDataOut
    );
	 
	always@(*) begin
		//init
		m_inst_addr = PC_M;
		m_data_wdata = `X_INIT_32;
		m_data_byteen = 4'b0000;
		m_data_addr = MemAddr;
		MemDataOut = `X_INIT_32;
		m_int_byteen = 4'b0000;
		if(MemWrite) begin : write
			//the very code should work the same way, if there is no mem operation not aligned.
			//m_data_wdata = MemDataWrite << ({MemAddr[1:0]} << 3); 
			if(MemType == `MEM_TYPE_B) begin	: sb
				m_data_wdata = MemDataWrite << ({3'b000, MemAddr[1:0]} << 3);	//Memdata left shifter ,shift amount is 8*memaddr[1:0]
				m_data_byteen = (4'b0001 << {MemAddr[1:0]});
			end else if(MemType == `MEM_TYPE_H) begin	: sh
				m_data_wdata = MemDataWrite << ({4'b0000, MemAddr[1]} << 4);
				m_data_byteen = (4'b0011 << ({1'b0, MemAddr[1]} << 1));
			end else begin	: sw
				m_data_wdata = MemDataWrite;
				m_data_byteen = 4'b1111;
			end
		end else begin : read
			if(MemType == `MEM_TYPE_B) begin	: lb
				MemDataOut = m_data_rdata >> ({3'b000, MemAddr[1:0]} << 3);
				MemDataOut = {{24{MemDataOut[7]}}, MemDataOut[7:0]};	//sign extend (for byte)
			end else if(MemType == `MEM_TYPE_H) begin	: lh
				MemDataOut = m_data_rdata >> ({4'b0000, MemAddr[1]} << 4);
				MemDataOut = {{16{MemDataOut[15]}}, MemDataOut[15:0]};	//sign extend (for half word)
			end else begin	: lw
				MemDataOut = m_data_rdata;
			end
		end
		if(MemAddr >= 32'h7f20 && MemAddr <= 32'h7f23) begin
			m_int_byteen = m_data_byteen;
			m_data_byteen = 4'b0000;
		end
	end
	 
endmodule