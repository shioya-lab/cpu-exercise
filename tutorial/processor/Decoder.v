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
    output logic pcScr,
    output logic regDst,
    output logic regWrite,
    output logic aluSrc,
    output logic memWrite,
    output logic isSrcA_Rt,
    output logic memRead,
    input `InsnPath insn,
);

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
                `FUNCT_CODE_SLT     aluCode = `ALU_CODE_SLT;
                `FUNCT_CODE_SRL     aluCode = `ALU_CODE_SRL;
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
            `OP_CODE_LD: memRead = `TRUE;
            default: memRead = `FALSE;
        endcase

        case (op)
            `OP_CODE_ST: memWrite = `TRUE;
            default: memWrite = `FALSE;
        endcase

        case(op)
            `OP_CODE_LD:    regDst = `TRUE;
            `OP_CODE_ADDI:  regDst = `TRUE;
            `OP_CODE_ANDI:  regDst = `TRUE;
            `OP_CODE_ORI:   regDst = `TRUE;
            default:    regDst = `FALSE;
        endcase

        case(op)
            `OP_CODE_LD:    regWrite = `TRUE;
            `OP_CODE_ALU:   regWrite = `TRUE;
            `OP_CODE_ANDI:  regWrite = `TRUE;
            `OP_CODE_ORI:   regWrite = `TRUE;
            `OP_CODE_ADDI:  regWrite = `TRUE;
            default:    regWrite = `FALSE;
        endcase

        isSrcA_Rt = isShift;

        if(isShift) begin
            aluSrc = `TRUE;
        end
        else begin
            case(op):
                `OP_CODE_ALU: aluSrc = `FALSE;
                default:    aluSrc = `TRUE;
            endcase
        end

        case(op)
            `OP_CODE_BEQ: pcScr = `TRUE;
            `OP_CODE_BNE: pcScr = `TRUE;
            default: pcScr= `FALSE;
        endcase
    end
endmodule