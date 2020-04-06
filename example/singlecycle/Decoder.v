//
// デコード・ユニット
//


`include "Types.v" 


module Decoder(
	
	output `OpPath     op,
	output `RegNumPath rs,
	output `RegNumPath rt,
	output `RegNumPath rd,
	output `ShamtPath  shamt,
	output `FunctPath  funct,
	output `ConstantPath constat,
	output `ALUCodePath  aluCode,
	output `BrCodePath   brCode,
	output logic pcWrEnable,		// PC 書き込みを行うかどうか
	output logic isLoadInsn,		// ロード命令かどうか
	output logic isStoreInsn,		// ストア命令かどうか
	output logic isSrcA_Rt,			// ソースAがRtかどうか
	output logic isDstRt,			// ディスティネーションがRtかどうか
	output logic rfWrEnable,		// ディスティネーション書き込みを行うかどうか
	output logic isALUInConstant,	// ALU の入力が Constant かどうか
		
	input `InsnPath insn
);
	
	logic isShift;
	
	always_comb begin
		
		op    = insn[ `OP_POS +: `OP_WIDTH      ];
		rs    = insn[ `RS_POS +: `REG_NUM_WIDTH ];
		rt    = insn[ `RT_POS +: `REG_NUM_WIDTH ];
		rd    = insn[ `RD_POS +: `REG_NUM_WIDTH ];
		
		shamt   = insn[ `SHAMT_POS   +: `SHAMT_WIDTH   ];
		funct   = insn[ `FUNCT_POS   +: `FUNCT_WIDTH   ];
		constat = insn[ `CONSTAT_POS +: `CONSTAT_WIDTH ];
		
		isShift = `FALSE;
		
		// ALU function
		if( op == `OP_CODE_ALU ) begin

			// ALU
			case( funct )
			default:			aluCode = `ALU_CODE_SLL;	// FUNCT_CODE_SLL
			`FUNCT_CODE_SRL:	aluCode = `ALU_CODE_SRL;	
			`FUNCT_CODE_ADD:	aluCode = `ALU_CODE_ADD;	
			`FUNCT_CODE_SUB:	aluCode = `ALU_CODE_SUB;
			`FUNCT_CODE_AND:	aluCode = `ALU_CODE_AND;
			`FUNCT_CODE_OR:	    aluCode = `ALU_CODE_OR;
			`FUNCT_CODE_SLT:	aluCode = `ALU_CODE_SLT;
			endcase
			
			if( funct == `FUNCT_CODE_SLL || funct == `FUNCT_CODE_SRL ) begin
				isShift = `TRUE;
			end

		end
		else begin

			// ALU Imm
			case( op )
			default:		aluCode = `ALU_CODE_ADD;	// OP_CODE_ADDI
			`OP_CODE_ANDI:	aluCode = `ALU_CODE_AND;
			`OP_CODE_ORI:	aluCode = `ALU_CODE_OR;
			endcase

		end
		
		// ロード命令かどうか
		case( op )
		`OP_CODE_LD: isLoadInsn = `TRUE;
		default:	 isLoadInsn = `FALSE;
		endcase
		
		// ストア命令かどうか
		case( op )
		`OP_CODE_ST: isStoreInsn = `TRUE;
		default:	 isStoreInsn = `FALSE;
		endcase

		// ディスティネーションがRtかどうか
		case( op )
		`OP_CODE_LD:   isDstRt = `TRUE;
		`OP_CODE_ANDI: isDstRt = `TRUE;
		`OP_CODE_ADDI: isDstRt = `TRUE;
		`OP_CODE_ORI:  isDstRt = `TRUE;
		default:	   isDstRt = `FALSE;
		endcase
		
		// ソースの1個目が Rt かどうか
		isSrcA_Rt = isShift;
		
		// ディスティネーション書き込みを行うかどうか
		case( op )
		`OP_CODE_LD:   rfWrEnable = `TRUE;
		`OP_CODE_ALU:  rfWrEnable = `TRUE;
		`OP_CODE_ANDI: rfWrEnable = `TRUE;
		`OP_CODE_ADDI: rfWrEnable = `TRUE;
		`OP_CODE_ORI:  rfWrEnable = `TRUE;
		default:       rfWrEnable = `FALSE;
		endcase
		
		// ALU の入力が Constant かどうか
		if( isShift ) begin
			isALUInConstant = `TRUE;
		end
		else begin
			case( op )
			`OP_CODE_ALU : isALUInConstant = `FALSE;
			default:	   isALUInConstant = `TRUE;
			endcase
		end

		// Branch
		case( op )
		`OP_CODE_BEQ: brCode = `BR_CODE_EQ;
		`OP_CODE_BNE: brCode = `BR_CODE_NE;
		default:	  brCode = `BR_CODE_UNTAKEN;
		endcase

		// PC write enable
		case( op )
		`OP_CODE_BEQ: pcWrEnable = `TRUE;
		`OP_CODE_BNE: pcWrEnable = `TRUE;
		default:	  pcWrEnable = `FALSE;
		endcase

	end

endmodule
		
		