//
// 16ビット減算器
//


// 基本的な型を定義したファイルの読み込み
`include "Types.v" 


module Subtractor(
    output
        `DataPath dst,
    input
        `DataPath srcA,
        `DataPath srcB
);      
    assign dst = srcA - srcB;

endmodule

