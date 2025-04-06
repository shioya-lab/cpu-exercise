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
        
    end
    
    // 出力
    assign addrOut = pc;

endmodule
