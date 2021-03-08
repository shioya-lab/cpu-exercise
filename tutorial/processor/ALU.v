`include "Types.v"

module ALU(
    output `DataPath aluOut,

    input `DataPath aluInA,
    input `DataPath aluInB,
    input `ALUCodePath code
);

    always_comb begin
        case (code)
        `ALU_CODE_SLL:
            aluOut = aluInA << `GET_SHIFT(aluInB);
        `ALU_CODE_SRL:
            aluOut = aluInB >> `GET_SHIFT(aluInB);
        `ALU_CODE_ADD:
            aluout = aluInA + aluInB;
        `ALU_CODE_SUB:
            aluout = aluInA - aluInB;
        `ALU_CODE_AND:
            aluout = aluInA & aluInB;
        `ALU_CODE_OR:
            aluout = aluInA | aluInB;
        `ALU_CODE_XOR:
            aluOut = aluInA ^ aluInB;
        `ALU_CODE_SLT:
            aluout = aluInA < aluInB ? `TRUE : `FALSE;

end module