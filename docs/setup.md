# 実験の準備

実験で使用するツールやファイルの準備についての説明です．上から順に実行して下さい．

## インストール

現在のリポジトリは，主に Verilator と Vivado を使う構成です．

* 必須
    * git
    * make
    * Verilator
* あると便利
    * GTKWave
* FPGA 合成や実機確認を行う場合
    * Vivado
* エディタ
    * VSCode を使うことを前提に説明します
    * 下記拡張をいれておいてください
        * SystemVerilog - Language Support
        * svls-vscode
* Windows ユーザーの場合
    * WSL2 上で作業するのが無難です
    * GUI ツールを使う場合は，WSLg または各自の X 環境を用意してください

## 環境変数の設定

* `tools/setenv/` に移動
* `set_env.sh` をコピーして自分用の設定ファイルを作成
* 作成したファイルを `source` して環境変数を設定
* 少なくとも以下が通っていることを確認
    * `CPU_EXERCISE_ROOT`
    * `VERILATOR`
    * `VIVADO_BIN` （Vivado を使う場合）

## シミュレーションのテスト

ここまでの設定がうまく行っているかを確認するため，加算器のシミュレーションを行います．

### Verilator で確認する場合

* `tutorial/adder` に移動
* `make` を実行
    * `obj_dir/VAdderSim` が生成されれば OK
* `make sim` を実行
    * シミュレーションが最後まで実行されれば OK
* `make view` を実行
    * `wave.vcd` が生成され，GTKWave で波形を開ければ OK

### Vivado XSim で確認する場合

* `tutorial/adder` に移動
* `make vivado-sim` を実行
    * コンパイルと実行が通れば OK
* GUI で確認したい場合は `make vivado-sim-gui` を実行

## プロセッサのビルド

シングルサイクル CPU のサンプルや演習用ひな形も同様の手順で扱えます．

* 演習用ひな形: `tutorial/processor`
* 参考実装: `example/singlecycle`

各ディレクトリで以下を使います．

* `make`
    * Verilator でビルド
* `make sim`
    * コマンドラインでシミュレーション実行
* `make view`
    * 波形を GTKWave で確認
* `make vivado-sim`
    * XSim でシミュレーション実行
* `make vivado`
    * Vivado プロジェクトを生成して開く

## 補足

* `docs/modelsim.md` と `docs/quartus.md` は旧構成の資料として残しています
* 現行の作業手順では，まず Verilator で検証し，必要に応じて Vivado / XSim と実機確認に進んでください

