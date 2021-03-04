//
// 16ビット加算器
//


// 基本的な型を定義したファイルの読み込み
`include "Types.v" 


module Adder( 			// モジュールの宣言 
	output
		`DataPath dst,	// 出力線の宣言
						// `DataPath は Types.v 内で定義されたマクロであり，
						// logic [15:0] に展開される．
	input
		`DataPath srcA,
		`DataPath srcB	// 入力線の宣言
);      

	// 加算
   assign dst = srcA + srcB;  

endmodule				// モジュールの終了

