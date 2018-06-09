//Sloan Liu, slyliu, 4/27/18
// Bit Encodings for RV64I (look at page 126 in riscv ISA spec 2.3-draft

//OP CODES (32 and 64 bit instructions) 11 opcodes
//
//
//
`define OP_LUI        7'b0110111 //32
`define OP_AUIPC      7'b0010111 //32
`define OP_JAL        7'b1101111 //32
`define OP_JALR       7'b1100111 //32
`define OP_BRANCH     7'b1100011 //32
`define OP_LOAD       7'b0000011 //32 64
`define OP_STORE      7'b0100011 //32 64
`define OP_ARITH_I    7'b0010011 //32 64
`define OP_ARITH      7'b0110011 //32 
`define OP_64ARITH_I  7'b0011011 //64 for words
`define OP_64ARITH    7'b0111011 //64
//================================


//FUNCT3's
//
//
//
//JALR FUNCT3's~~~~~~~~
//--------32 bit
`define FUNCT3_JALR   3'b000

//BRANCH FUNCT3's~~~~~~
//--------32 bit
`define FUNCT3_BRANCH_BEQ   3'b000
`define FUNCT3_BRANCH_BNE   3'b001
`define FUNCT3_BRANCH_BLT   3'b100
`define FUNCT3_BRANCH_BGE   3'b101
`define FUNCT3_BRANCH_BLTU  3'b110
`define FUNCT3_BRANCH_BGEU  3'b111

//LOAD FUNCT3's~~~~~~~~
//--------32 Bit
`define FUNCT3_LOAD_LB    3'b000
`define FUNCT3_LOAD_LH    3'b001
`define FUNCT3_LOAD_LW    3'b010
`define FUNCT3_LOAD_LBU   3'b100
`define FUNCT3_LOAD_LHU   3'b101
//--------64 bit
`define FUNCT3_LOAD_LWU   3'b110
`define FUNCT3_LOAD_LD    3'b011

//STORE FUNCT3's~~~~~~~
//--------32 bit
`define FUNCT3_STORE_SB   3'b000
`define FUNCT3_STORE_SH   3'b001
`define FUNCT3_STORE_SW   3'b010
//--------64 bit
`define FUNCT3_STORE_SD   3'b011

//ARITH_I FUNCT3's~~~~~
//--------32 bit
`define FUNCT3_ARITH_I_ADDI   3'b000
`define FUNCT3_ARITH_I_SLTI   3'b010
`define FUNCT3_ARITH_I_SLTIU  3'b011
`define FUNCT3_ARITH_I_XORI   3'b100
`define FUNCT3_ARITH_I_ORI    3'b110
`define FUNCT3_ARITH_I_ANDI   3'b111
`define FUNCT3_ARITH_I_SLLI   3'b001 //same for 64 bit
`define FUNCT3_ARITH_I_SRLI   3'b101 //same for 64 bit
`define FUNCT3_ARITH_I_SRAI   3'b101 //same for 64 bit

//ARITH FUNCT3's~~~~~~~
//--------32 bit
`define FUNCT3_ARITH_ADD    3'b000
`define FUNCT3_ARTIH_SUB    3'b000
`define FUNCT3_ARITH_SLL    3'b001
`define FUNCT3_ARITH_SLT    3'b010
`define FUNCT3_ARITH_SLTU   3'b011
`define FUNCT3_ARITH_XOR    3'b100
`define FUNCT3_ARITH_SRL    3'b101
`define FUNCT3_ARITH_SRA    3'b101
`define FUNCT3_ARITH_OR     3'b110
`define FUNCT3_ARITH_AND    3'b111

//64ARITH_I FUNCT3's
//--------64 bit
`define FUNCT3_64ARITH_I_ADDIW  3'b000
`define FUNCT3_64ARITH_I_SLLIW  3'b001
`define FUNCT3_64ARITH_I_SRLIW  3'b101
`define FUNCT3_64ARITH_I_SRAIW  3'b101

//64ARITH FUNCT3's
//--------64 bit
`define FUNCT3_64ARITH_ADDW   3'b000
`define FUNCT3_64ARITH_SUBW   3'b000
`define FUNCT3_64ARITH_SLLW   3'b001
`define FUNCT3_64ARITH_SRLW   3'b101
`define FUNCT3_64ARITH_SRAW   3'b101
//=======================================


//FUNCT7's
//
//
//
//ARITH_I FUNCT7's
//--------32 bit
`define FUNCT7_ARITH_I_SLLI   7'b0000000 //same for 64 bit 
`define FUNCT7_ARITH_I_SRLI   7'b0000000 //same for 64 bit 0
`define FUNCT7_ARITH_I_SRAI   7'b0100000 //same for 64 bit 1

//ARITH FUNCT7's
//--------32 bit
`define FUNCT7_ARITH_ADD  7'b0000000 //0
`define FUNCT7_ARITH_SUB  7'b0100000 //1
`define FUNCT7_ARITH_SLL  7'b0000000 
`define FUNCT7_ARITH_SLT  7'b0000000
`define FUNCT7_ARITH_SLTU 7'b0000000
`define FUNCT7_ARITH_XOR  7'b0000000
`define FUNCT7_ARITH_SRL  7'b0000000 //0
`define FUNCT7_ARITH_SRA  7'b0100000 //1
`define FUNCT7_ARTIH_OR   7'b0000000
`define FUNCT7_ARTIH_AND  7'b0000000

//64ARITH_I FUNCT7's
//--------64 bit
`define FUNCT7_64ARITH_I_SLLIW  7'b0000000
`define FUNCT7_64ARITH_I_SRLIW  7'b0000000 //0
`define FUNCT7_64ARITH_I_SRAIW  7'b0100000 //1

//64ARITH FUNCT7's
//--------64 bit
`define FUNCT7_64ARITH_ADDW   7'b0000000 //0
`define FUNCT7_64ARITH_SUBW   7'b0100000 //1
`define FUNCT7_64ARITH_SLLW   7'b0000000
`define FUNCT7_64ARITH_SRLW   7'b0000000 //0
`define FUNCT7_64ARITH_SRAW   7'b0100000 //1
//======================================
