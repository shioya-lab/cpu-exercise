//
// ALU
//

import BasicTypes::*;
import Types::*;

module ALU(
    output DataPath aluOut,
    
    input DataPath aluInA,
    input DataPath aluInB,
    input ALUCodePath code
);

    always_comb begin

        aluOut = {DATA_WIDTH{1'b0}};
        case ( code )
        ALU_CODE_SLL:    // ALU_CODE_SLL:
            aluOut = aluInA << GET_SHIFT( aluInB );

        ALU_CODE_SRL:    // ALU_CODE_SRL:
            aluOut = aluInA >> GET_SHIFT( aluInB );

        ALU_CODE_ADD:    // ALU_CODE_ADD:
            aluOut = aluInA + aluInB;

        ALU_CODE_SUB:
            aluOut = aluInA - aluInB;

        ALU_CODE_OR:
            aluOut = aluInA | aluInB;

        ALU_CODE_XOR:
            aluOut = aluInA ^ aluInB;

        ALU_CODE_AND:
            aluOut = aluInA & aluInB;

        ALU_CODE_SLT:
            aluOut[0] = aluInA < aluInB ? TRUE : FALSE;
        endcase
    end

endmodule
        
        