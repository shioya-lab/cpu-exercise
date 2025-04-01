//
// ブランチ関係
//

import BasicTypes::*;
import Types::*;

module BranchUnit(
    output InsnAddrPath pcOut,
    output logic brTaken,

    input InsnAddrPath pcIn,
    input BrCodePath    brCode,
    input DataPath     rs1,
    input DataPath     rs2,
    input ConstantPath constant
);

    InsnAddrPath disp;

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
        
        disp = EXPAND_BR_DISPLACEMENT( constant );
        pcOut = pcIn + disp;
    end

endmodule

