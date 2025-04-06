//
// ブランチ関係
//

import BasicTypes::*;
import Types::*;

module BranchUnit(
    output logic brTaken,

    input BrCodePath    brCode,
    input DataPath     rs1,
    input DataPath     rs2
);

    always_comb begin

        case (brCode)
        BR_CODE_EQ:    brTaken = (rs1 == rs2) ? TRUE : FALSE;
        BR_CODE_NE:    brTaken = (rs1 != rs2) ? TRUE : FALSE;
        BR_CODE_LT:    brTaken = (rs1 < rs2) ? TRUE : FALSE;
        BR_CODE_GE:    brTaken = (rs1 >= rs2) ? TRUE : FALSE;
        BR_CODE_LTU:   brTaken = ($unsigned(rs1) < $unsigned(rs2)) ? TRUE : FALSE;
        BR_CODE_GEU:   brTaken = ($unsigned(rs1) >= $unsigned(rs2)) ? TRUE : FALSE;
        default:       brTaken = FALSE;
        endcase

    end

endmodule
