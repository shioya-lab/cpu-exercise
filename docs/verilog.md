このページでは Verilog を記述する際に守って欲しいルールや，通常の Verilog とは異なる点について説明します．

*基本的なルール [#n583ac53]
この実験で記述する Verilog では，以下のルールを守って記述してください．

チュートリアルなどで用意されているファイルがこのルールに従っていない場合，こっちのルールを優先して書き換えてください．

''ルールが守られていない場合，レポートは再提出になることがあります．''
**モジュールや信号線の名前の付け方 [#ta3c6a6f]

:ModuleName | モジュール名は大文字と小文字を組み合わせて使用し，1文字目を大文字にする．
:TypeName | typedefや`defineによる型定義では，大文字と小文字を組み合わせて使用し，1文字目を大文字にする．
:RoutineName | Function，Taskには大文字と小文字を組み合わせて使用し，1文字目を大文字にする．

:localVariable | ローカルの配線やFFには大文字と小文字を組み合わせて使用し，1文字目を小文字にする．
:CONSTANT_VALUE | 名前付き定数は全て大文字．
:PREFIX_ENUMERATED_TYPE | 列挙子については，定数と同じく大文字．ただし，先頭にデータ型を表すプレフィックスをつける．列挙型全体を表す型はTypeName に準じる


***例 [#g85e5d86]


	// データ幅は16bit
	`define DATA_WIDTH 16
	
	// データパス
	`define DataPath logic [ `DATA_WIDTH-1:0 ]
	
	// Adder
	module Adder( input `DataPath adderIn );
	`DataPath adderTmp; // 先ほど定義した `DataPath を使用
	...
	endmodule
	
	// Adder の実体
	Adder adder( adderIn );

**スペースの入れ方とか名前の規則 [#g6ddb94b]
-演算子（=-とかそう言うの）と，信号線の間は必ずスペースを入れる
-括弧()との間にも入れる
-信号線やモジュールの名前には，日本語ローマ字を使わない
-同じ物が2つある場合でも，～1，～2という名前は使わない
-コメントは必ず書くこと

**その他のルール [#h3c4d19d]
-logic を使う．wire/reg の使用は禁止．
-always_comb/always_ff を使う．always は使用禁止．
-各ファイルは基本的には module を一つのみ実装する．
-生の値の使用禁止
--必ず定数として意味のある名前を定義してから使用する
-生の型（logic [5:0]とか）の使用禁止
--必ず define で意味のある名前を定義してから使用する
--ただし，真偽を表すために 1bit の logic を使うのはよい．
-定数や型は Types.v の中で定義すること

これを守ると，Types.v の中以外では logic はほとんど現れない事になります．


*通常の Verilog との違い [#d15d6a37]

この実験では，素の Verilog ではなく，一部 ''System Verilog'' の構文を使用します．
（本当は全面的に System Verilog で書きたいのですが，開発環境の制限により使えません･･･）
以下では，この実験で使用している System Verilog 固有の構文をまとめます．

** logic [#d22ada54]
Verilog では状況に応じて wire と reg を使い分ける必要がありましたが，System Verilog では logic で統一的に記述できます．

 // Verilog
 wire [1:0] w;
 reg  [1:0] r;

 // System Verilog
 logic [1:0] l; // 使い分ける必要はない

** always_comb, always_ff [#ydd14f67]
Verilog では組み合わせ回路や順序回路の双方を always 文で書きます．これに対し，System Verilog では組み合わせ回路には always_comb，フリップ・フロップには always_ff と言う専用の構文が用意されています．これにより，組み合わせ回路のつもりが，意図せずフリップ・フロップやラッチになってしまうミスを未然に防げます．

また，Verilog では always 節にはセンシティビティ・リストと呼ばれる変化に対応する必要がある信号のリストを書かなければいけませんでした．これに対し，System Verilog ではフリップ・フロップでクロック同期の指定に使う以外ではセンシティビティ・リストは必要ありません．

 // System Verilog
 always_comb begin
 ...
 end

 always_ff @( posedge clk ) begin // クロック立ち上がりに同期したFF
 ...
 end
 
** module の入出力の定義 [#j32cca87]

Verilog では module の入出力を定義する際，同じ信号線名を2書かなければなりませんでしたが， System Verilog では一度ですみます．また，System Verilog では module の入出力に配列が使えます．

 // Verilog 
 module ( signal )
     input wire [1:0] signal;
     ...
 endmodule

 // System Verilog
 module ( input wire [1:0] signal )
     ...
 endmodule
