`define ALUadd 5'b00000
`define ALUsub 5'b00001
`define ALUor 5'b00010
`define ALUisEqual 5'b00100

`define BT_beq 2'b00
`define BT_jal 2'b01
`define BT_jr 2'b10

`define IM_SIZE (4096)
`define DM_SIZE (3072)
`define PC_INIT 32'h00003000

`define REG_SRC_ALU 2'b00
`define REG_SRC_MEM 2'b01
`define REG_SRC_PC 2'b10
//`define REG_SRC_SP 2'b11