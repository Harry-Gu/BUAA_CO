`define ALU_add 5'b00000
`define ALU_sub 5'b00001
`define ALU_and 5'b00010
`define ALU_or 5'b00011
`define ALU_isEqual 5'b00100
`define ALU_isLess 5'b00110
`define ALU_isLess_unsigned 5'b00111

`define BT_beq 3'b000
`define BT_bne 3'b001
`define BT_jal 3'b010
`define BT_jr 3'b011
`define BT_eret 3'b100

`define IM_SIZE (4096)
`define DM_SIZE (3072)
`define PC_INIT 32'h00003000

`define REG_SRC_ALU 3'b000
`define REG_SRC_MEM 3'b001
`define REG_SRC_PC 3'b010
`define REG_SRC_HI_LO 3'b011
`define REG_SRC_CP0 3'b100

`define X_INIT_32 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx

`define MUL_DELAY 5
`define DIV_DELAY 10

`define MEM_TYPE_B 2'b00
`define MEM_TYPE_H 2'b01
`define MEM_TYPE_W 2'b10

`define MDU_mul 3'b000
`define MDU_mulu 3'b001
`define MDU_div 3'b010
`define MDU_divu 3'b011

`define SHIFTER_MOD_0 2'b00
`define SHIFTER_MOD_2 2'b01
`define SHIFTER_MOD_16 2'b10

`define EXC_CODE_INT 0
// 	PC not aligned / PC out of range / load not aligned / load from timer with lh or lb / **address overflow** / address out of range 
`define EXC_CODE_ADEL 4
// 	store not aligned / store to timer with sh or sb / try to store to count register of timer / **address overflow** / address out of range 
`define EXC_CODE_ADES 5
`define EXC_CODE_SYSCALL 8
// unknown instruction
`define EXC_CODE_RI 10
// calc-type instr overflow
`define EXC_CODE_OV 12

`define EXCEPTION_HANDLER_ADDR 32'h4180