//
// 加算器の検証用モジュール
//



// 基本的な型を定義したファイルの読み込み
`include "Types.v" 



// シミュレーションの単位時間の設定
// #~ と書いた場合，この時間が経過する．
`timescale 1ns/1ns


//
// 加算器の検証用のモジュール
//
module H3_Simulator;


	`DataPath adderInA, adderInB; 	// 加算器への入力信号線の定義
	`DataPath adderOut;				// 加算器から出力信号線の定義

	//
	// Adder.v で定義された加算器 Adder の実体を adder と言う名前で定義．
	// 
	Adder adder(
		.dst ( adderOut ), 	// Adder の dst  に adderOut を接続
		.srcA( adderInA ), 	// Adder の srcA に adderInA を接続
		.srcB( adderInB ) 	// Adder の srcB に adderInB を接続 
	);

	//
	// 検証用の信号の入力を記述
	// 
	initial begin       

		//シミュレーション開始
		
		adderInA = 1;	// A に 1 代入
		adderInB = 8;	// B に 8 代入

		#40 			// 40ns 経過させる（40 * 1timescale）

		adderInA = 9;	// A に 9 代入
		adderInB = 6;   // B に 6 代入

		#20 			// 20ns 経過

		$finish;		// シミュレーション終了
		
	end

	//
	// シミュレーション結果の表示
	// inA, inB, Out に変化が生じた場合，$monitor が呼ばれて出力が表示される．
	// 
	initial 
		$monitor(
			$stime, 					// 現在の時間
			" a(%d) + b(%d) = c(%d)", 	// printf と同様の書式設定
			adderInA, 
			adderInB,
			adderOut
		);

endmodule


