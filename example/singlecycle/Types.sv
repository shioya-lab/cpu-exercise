
package Types;

import BasicTypes::*;

//
// 命令のフィールドの幅と位置
//

parameter OPCODE_WIDTH = 7;
typedef logic [OPCODE_WIDTH-1:0] OpcodePath;
parameter OPCODE_POS = 0;

// レジスタ番号を表すために必要なビット数
// 5: 2^5 で 32 個のレジスタを表す
parameter REG_NUM_WIDTH = 5;
typedef logic [ REG_NUM_WIDTH-1:0 ] RegNumPath;
parameter REG_FILE_SIZE = 2 ** REG_NUM_WIDTH;
parameter RD_POS = 7;
parameter RS1_POS = 15;
parameter RS2_POS = 20;

parameter SHAMT_WIDTH = 5;
typedef logic [SHAMT_WIDTH-1:0] ShamtPath;
function automatic ShamtPath GET_SHAMT(input DataPath data);
    return data[SHAMT_WIDTH-1:0];
endfunction

parameter FUNCT3_WIDTH = 3;
typedef logic [FUNCT3_WIDTH-1:0] Funct3Path;
parameter FUNCT3_POS = 12;

parameter FUNCT7_WIDTH = 7;
typedef logic [FUNCT7_WIDTH-1:0] Funct7Path;
parameter FUNCT7_POS = 25;

parameter IMMEDIATE_WIDTH = 32;
typedef logic[IMMEDIATE_WIDTH-1:0] ImmediatePath;

// Opcode
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

// Funct7
parameter OP_FUNCT7_ADD = 7'b0000000;
parameter OP_FUNCT7_SUB = 7'b0100000;

parameter SHIFT_FUNCT7_SRL = 7'b0000000;
parameter SHIFT_FUNCT7_SRA = 7'b0100000;

// constant を InsnAddrPath の幅にまで符号拡張する
// InsnAddrPath が小さいので，上を取り出す
function automatic InsnAddrPath EXPAND_BR_DISPLACEMENT(
    input ImmediatePath disp
);
    return { disp[ INSN_ADDR_WIDTH-1 : 0 ] };
endfunction

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

typedef struct packed {
    OpcodePath opcode;
    RegNumPath rd;
    RegNumPath rs1;
    RegNumPath rs2;
    Funct3Path funct3;
    Funct7Path funct7;
    ImmediatePath imm;
    ALUCodePath aluCode;
    BrCodePath brCode;
    logic isBranch;
    logic isJump;
    logic isLoad;
    logic isStore;
    logic regWrEnable;
    logic isALUInImm;
} OpInfo;

endpackage
