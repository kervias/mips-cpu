
// enable signal define

`define RstEnable 1'b1
`define RstDisable 1'b0
`define ENABLE 1'b1
`define DISABLE 1'b0
`define WriteEnable 1'b1
`define WriteDisable 1'b0

`define ReadEnable 1'b1
`define ReadDisable 1'b0

`define InsEnable 1'b1
`define InsDisable 1'b0


// common constant define
`define ZeroWord 32'h00000000


// bus width define
`define InsAddrWidth 31:0 
`define InsWidth 31:0
`define InsAddrBus 31:0
`define InsDataBus 31:0 

`define RegAddrBus 4:0
`define RegDataBus 31:0
`define DRegDataBus 63:0

// number of objects
`define InsMemUnitNum 262143
`define InsMemUnitNumLog2 18

`define RegFilesNum 32
`define RegFilesNumLog2 5

// instructions encoding

`define SPECIAL 6'b000000
`define SPECIAL2 6'b011100
`define REGIMM 6'b000001

// 0. NOP
`define NOP 6'b000000 // SPECIAL
`define PREF 6'b110011 //SPECIAL
`define SYNC 6'b001111

// 1. LOGIC Insts
`define AND 6'b100100 // SPECIAL
`define OR 6'b100101  // SPECIAL
`define XOR 6'b100110 // SPECIAL
`define NOR 6'b100111 // SPECIAL

`define ANDI 6'b001100
`define ORI 6'b001101
`define XORI 6'b01110
`define LUI 6'b001111

// 2. SHIFT Insts
`define SLL 6'b000000 // SPECAIL
`define SRL 6'b000010 // SPECIAL
`define SRA 6'b000011 // SPECIAL
`define SLLV 6'b000100 //SPECIAL
`define SRLV 6'b000110 //SPECIAL
`define SRAV 6'b000111 //SPECIAL

// 3. MOVE Insts
`define MOVN 6'b001011 // SPECIAL
`define MOVZ 6'b001010 // SPECIAL
`define MFHI 6'b010000 // SPECIAL
`define MFLO 6'b010010 // SPECIAL
`define MTHI 6'b010010 // SPECIAL
`define MTLO 6'b010011 // SPECIAL

// 4. Arith Insts
`define ADD 6'b100000 // SPECIAL
`define ADDU 6'b100001 // SPECIAL
`define SUB 6'b100010 // SPECIAL
`define SUBU 6'b100011 // SPECIAL
`define SLT 6'b101010 // SPECIAL 
`define SLTU 6'b101011 // SPECIAL

`define ADDI 6'b001000
`define ADDIU 6'b001001
`define SLTI 6'b001010
`define SLTIU 6'b001011

`define CLZ 6'b100000 // SPECIAL2
`define CLO 6'b100001 // SPECIAL2

`define MUL 6'b000010 // SPECIAL2
`define MULT 6'b011000 // SPECIAL
`define MULTU 6'b011001 //SPECIAL

// 5. branch insts
`define JR 6'b001000 //SPECIAL
//`define JALR 6'b001001 // SPECIAL
`define J 6'b000010
//`define JAL 6'b000011

`define BEQ 6'b000100
`define BGTZ 6'b000111
`define BLEZ 6'b000110
`define BNE 6'b000101
`define BLTZ 5'b00000   // REGIMM
//`define BLTZAL 5'b10000 // REGIMM 
`define BGEZ 5'b00001    // REGIMM
//`define BGEZAL 5'b10001 // REGIMM

// LOAD and STORE
//`define LB   6'b100000
//`define LBU  6'b100100
//`define LH   6'b100001
//`define LHU  6'b100101
`define LW   6'b100011
//`define LWL  6'b100010
//`define LWR  6'b100110
//`define SB   6'b101000
//`define SH   6'b101001
`define SW   6'b101011
//`define SWL  6'b101010
//`define SWR  6'b101110


// ALU OP
`define alu_op_nop 8'b00000000
`define alu_op_or 8'b00100101
`define ALU_OP_NOP 8'b00000000
`define ALU_OP_AND   8'b00100100
`define ALU_OP_OR    8'b00100101
`define ALU_OP_XOR  8'b00100110
`define ALU_OP_NOR  8'b00100111
`define ALU_OP_ANDI  8'b01011001
`define ALU_OP_ORI  8'b01011010
`define ALU_OP_XORI  8'b01011011
`define ALU_OP_LUI  8'b01011100   

`define ALU_OP_SLL  8'b01111100
`define ALU_OP_SLLV  8'b00000100
`define ALU_OP_SRL  8'b00000010
`define ALU_OP_SRLV  8'b00000110
`define ALU_OP_SRA  8'b00000011
`define ALU_OP_SRAV  8'b00000111

`define ALU_OP_MOVZ 8'b00001010
`define ALU_OP_MOVN 8'b00001011
`define ALU_OP_MFHI 8'b00010000
`define ALU_OP_MTHI 8'b00010001
`define ALU_OP_MFLO 8'b00010010
`define ALU_OP_MTLO 8'b00010011

`define ALU_OP_SLT  8'b00101010
`define ALU_OP_SLTU  8'b00101011
`define ALU_OP_SLTI  8'b01010111
`define ALU_OP_SLTIU  8'b01011000   
`define ALU_OP_ADD  8'b00100000
`define ALU_OP_ADDU  8'b00100001
`define ALU_OP_SUB  8'b00100010
`define ALU_OP_SUBU  8'b00100011
`define ALU_OP_ADDI  8'b01010101
`define ALU_OP_ADDIU  8'b01010110
`define ALU_OP_CLZ 8'b10110000
`define ALU_OP_CLO  8'b10110001

`define ALU_OP_MULT  8'b00011000
`define ALU_OP_MULTU  8'b00011001
`define ALU_OP_MUL  8'b10101001

`define ALU_OP_J  8'b01001111
//`define ALU_OP_JAL  8'b01010000
//`define ALU_OP_JALR  8'b00001001
`define ALU_OP_JR  8'b00001000
`define ALU_OP_BEQ  8'b01010001
`define ALU_OP_BGEZ  8'b01000001
//`define ALU_OP_BGEZAL  8'b01001011
`define ALU_OP_BGTZ  8'b01010100
`define ALU_OP_BLEZ  8'b01010011
`define ALU_OP_BLTZ  8'b01000000
//`define ALU_OP_BLTZAL  8'b01001010
`define ALU_OP_BNE  8'b01010010

`define ALU_OP_LW  8'b11100011
`define ALU_OP_SW  8'b11101011


// ALU SEL
`define ALU_NOP 3'b000
`define ALU_LOGIC 3'b001
`define ALU_SEL_LOGIC 3'b001
`define ALU_SEL_SHIFT 3'b010
`define ALU_SEL_NOP 3'b000
`define ALU_SEL_MOVE 3'b011
`define ALU_SEL_ARITH 3'b100
`define ALU_SEL_MUL 3'b101
`define ALU_SEL_BRANCH 3'b110
`define ALU_SEL_LOADSTORE 3'b111

//ALU
`define ALUOpBus 7:0
`define ALUSelBus 2:0

// DataMem
`define DMDataBus 31:0
`define DMAddrBus 31:0
`define DMUnitNum 131071
`define DMunitNumLog2 17
`define ByteWidth 7:0
