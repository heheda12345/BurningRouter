//instruction
`define EXE_SPECIAL 6'b000000
`define EXE_SLL_FUNC 6'b000000
`define EXE_SRL_FUNC 6'b000010
`define EXE_AND_FUNC  6'b100100
`define EXE_OR_FUNC   6'b100101
`define EXE_XOR_FUNC 6'b100110
`define EXE_ANDI 6'b001100
`define EXE_ORI  6'b001101
`define EXE_XORI 6'b001110
`define EXE_LUI 6'b001111


//AluOp
`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP  8'b00100110
// LUI: rt <= imm is same as rt <= imm|imm

`define EXE_SLL_OP  8'b01111100
`define EXE_SRL_OP  8'b00000010

`define EXE_NOP_OP    8'b00000000

//AluSel
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_SHIFT 3'b010
`define EXE_RES_NOP 3'b000