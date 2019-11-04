//instruction
// ALU
`define EXE_SPECIAL 6'b000000
`define EXE_SLL_FUNC 6'b000000
`define EXE_SRL_FUNC 6'b000010
`define EXE_ADDU_FUNC 6'b100001
`define EXE_AND_FUNC  6'b100100
`define EXE_OR_FUNC   6'b100101
`define EXE_XOR_FUNC 6'b100110
`define EXE_ADDIU 6'b001001
`define EXE_ANDI 6'b001100
`define EXE_ORI  6'b001101
`define EXE_XORI 6'b001110
`define EXE_LUI 6'b001111


//AluOp
`define EXE_LB_OP 8'b00100000
`define EXE_LW_OP 8'b00100011
`define EXE_SB_OP 8'b00101000
`define EXE_SW_OP 8'b00101011

`define EXE_ADDU_OP  8'b00100001
`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP   8'b00100110
// LUI: rt <= imm is same as rt <= imm|imm

`define EXE_SLL_OP  8'b01111100
`define EXE_SRL_OP  8'b00000010
`define EXE_BRANCH_OP 8'b00000010
`define EXE_NOP_OP    8'b00000000

//AluSel
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_SHIFT 3'b010
`define EXE_RES_NOP 3'b000
`define EXE_RES_ARITHMETIC 3'b011
`define EXE_RES_BRANCH 3'b100
`define EXE_RES_RAM 3'b101

// branch & jump
`define EXE_JUMP 6'b000010
`define EXE_JAL 6'b000011
`define EXE_JR_FUNC 6'b001000
`define EXE_BEQ 6'b000100
`define EXE_BNE 6'b000101
`define EXE_BGTZ 6'b000111

// RAM
`define EXE_LB 6'b100000
`define EXE_LW 6'b100011
`define EXE_SB 6'b101000
`define EXE_SW 6'b101011