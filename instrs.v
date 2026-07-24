//R-type or SPECIAL
`define FUNCT_ADD 		6'b100000
`define FUNCT_ADDU 		6'b100001
`define FUNCT_SUB			6'b100010
`define FUNCT_SUBU		6'b100011
`define FUNCT_AND 		6'b100100
`define FUNCT_OR			6'b100101
`define FUNCT_SLT			6'b101010
`define FUNCT_SLTU		6'b101011
`define FUNCT_MULT		6'b011000
`define FUNCT_MULTU		6'b011001
`define FUNCT_DIV			6'b011010
`define FUNCT_DIVU 		6'b011011
`define FUNCT_MFHI		6'b010000
`define FUNCT_MFLO		6'b010010
`define FUNCT_MTHI		6'b010001
`define FUNCT_MTLO 		6'b010011
`define FUNCT_JR			6'b001000
`define FUNCT_JALR 		6'b001001

// I/J-type
`define OP_LUI			6'b001111
`define OP_ADDI		6'b001000
`define OP_ADDIU		6'b001001
`define OP_ANDI		6'b001100
`define OP_ORI			6'b001101
`define OP_LB			6'b100000
`define OP_LH			6'b100001
`define OP_LW			6'b100011
`define OP_SB			6'b101000
`define OP_SH			6'b101001
`define OP_SW			6'b101011
`define OP_BEQ			6'b000100
`define OP_BNE			6'b000101
`define OP_JAL			6'b000011
`define OP_J			6'b000010

