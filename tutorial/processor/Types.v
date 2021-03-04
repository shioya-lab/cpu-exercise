// 基本的な定数や型の定義
`include "BasicTypes.v"

// ここより下に，各人の定義を追加してください
`define OP_WIDTH 6
`define OP_POS 26
`define OpPath logic[ `OP_WIDTH-1 : 0 ]

`define FUNCT_WIDTH 6
`define FUNCT_POS 0
`define FunctPath logic [ `FUNCT_WIDTH-1 : 0 ]

`define SHAMT_WIDTH 5
`define SHAMT_POS 5
`define ShamtPath logic [ `SHAMT_POS +: `SHAMT_WIDTH ]

`define CONSTANT_WIDTH 16
`define CONSTANT_POS 0
`define ConstantPath logic [ `CONSTANT_WIDTH-1 : 0 ]

`define RS_POS 21
`define RD_POS 16
`define RD_POS 11

`define OP_CODE_ALU 0
`define OP_CODE_LD 35
`define OP_CODE_ST 43

`define OP_CODE_ADDI 8
`define OP_CODE_BEQ 4
`define OP_CODE_BNE 5

`define FUNCT_CODE_ADD 32
`define FUNCT_CODE_SUB 34
`define FUNCT_CODE_AND 36
`define FUNCT_CODE_OR 37
`define FUNCT_CODE_SLT 42

`define ALU_CODE_WIDTH 3
`define ALUCodePath logic [ `ALU_CODE_WIDTH-1: 0 ]

`define ALU_CODE_ADD 0
`define ALU_CODE_SUB 1
`define ALU_CODE_AND 2
`define ALU_CODE_OR 3
`define ALU_CODE_SLT 4

`define BR_CODE_WIDTH 2
`define BrCodePath logic [ `BR_CODE_WIDTH-1 : 0 ]

`define BR_CODE_UNTAKEN 0
`define BR_CODE_TAKEN 1
`define BR_CODE_EQ 2
`define BR_CODE_NE 3