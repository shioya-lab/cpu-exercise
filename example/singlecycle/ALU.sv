//
// ALU
//

import BasicTypes::*;
import Types::*;

module ALU(
    output DataPath aluOut,
    
    input DataPath aluInA,
    input DataPath aluInB,
    input ALUCodePath code,
    input logic[6:0] funct7
);

    always_comb begin

        aluOut = '0;
        case ( code )
        ALU_CODE_ADD_SUB: 
            aluOut = aluInA + aluInB;

        ALU_CODE_SLL:
            aluOut = aluInA << GET_SHIFT( aluInB );
        ALU_CODE_SLT:
            aluOut[0] = aluInA < aluInB ? TRUE: FALSE;

        ALU_CODE_SLTU:
            aluOut[0] = $unsigned(aluInA) < $unsigned(aluInB) ? TRUE: FALSE;

        ALU_CODE_XOR:
            aluOut = aluInA ^ aluInB;

        ALU_CODE_SRL_SRA: begin
            if (funct7 == SHIFT_FUNCT7_SRA) begin
                aluOut = aluInA >>> GET_SHIFT( aluInB );
            end
            else if (funct7 == SHIFT_FUNCT7_SRL) begin
                aluOut = aluInA >> GET_SHIFT( aluInB );
            end
            else begin
                aluOut = 32'hcdcdcdcd;
            end
        end
        ALU_CODE_OR:
            aluOut = aluInA | aluInB;

        ALU_CODE_AND:
            aluOut = aluInA & aluInB;

        endcase
    end

endmodule
        
        