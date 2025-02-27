
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

parameter CONSTAT_WIDTH = 16; // 幅
parameter CONSTAT_POS = 0; // 開始位置
typedef logic[ CONSTAT_WIDTH-1 : 0 ] ConstantPath;

parameter RS_POS = 21;
parameter RT_POS = 16;
parameter RD_POS = 11;

parameter SHIFT_POS = 6;
parameter SHIFT_WIDTH = 4;
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
     return { disp[ INSN_ADDR_WIDTH - 2 - 1 : 0 ], 2'b00 };
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


//
// ALU のコード
//

parameter ALU_CODE_WIDTH = 3;
typedef logic [ ALU_CODE_WIDTH-1:0 ] ALUCodePath;

parameter ALU_CODE_SLL = 0;
parameter ALU_CODE_SRL = 1;
parameter ALU_CODE_ADD = 2;
parameter ALU_CODE_SUB = 3;
parameter ALU_CODE_AND = 4;
parameter ALU_CODE_OR  = 5;
parameter ALU_CODE_XOR = 6;
parameter ALU_CODE_SLT = 7;


//
// 分岐のコード
//

parameter BR_CODE_WIDTH = 2;
typedef logic [ BR_CODE_WIDTH-1:0 ] BrCodePath;

parameter BR_CODE_UNTAKEN = 0;
parameter BR_CODE_TAKEN   = 1;
parameter BR_CODE_EQ      = 2;
parameter BR_CODE_NE      = 3;




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

endpackage
