//
// デコード・ユニット
//

import BasicTypes::*;
import Types::*;

module Decoder(
    output OpInfo opinfo,
    input InsnPath insn
);
        
    always_comb begin

        opinfo = '0;
        // Cutting out bit fields from instructions
        opinfo.opcode   = insn[OPCODE_POS +: OPCODE_WIDTH];
        opinfo.rd       = insn[RD_POS +: REG_NUM_WIDTH];
        opinfo.rs1      = insn[RS1_POS +: REG_NUM_WIDTH];
        opinfo.rs2      = insn[RS2_POS +: REG_NUM_WIDTH];
        opinfo.funct3   = insn[FUNCT3_POS +: FUNCT3_WIDTH];
        opinfo.funct7   = insn[FUNCT7_POS +: FUNCT7_WIDTH];
        opinfo.constant = '0;
        
        // Switch by opcode
        case (opinfo.opcode)
        OPCODE_OP: begin
            opinfo.regWrEnable = TRUE;
        end
        OPCODE_OP_IMM: begin
            opinfo.rs2 = '0;
            opinfo.constant[31:12] = {20{insn[31]}};
            opinfo.constant[11:0]  = insn[31:20];
            opinfo.isALUInConstant = TRUE;
            opinfo.regWrEnable     = TRUE;
        end
        OPCODE_AUIPC, OPCODE_LUI: begin
            opinfo.rs1 = '0;
            opinfo.rs2 = '0;
            opinfo.constant[31:12] = insn[31:12];
            opinfo.isALUInConstant = TRUE;
            opinfo.regWrEnable     = TRUE;
        end
        OPCODE_LOAD: begin
            opinfo.rs2 = '0;
            opinfo.constant[31:12] = {20{insn[31]}};
            opinfo.constant[11:0]  = insn[31:20];
            opinfo.isLoad          = TRUE;
            opinfo.isALUInConstant = TRUE;
            opinfo.regWrEnable     = TRUE;
        end
        OPCODE_STORE: begin
            opinfo.rd = '0;
            opinfo.constant[31:12] = {20{insn[31]}};
            opinfo.constant[11:5]  = insn[31:25];
            opinfo.constant[4:0]   = insn[11:7];
            opinfo.isStore         = TRUE;
            opinfo.isALUInConstant = TRUE;
        end
        OPCODE_BRANCH: begin
            opinfo.rd = '0;
            opinfo.constant[31:12] = {20{insn[31]}};
            opinfo.constant[10:5]  = insn[30:25];
            opinfo.constant[4:1]   = insn[11:8];
            opinfo.constant[11]    = insn[7];
            opinfo.isBranch        = TRUE;
        end
        OPCODE_JALR: begin
            opinfo.rs2 = '0;
            opinfo.constant[31:12] = {20{insn[31]}};
            opinfo.constant[11:0]  = insn[31:20];
            opinfo.isJump          = TRUE;
            opinfo.isALUInConstant = TRUE;
            opinfo.regWrEnable     = TRUE;
        end
        OPCODE_JAL: begin
            opinfo.rs1             = '0;
            opinfo.rs2             = '0;
            opinfo.constant[31:21] = {11{insn[31]}};
            opinfo.constant[20]    = insn[31];
            opinfo.constant[10:1]  = insn[30:21];
            opinfo.constant[11]    = insn[20];
            opinfo.constant[19:12] = insn[19:12];
            opinfo.isJump          = TRUE;
            opinfo.isALUInConstant = TRUE;
            opinfo.regWrEnable     = TRUE;
        end
        default: begin
            opinfo.rd = '0;
            opinfo.rs1 = '0;
            opinfo.rs2 = '0;
        end
        endcase
    end

endmodule
        
        