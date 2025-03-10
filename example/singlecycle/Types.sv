
package Types;

import BasicTypes::*;

//
// 命令のフィールドの幅と位置
//
parameter OP_WIDTH = 6; // 幅
parameter OP_POS = 26; // 開始位置
typedef logic[ OP_WIDTH-1 : 0 ] OpPath;

parameter FUNCT_WIDTH = 6; // 幅
parameter FUNCT_POS = 0; // 開始位置
typedef logic[ FUNCT_WIDTH-1 : 0 ] FunctPath;

parameter SHAMT_WIDTH = 6; // 幅
parameter SHAMT_POS = 6; // 開始位置
typedef logic[ SHAMT_WIDTH-1 : 0 ] ShamtPath;

parameter CONSTAT_WIDTH = 32; // 幅
parameter CONSTAT_POS = 0; // 開始位置
typedef logic[ CONSTAT_WIDTH-1 : 0 ] ConstantPath;

parameter RS_POS = 21;
parameter RT_POS = 16;
// parameter RD_POS = 11;

parameter SHIFT_POS = 0;
parameter SHIFT_WIDTH = 5;
function automatic logic[SHIFT_WIDTH-1:0] GET_SHIFT(
    input DataPath disp
); 
    return disp[ SHIFT_POS +: SHIFT_WIDTH ];
endfunction

// constant を DataPath の幅にまで符号拡張する
// DataPath が小さいので，ただ取り出すだけでよい
function automatic DataPath EXPAND_CONSTANT( 
    input ConstantPath disp
);
    return disp[ CONSTAT_WIDTH - 1 : 0 ];
endfunction

// 本来はこうなる
//\
//{ \
// (disp[ `CONSTAT_WIDTH - 1 ] ? 16'hffff : 16'b0000), // [31:16] \
// disp // [15: 0] \
//}\

// アドレス幅まで符号拡張する
function automatic DataAddrPath EXPAND_ADDRESS( input ConstantPath disp );
    return disp[ DATA_ADDR_WIDTH - 1 : 0 ];
endfunction


// constant を InsnAddrPath の幅にまで符号拡張する
// InsnAddrPath が小さいので，上を取り出す
function automatic InsnAddrPath EXPAND_BR_DISPLACEMENT(ConstantPath disp);
     return { disp[ INSN_ADDR_WIDTH-1 : 0 ] };
endfunction

// 本来はこうなる
//
//`define BR_DISPLACEMENT(disp) \
//{ \
// (disp[ `CONSTAT_WIDTH - 1 ] ? 12'b111111111111 : 12'b000000000000), // [31:19] \
// disp, // [18: 2] \
// 2'b00 // [ 1: 0] \
//}\


// 命令コード

parameter OP_CODE_ALU = 0;
parameter OP_CODE_LD = 35;
parameter OP_CODE_ST = 43;

parameter OP_CODE_ADDI = 8;
parameter OP_CODE_ANDI = 12;
parameter OP_CODE_ORI  = 13;
parameter OP_CODE_BEQ  = 4;
parameter OP_CODE_BNE  = 5;


parameter FUNCT_CODE_SLL = 0;
parameter FUNCT_CODE_SRL = 2;
parameter FUNCT_CODE_ADD = 32;
parameter FUNCT_CODE_SUB = 34;
parameter FUNCT_CODE_AND = 36;
parameter FUNCT_CODE_OR  = 37;
parameter FUNCT_CODE_SLT = 42;

parameter OPCODE_WIDTH = 7;
parameter OPCODE_POS = 0;

parameter RD_POS = 7;
parameter RS1_POS = 15;
parameter RS2_POS = 20;

parameter FUNCT3_WIDTH = 3;
parameter FUNCT3_POS = 12;

parameter FUNCT7_WIDTH = 7;
parameter FUNCT7_POS = 25;

parameter OPCODE_LOAD     = 7'b0000011;
parameter OPCODE_MISC_MEM = 7'b0001111;
parameter OPCODE_OP_IMM   = 7'b0010011;
parameter OPCODE_AUIPC    = 7'b0010111;
parameter OPCODE_STORE    = 7'b0100011;
parameter OPCODE_OP       = 7'b0110011;
parameter OPCODE_LUI      = 7'b0110111;
parameter OPCODE_BRANCH   = 7'b1100011;
parameter OPCODE_JALR     = 7'b1100111;
parameter OPCODE_JAL      = 7'b1101111;
parameter OPCODE_SYSTEM   = 7'b1110011;


typedef enum logic [OPCODE_WIDTH-1:0]    // enum OpCode
{
    OC_LOAD      = 7'b0000011,
    OC_MISC_MEM  = 7'b0001111,
    OC_OP_IMM    = 7'b0010011,
    OC_AUIPC     = 7'b0010111,
    OC_STORE     = 7'b0100011,
    OC_OP        = 7'b0110011,
    OC_LUI       = 7'b0110111,
    OC_BRANCH    = 7'b1100011,
    OC_JALR      = 7'b1100111,
    OC_JAL       = 7'b1101111,
    OC_SYSTEM    = 7'b1110011
} OpCode;

typedef enum logic [2:0]    // enum OpFunct3
{
    OP_FUNCT3_ADD_SUB   = 3'b000,
    OP_FUNCT3_SLT       = 3'b010,
    OP_FUNCT3_SLTU      = 3'b011,
    OP_FUNCT3_EOR       = 3'b100,
    OP_FUNCT3_OR        = 3'b110,
    OP_FUNCT3_AND       = 3'b111,
    OP_FUNCT3_SLL       = 3'b001,
    OP_FUNCT3_SRL_SRA   = 3'b101
} OpFunct3;

//
// Op命令のfunct7
//
// typedef enum logic [6:0]    // enum OpFunct7
// {
//     OP_FUNCT7_ADD = 7'b0000000,
//     OP_FUNCT7_SUB = 7'b0100000
// } OpFunct7;

parameter OP_FUNCT7_ADD = 7'b0000000;
parameter OP_FUNCT7_SUB = 7'b0100000;
//
// シフト命令のfunct7
//
// typedef enum logic [6:0]    // enum ShiftFunct7
// {
//     SHIFT_FUNCT7_SRL = 7'b0000000,
//     SHIFT_FUNCT7_SRA = 7'b0100000
// } ShiftFunct7;

//
// 分岐命令のfunct3
//
typedef enum logic [2:0]    // enum BrFunct3
{
    BRANCH_FUNCT3_BEQ     = 3'b000,
    BRANCH_FUNCT3_BNE     = 3'b001,
    BRANCH_FUNCT3_BLT     = 3'b100,
    BRANCH_FUNCT3_BGE     = 3'b101,
    BRANCH_FUNCT3_BLTU    = 3'b110,
    BRANCH_FUNCT3_BGEU    = 3'b111
} BrFunct3;

//
// Mem命令のfunct3
//
typedef enum logic [2:0]    // enum MemFunct3
{
    MEM_FUNCT3_SIGNED_BYTE          = 3'b000,
    MEM_FUNCT3_SIGNED_HALF_WORD     = 3'b001,
    MEM_FUNCT3_WORD                 = 3'b010,
    MEM_FUNCT3_UNSIGNED_BYTE        = 3'b100,
    MEM_FUNCT3_UNSIGNED_HALF_WORD   = 3'b101
} MemFunct3;

//
// Misc-Mem命令のfunct3
//
typedef enum logic [2:0]    // enum MiscMemFunct3
{
    MISC_MEM_FUNCT3_FENCE   = 3'b000, // FENCE
    MISC_MEM_FUNCT3_FENCE_I = 3'b001  // FENCE.I
} MiscMemFunct3;

parameter SHIFT_FUNCT7_SRL = 7'b0000000;
parameter SHIFT_FUNCT7_SRA = 7'b0100000;


//
// ALU のコード
//

parameter ALU_CODE_WIDTH = 3;
typedef logic [ ALU_CODE_WIDTH-1:0 ] ALUCodePath;

parameter ALU_CODE_ADD_SUB = 3'b000;
parameter ALU_CODE_SLL     = 3'b001;
parameter ALU_CODE_SLT     = 3'b010;
parameter ALU_CODE_SLTU    = 3'b011;
parameter ALU_CODE_XOR     = 3'b100;
parameter ALU_CODE_SRL_SRA = 3'b101;
parameter ALU_CODE_OR      = 3'b110;
parameter ALU_CODE_AND     = 3'b111;


//
// 分岐のコード
//

parameter BR_CODE_WIDTH = 3;
typedef logic [ BR_CODE_WIDTH-1:0 ] BrCodePath;

parameter BR_CODE_EQ  = 3'b000;
parameter BR_CODE_NE  = 3'b001;
parameter BR_CODE_LT  = 3'b100;
parameter BR_CODE_GE  = 3'b101;
parameter BR_CODE_LTU = 3'b110;
parameter BR_CODE_GEU = 3'b111;

//
// --- レジスタ・ファイル
//

// レジスタ番号を表すために必要なビット数
// 5: 2^5 で 32 個のレジスタを表す
parameter REG_NUM_WIDTH = 5;

// レジスタ・ファイルのサイズ
// 上に合わせて 32 個に
parameter REG_FILE_SIZE = 32;

// レジスタ番号
typedef logic [ REG_NUM_WIDTH-1:0 ] RegNumPath;

typedef struct packed {
    logic [6:0] opcode;
    RegNumPath rd;
    RegNumPath rs1;
    RegNumPath rs2;
    ShamtPath shamt;
    logic [2:0] funct3;
    logic [6:0] funct7;
    ConstantPath constant;
    ALUCodePath aluCode;
    BrCodePath brCode;
    logic isBranch;
    logic isJump;
    logic isLoad;
    logic isStore;
    logic regWrEnable;
    logic isALUInConstant;
} OpInfo;


endpackage
