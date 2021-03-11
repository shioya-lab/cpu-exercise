`include "Types.v"

module Decoder(
    output `OpPath op,
    output `RegNumPath rs,
    output `RegNumPath rt,
    output `RegNumPath rd,
    output `ShamtPath shamt,
    output `FunctPath funct,
    output `ConstantPath constant,
    output `ALUCodePath aluCode,
    output `BrCodePath brCode,
    output logic pcWrEnable,
    output logic isLoadInsn,
    output logic isStoreInsn,
    output logic isSrcA_Rt,
    output logic isDstRt,
    output logic rfWrEnable,
    output logic isALUInConstant,
    input `InsnPath insn
);

    logic isShift;

    always_comb begin
        op = insn[ `OP_POS +: `OP_WIDTH ];
        rs = insn[ `RS_POS +: `REG_NUM_WIDTH ];
        rt = insn[ `RT_POS +: `REG_NUM_WIDTH ];
        rd = insn[ `RD_POS +: `REG_NUM_WIDTH ];

        shamt = insn[ `SHAMT_POS +: `SHAMT_WIDTH ];
        funct = insn[ `FUNCT_POS +: `FUNCT_WIDTH ];
        constant = insn[ `CONSTANT_POS +: `CONSTANT_WIDTH ];

        isShift = `FALSE;

        if( op == `OP_CODE_ALU ) begin
            case(funct)
                `FUNCT_CODE_ADD:    aluCode = `ALU_CODE_ADD;
                `FUNCT_CODE_SUB:    aluCode = `ALU_CODE_SUB;
                `FUNCT_CODE_AND:    aluCode = `ALU_CODE_AND;
                `FUNCT_CODE_OR:     aluCode = `ALU_CODE_OR;
                `FUNCT_CODE_SLT:     aluCode = `ALU_CODE_SLT;
                `FUNCT_CODE_SRL:     aluCode = `ALU_CODE_SRL;
                `FUNCT_CODE_XOR:     aluCode = `ALU_CODE_XOR;
                default:    aluCode = `ALU_CODE_SLL;
            endcase

            if (funct == `FUNCT_CODE_SLL || funct == `FUNCT_CODE_SRL) begin
                isShift = `TRUE;
            end
        end
        else begin
            case(op)
                `OP_CODE_ADDI: aluCode = `ALU_CODE_ADD;
                `OP_CODE_ANDI: aluCode = `ALU_CODE_AND;
                default: aluCode = `ALU_CODE_OR;
            endcase
        end

        case (op)
            `OP_CODE_LD: isLoadInsn = `TRUE;
            default: isLoadInsn = `FALSE;
        endcase

        case (op)
            `OP_CODE_ST: isStoreInsn = `TRUE;
            default: isStoreInsn = `FALSE;
        endcase

        case(op)
            `OP_CODE_LD:    isDstRt = `TRUE;
            `OP_CODE_ADDI:  isDstRt = `TRUE;
            `OP_CODE_ANDI:  isDstRt = `TRUE;
            `OP_CODE_ORI:   isDstRt = `TRUE;
            default:    isDstRt = `FALSE;
        endcase

        case(op)
            `OP_CODE_LD:    rfWrEnable = `TRUE;
            `OP_CODE_ALU:   rfWrEnable = `TRUE;
            `OP_CODE_ANDI:  rfWrEnable = `TRUE;
            `OP_CODE_ORI:   rfWrEnable = `TRUE;
            `OP_CODE_ADDI:  rfWrEnable = `TRUE;
            default:    rfWrEnable = `FALSE;
        endcase

        isSrcA_Rt = isShift;

        if(isShift) begin
            isALUInConstant = `TRUE;
        end
        else begin
            case(op)
                `OP_CODE_ALU: isALUInConstant = `FALSE;
                default:    isALUInConstant = `TRUE;
            endcase
        end

        case(op)
            `OP_CODE_BEQ:   brCode = `BR_CODE_EQ;
            `OP_CODE_BNE:   brCode = `BR_CODE_NE;
            default:    brCode = `BR_CODE_UNTAKEN;
        endcase

        case(op)
            `OP_CODE_BEQ: pcWrEnable = `TRUE;
            `OP_CODE_BNE: pcWrEnable = `TRUE;
            default: pcWrEnable= `FALSE;
        endcase
    end
endmodule