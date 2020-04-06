
# QuartusII

## プロジェクトの設定
基本的には既存プロジェクトを開く方でよい
### 既存プロジェクトを開く場合
* QuartusII ディレクトリ内の *.qpf ファイルを開く
* AssignMents -> Settings -> Files
* 自分の作ったHDLファイルをAdd
    * Simulation用のHDLファイルは追加しないこと
### 新規プロジェクトの作成する場合
下記から行う
File -> New Project Wizard
1. Introduction
    * Next
1. Directory, Name, Top-Level Entitiy
    * プロジェクトを保存するディレクトリ，プロジェクト名等を設定
        * Top-Level Entitiyについてよくわからない人はプロジェクト名もTop-Level Entity名もMainにすること
1. Add Files
    * 使用するHDLファイルを追加
        * ファイル名を指定してAdd
1. Family & Device Settings
    * 使用するFPGAの型番指定
        1. familyをCyclone IV Eに変更
        1. Available devices: の中から EP4CE30F23I7 を選択
        1. 選択後はNextではなくFinish 

## コンパイルする際の言語の切り替え
下記から行う
 AssignMents -> Settings -> Analysys & Synthesis Settings -> Verilog HDL Input
* SystemVerilog-2005にチェック

## シミュレーションのやり方
コンパイル後にソース・コードの保存してあるファイルのパスを変更した場合は，
QuartusIIフォルダを削除し，オリジナルのQuartusIIのフォルダを持ってきて再設定すること
###  1. 設定
1. Assignments->Settings
    1. 左のツールツリーから "Simulation"を開く
    1. Tool Name を ModelSim-Altera に変更
    1. Format for output netlist を SystemVerilog HDL に変更
    1. Output directoryを ../QuartusSim に変更
    1. More EDaNetlist Writter Settings をクリック
        * Maintain hierarchy を On にし，他をOFFにしてOK
    1. Compile test bench を選択しTestBenches をクリック
        1. New
        1. Test bench name を H3_MainSim に変更
        1. Test bench and simulation files に MainSim.v を追加
        1. 下の枠に追加されたMainSim.vを選択し Properties
        1. HDL Version を SystemVerilog_2005
    1. OKをクリックしてSettingsのウィンドウを閉じる
###  2. 命令メモリのコピー
1. QuartusII上でFile->Open　から imem.mif を開く
1. サクラエディタ上で imem.dat  を開きコピー
1. imem.mifの先頭にペーストし保存
###  3.コンパイル&合成
1. Processing -> Start Compilation
    * エラーが出たら修正し，警告は極力つぶすこと
###  4.シミュレーションの実行
1. Tool->Run Simulatiron Tool->Gate Level Simulation
1. モデルは初期のものでOK
    * Errorが出た場合はMainSim.v内のレジスタの初期化部分をコメントアウト
    * ModelSimが立ち上がりシミュレーションが開始される
    * 線の名前がゲートレベルに変更されているため，見たい線はMainSim.vの中に持ってくること

## ボードへのダウンロードの仕方
コンパイル後にソース・コードの保存してあるファイルのパスを変更した場合は，
QuartusIIフォルダを削除し，オリジナルのQuartusIIのフォルダを持ってきて再設定すること
### 1. 準備
* ボードを電源につなぐ
* Terasic Blaster から出ている USB ケーブルを PC に指す

###  2. 命令メモリのコピー
1. QuartusII上でFile->Open　から imem.mif を開く
1. サクラエディタ上で imem.dat  を開きコピー
1. imem.mifの先頭にペーストし保存

### 3. 合成

Processing -> Start Compilation から，合成を行っておいてください．

この時，極力警告は全部潰すこと．

#### ロジック使用率の確認
* Compilation Report内のFlow Summary内のTotal logic elemantsを参照

#### サイクル時間とクリティカルパスの確認
* Compilation Report内のTimeQuest Timing Analyzer→Slow 1200mV 100C Model→Fmax Summary
    * 一番遅い周波数から求めること
* クリティカルパスの場所はWorst-Case Timing Pathsを参照


### 4. ピン接続の確認

1.  Assignments -> AssignmentEditor を開く
1.  Main の出力に適切なピンが繋がっていることを確認
1.  Toの列で「?」となっている行がないことを確認
    1.  Mainモジュールの入出力線名を変更すると?になるようです．

### 5. ダウンロード
1. Tools -> Programmer を開く
1. 左上にある Hardware Setup ボタンを押す
    1. Currently selected hardware が USB blaster になるように選択
1.  Main.sof が表示されていることを確認
    1. 表示されていなかった場合，左側にある Add Files ボタンから追加
    1. 「../../../../Main.sof」のように表示されていたら，左側にある Delete ボタンから削除し，再度Main.sofを選択する．その後「Main.sof」と表示されていることを確認する．
1. それぞれの Program/Configure のチェックボックスにチェックをつける
1. 左側の Start ボタンを押す
1. 右上の Progress バーが100になったらダウンロード完了


### 6. 実行

1. リセットボタンを押す
    * ICがたくさんついている側のRESETと書かれているスイッチ
1. ソート開始用のスイッチを押す
    * プッシュスイッチがたくさんある部分のSW22
1. ソート完了後にデータの確認を行う
    * プッシュスイッチがたくさんある部分のSW23を押すと7segLEDにアドレスとデータが表示される

* ボードに入力されるクロックについて
    * ブザー横のロータリスイッチで入力クロックの速度が変更可能
        * 0が最速でEが自動クロックの最遅
        * Fの場合は手動クロックでブザーのそばのCLKSWを押すと1サイクル経過
* 再実行したい場合はダウンロードから再実行
