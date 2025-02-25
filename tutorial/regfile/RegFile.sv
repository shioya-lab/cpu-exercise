//
// 2 Read / 1 Write レジスタ・ファイル
//


// 基本的な型を定義したファイルの読み込み
import Types::*;


module RegisterFile(
	input logic clk,			// クロック
	
	output DataPath rdDataA,	// 読み出しデータA
	output DataPath rdDataB,	// 読み出しデータB
	

	input RegNumPath rdNumA,	// 読み出しレジスタ番号A
	input RegNumPath rdNumB,	// 読み出しレジスタ番号B

	input DataPath   wrData,	// 書き込みデータ
	input RegNumPath wrNum,	// 書き込みレジスタ番号
	input logic       wrEnable	// 書き込み制御 1の場合，書き込みを行う
);

	// 実際に値が入るストレージ
	// DataPath の配列（サイズ：REG_FILE_SIZE）
	DataPath storage[ REG_FILE_SIZE ]; 


	// 書き込みと，レジスタ・ファイルの実現
	// クロックの立ち上がりによって書き込みが行われる と言う動作を書くことで，
	// コンパイラはこれを順序回路だと解釈する．
	always_ff @( posedge clk ) begin
		if( wrEnable ) begin			// 書き込み制御
			storage[ wrNum ] <= wrData;	// 順序回路では，ノンブロッキング代入で
		end
	end

	// 読み出し
	assign rdDataA = storage[ rdNumA ];
	assign rdDataB = storage[ rdNumB ];

endmodule

