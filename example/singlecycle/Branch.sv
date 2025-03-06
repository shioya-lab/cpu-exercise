//
// ブランチ関係
//

import BasicTypes::*;
import Types::*;


module BranchUnit(
    output InsnAddrPath pcOut,
        
    input InsnAddrPath pcIn,
    input BrCodePath    brCode,
    input DataPath     rs1,
    input DataPath     rs2,
    input ConstantPath constant
);
    
    logic brTaken;
    InsnAddrPath disp;
    
    always_comb begin

        case( brCode )
        BR_CODE_EQ:    brTaken =  (rs1 == rs2) ? TRUE : FALSE;
        BR_CODE_NE:    brTaken =  (rs1 != rs2) ? TRUE : FALSE;
        default:       brTaken = FALSE;
        endcase
        
        disp = EXPAND_BR_DISPLACEMENT( constant );
        pcOut =
            pcIn + INSN_PC_INC + (brTaken ? disp : {INSN_ADDR_WIDTH{1'b0}});
    end

endmodule

