`timescale 1ns / 1ps

`define EXCODE_AdEL 4			// 取数或取指时地址错误。
`define EXCODE_AdES 5			// 存数时地址错误。
`define EXCODE_Syscall 8		// 系统调用。
`define EXCODE_RI 10			// 未知指令。
`define EXCODE_Ov 12			// 执行算术指令（例如 add）时发生的溢出。

module ExcCodeArbiter(
	input IsUnknownInstr,
	input InstrMemMisalignedLoad,
	input DataMemMisaligned,
	input MemWrite,
	input IsSyscall,
	input Overflow,
	input MightOverflow,
	input MemLoad,
	output IsExceptionOccur,
	output [4:0] ExcCode
	);
	
	assign IsExceptionOccur = IsUnknownInstr 
							|| InstrMemMisalignedLoad
							|| ((MemLoad || MemWrite) 
								&& DataMemMisaligned)
							|| IsSyscall
							|| IsUnknownInstr
							|| (MightOverflow && Overflow);
	assign ExcCode = InstrMemMisalignedLoad 		? `EXCODE_AdEL 		:
					 IsUnknownInstr 				? `EXCODE_RI 		:
					 IsSyscall 						? `EXCODE_Syscall 	:
					 (MightOverflow && Overflow)	? `EXCODE_Ov 		:
					 (MemWrite && DataMemMisaligned)? `EXCODE_AdES 		:
					 (MemLoad && DataMemMisaligned) ? `EXCODE_AdEL 		: 
					 								  5'bXXXXX			;

endmodule
