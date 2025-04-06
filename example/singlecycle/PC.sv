//
// Program Counter
//

import BasicTypes::*;
import Types::*;

module PC(
    input logic clk,    // クロック
    input logic rst,    // リセット

    output InsnAddrPath addrOut,    // アドレス出力

    input InsnAddrPath addrIn,        // 外部書き込みをする時のアドレス
    input logic wrEnable            // 外部書き込み有効
);

    InsnAddrPath pc;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= INSN_RESET_VECTOR;    // リセット
        end
        else if (wrEnable) begin
            pc <= addrIn;                // 書き込み
        end
        else begin
            pc <= pc + INSN_PC_INC;    // PC 更新
        end
    end
    
    // 出力
    assign addrOut = pc;

endmodule
