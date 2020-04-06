このページでは，作成したプロセッサの性能評価の仕方について説明しています．

*QuartusII上で計測する項目 [#ie1e9772]

計測の前に Processing -> Start Compilation から，合成を行っておいてください．

**動作周波数とクリティカルパスの遅延 [#ncc4d81e]
-Compilation Report内のTimeQuest Timing Analyzer→Slow 1200mV 100C Model→Fmax Summary を見る
--一番遅い周波数を動作周波数とする
--シングルサイクルマシンでは，動作周波数は表示される値の1/4とする
-クリティカルパス遅延は動作周波数の逆数をとる
--クリティカルパスの場所はWorst-Case Timing Pathsを参照

**ロジックエレメントの使用率 [#va446161]
-Compilation Report内のFlow Summary内のTotal logic elemantsを参照

*FPGAボード上で計測する項目 [#n57cf89d]

**実行サイクル数 [#a9d36912]
-ソートが終了してボード上のLED表示が停止した時の値を読み取る
--16進数で表示されるため，電卓などで10進数に変換
--シングルサイクルマシンでは，実行サイクル数は表示された値の1/4とする

*その他の項目 [#e98acc69]

**実行時間 [#f692dfbd]
-実行サイクル数を動作周波数で割る

**プログラムの命令数 [#l91bff96]
-imem.dat あるいは imem.mif に書いた命令数を数える
