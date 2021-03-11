// 基本的な定数や型の定義
`include "BasicTypes.v"

// ここより下に，各人の定義を追加してください
`define OP_WIDTH 6
`define OP_POS 26
`define OpPath logic[ `OP_WIDTH-1 : 0 ]

`define FUNCT_WIDTH 6
`define FUNCT_POS 0
`define FunctPath logic [ `FUNCT_WIDTH-1 : 0 ]

`define SHAMT_WIDTH 6
`define SHAMT_POS 5
`define ShamtPath logic [ `SHAMT_POS + `SHAMT_WIDTH - 1 : `SHAMT_POS ]

`define CONSTANT_WIDTH 16
`define CONSTANT_POS 0
`define ConstantPath logic [ `CONSTANT_WIDTH-1 : 0 ]

`define EXPAND_BR_DISPLACEMENT(disp) { disp[ `INSN_ADDR_WIDTH - 2 - 1 : 0 ], 2'b00 }


`define RS_POS 21
`define RT_POS 16
`define RD_POS 11

`define GET_SHIFT(disp) disp[ `SHAMT_POS +: `SHAMT_WIDTH ]

`define OP_CODE_ALU 0
`define OP_CODE_LD 35
`define OP_CODE_ST 43

`define OP_CODE_ADDI 8
`define OP_CODE_ANDI 12
`define OP_CODE_ORI  13
`define OP_CODE_BEQ 4
`define OP_CODE_BNE 5

`define FUNCT_CODE_SLL 0
`define FUNCT_CODE_SRL 2
`define FUNCT_CODE_ADD 32
`define FUNCT_CODE_SUB 34
`define FUNCT_CODE_AND 36
`define FUNCT_CODE_OR 37
`define FUNCT_CODE_XOR 38
`define FUNCT_CODE_SLT 42

`define ALU_CODE_WIDTH 3
`define ALUCodePath logic [ `ALU_CODE_WIDTH-1: 0 ]

`define ALU_CODE_SLL 0
`define ALU_CODE_SRL 1
`define ALU_CODE_ADD 2
`define ALU_CODE_SUB 3
`define ALU_CODE_AND 4
`define ALU_CODE_OR  5
`define ALU_CODE_XOR 6
`define ALU_CODE_SLT 7

`define BR_CODE_WIDTH 2
`define BrCodePath logic [ `BR_CODE_WIDTH-1 : 0 ]

`define BR_CODE_UNTAKEN 0
`define BR_CODE_TAKEN 1
`define BR_CODE_EQ 2
`define BR_CODE_NE 3

`define REG_NUM_WIDTH 5
`define REG_FILE_SIZE 32
`define RegNumPath logic [ `REG_NUM_WIDTH-1:0 ]

`define EXPAND_ADDRESS(disp) disp[ `DATA_ADDR_WIDTH - 1 : 0]