# 実験の準備

実験で使用するツールやファイルの準備についての説明です．上から順に実行して下さい．

## インストール

* Modelsim フリー版をインストール
    * https://www.intel.co.jp/content/www/jp/ja/software/programmable/quartus-prime/model-sim.html
    * リンクを進んで「個別ファイル」のところの Intel FPGA Edition のところにある
    * アドレスは割とコロコロかわるので，そこにない場合はググって探してください
* Windows ユーザーの場合
    * cygwin を導入しておいてください
    * WSL でも大丈夫かもしれませんが，試してないです
        * GUI の起動などにおいて問題が起きるかもしれません
* 共通
    * git, make が必要ですので，インストールしておいてください
    * エディタとしては VSCode を使うことを前提に説明します．
        * 下記拡張をいれておいてください
            * SystemVerilog - Language Support
            * svls-vscode
* 環境変数の設定
    * tools/setenv/ に移動し，SetEnv.bat/SetEnv.sh を使用して環境変数を設定



## シミュレーションのテスト

ここまでの設定がうまく行っているかを確認するため，加算器のシミュレーションを行ってみます．

* tutorial/adder に移動
* make と打って Enter を押す．
    * 下のように出ればOK
        ```
        Model Technology ModelSim ALTERA vlog 6.6d Compiler 2010.11 Nov  2 2010
        -- Compiling module Adder
        -- Compiling module H3_Simulator

        Top level modules:
                H3_Simulator
        ```
* make sim-gui と打って Enter を押す．
    * シミュレータが立ち上がり，シミュレータ内の下の方に以下のように加算の結果が出ていればOK
        ```
            #  run 50ns 
            #          0 a(    1) *  b(    8) = c(    9)
            #         40 a(    9) *  b(    6) = c(   15)
        ```

