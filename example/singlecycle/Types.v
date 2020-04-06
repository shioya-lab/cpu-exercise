`include "BasicTypes.v"


//
// 命令のフィールドの幅と位置
//
`define OP_WIDTH 6	// 幅
`define OP_POS   26	// 開始位置
`define OpPath logic[ `OP_WIDTH-1 : 0 ]

`define FUNCT_WIDTH 6	// 幅
`define FUNCT_POS   0	// 開始位置
`define FunctPath logic[ `FUNCT_WIDTH-1 : 0 ]

`define SHAMT_WIDTH 6	// 幅
`define SHAMT_POS   6	// 開始位置
`define ShamtPath logic[ `SHAMT_WIDTH-1 : 0 ]

`define CONSTAT_WIDTH 16	// 幅
`define CONSTAT_POS   0		// 開始位置
`define ConstantPath logic[ `CONSTAT_WIDTH-1 : 0 ]

`define RS_POS 21
`define RT_POS 16
`define RD_POS 11

`define SHIFT_POS   6
`define SHIFT_WIDTH 4
`define GET_SHIFT( disp ) disp[ `SHIFT_POS +: `SHIFT_WIDTH ]

// constant を DataPath の幅にまで符号拡張する
// DataPath が小さいので，ただ取り出すだけでよい
`define EXPAND_CONSTANT( disp ) disp[ `CONSTAT_WIDTH - 1 : 0 ]

// 本来はこうなる
//\
//{ \
//	(disp[ `CONSTAT_WIDTH - 1 ] ? 16'hffff : 16'b0000),	// [31:16] \
//	disp												// [15: 0] \
//}\

// アドレス幅まで符号拡張する
`define EXPAND_ADDRESS( disp ) disp[ `DATA_ADDR_WIDTH - 1 : 0 ]



// constant を InsnAddrPath の幅にまで符号拡張する
// InsnAddrPath が小さいので，上を取り出す
`define EXPAND_BR_DISPLACEMENT(disp) \
	{ disp[ `INSN_ADDR_WIDTH - 2 - 1 : 0 ], 2'b00 }

// 本来はこうなる
//
//`define BR_DISPLACEMENT(disp) \
//{ \
//	(disp[ `CONSTAT_WIDTH - 1 ] ? 12'b111111111111 : 12'b000000000000),	// [31:19] \
//	disp,																// [18: 2] \
//	2'b00																// [ 1: 0] \
//}\


// 命令コード

`define OP_CODE_ALU  0
`define OP_CODE_LD   35
`define OP_CODE_ST   43

`define OP_CODE_ADDI 8
`define OP_CODE_ANDI 12
`define OP_CODE_ORI  13
`define OP_CODE_BEQ  4
`define OP_CODE_BNE  5


`define FUNCT_CODE_SLL 0
`define FUNCT_CODE_SRL 2
`define FUNCT_CODE_ADD 32
`define FUNCT_CODE_SUB 34
`define FUNCT_CODE_AND 36
`define FUNCT_CODE_OR  37
`define FUNCT_CODE_SLT 42


//
// ALU のコード
//

`define ALU_CODE_WIDTH 3
`define ALUCodePath logic [ `ALU_CODE_WIDTH-1:0 ]

`define ALU_CODE_SLL 0
`define ALU_CODE_SRL 1
`define ALU_CODE_ADD 2
`define ALU_CODE_SUB 3
`define ALU_CODE_AND 4
`define ALU_CODE_OR  5
`define ALU_CODE_XOR 6
`define ALU_CODE_SLT 7


//
// 分岐のコード
//

`define BR_CODE_WIDTH 2
`define BrCodePath logic [ `BR_CODE_WIDTH-1:0 ]

`define BR_CODE_UNTAKEN 0
`define BR_CODE_TAKEN   1
`define BR_CODE_EQ      2
`define BR_CODE_NE      3




//
// --- レジスタ・ファイル
//

// レジスタ番号を表すために必要なビット数
// 5: 2^5 で 32 個のレジスタを表す
`define REG_NUM_WIDTH 5

// レジスタ・ファイルのサイズ
// 上に合わせて 32 個に
`define REG_FILE_SIZE 32

// レジスタ番号
`define RegNumPath logic [ `REG_NUM_WIDTH-1:0 ]

