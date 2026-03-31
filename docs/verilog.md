# Verilogの記法について

このページでは，この実験で HDL を記述する際に守ってほしいルールを説明します．
現在のリポジトリでは，素の Verilog ではなく **SystemVerilog** を前提にしています．

## 基本方針

この実験では，配布されている `*.sv` の書き方に合わせてください．

* `logic` を使う
* `always_comb` / `always_ff` を使う
* 型や定数は `package` にまとめ，`import ...::*;` で使う
* 配線幅を表す型は `typedef` を使って名前を付ける
* 既存コードと矛盾する古い Verilog 流儀は使わない

**ルールが守られていない場合，レポートは再提出になることがあります．**

## 命名規則

以下を推奨します．既存コードでも，おおむねこの方針になっています．

| 形式 | 用途 |
| -- | -- |
| `ModuleName` | モジュール名 |
| `TypeName` | `typedef` で定義する型名 |
| `signalName` | 信号線，変数，インスタンス名 |
| `CONSTANT_NAME` | `parameter` / `localparam` で定義する定数 |

### 例

```systemverilog
package Types;

parameter REG_NUM_WIDTH = 5;
typedef logic [REG_NUM_WIDTH-1:0] RegNumPath;

endpackage

import Types::*;

module RegisterFile(
    input logic clk,
    input RegNumPath rdNum,
    output logic [31:0] rdData
);

    RegNumPath wrNum;

endmodule
```

### 補足

* 関数名は既存コードに合わせて一貫していればよいです
* たとえば `GET_ADDR` や `ConvertToASCII` のような名前が使われています
* 信号線やモジュール名に日本語ローマ字は使わないでください

## 書式上のルール

* 演算子の前後にはスペースを入れる
* インデントは既存コードに合わせて統一する
* コメントは，モジュールの役割，主要な信号，複雑な処理に対して書く
* 自明な 1 行代入すべてにコメントを付ける必要はありません

## 型と定数

### 型の定義

配線幅を持つ信号は，可能な限り `typedef` で名前を付けた型を使ってください．

```systemverilog
package BasicTypes;

parameter DATA_WIDTH = 32;
typedef logic [DATA_WIDTH-1:0] DataPath;

endpackage
```

### 定数の定義

意味のある固定値は，`parameter` または `localparam` で名前を付けてください．

```systemverilog
parameter OPCODE_LOAD = 7'b0000011;
parameter INSN_PC_INC = 4;
```

### 生の値について

意味の分からないマジックナンバーは避けてください．
ただし，以下のような短いリテラルは使って構いません．

* `1'b0`, `1'b1`
* `'0`
* 命令符号化のビット列
* 連結や符号拡張のための短い定数

## `package` と `import`

現在のコードでは，型や定数を `package` にまとめています．
配布コードでは主に `BasicTypes.sv` と `Types.sv` を使っています．

```systemverilog
import BasicTypes::*;
import Types::*;
```

新しい型や定数を追加する場合は，意味に応じてこれらの `package` に追加してください．

## `logic`

この実験では `wire` / `reg` の使い分けは行わず，基本的に `logic` を使ってください．

```systemverilog
logic [31:0] data;
logic wrEnable;
```

ただし，多ビットのデータ線は，できるだけ `typedef` した型で書いてください．

```systemverilog
DataPath data;
```

## `always_comb` と `always_ff`

### 組み合わせ回路

組み合わせ回路は `always_comb` で書きます．

```systemverilog
always_comb begin
    dst = sel ? a : b;
end
```

* `always_comb` の中ではブロッキング代入 `=` を使う
* 代入されない条件を作らない
* `if` なら `else`，`case` なら `default` を基本的に付ける

### 順序回路

フリップ・フロップは `always_ff` で書きます．

```systemverilog
always_ff @(posedge clk) begin
    q <= d;
end
```

* `always_ff` の中ではノンブロッキング代入 `<=` を使う
* クロック同期回路は `always_ff` にまとめる

## モジュールの入出力

SystemVerilog では，モジュールのポートを宣言部でそのまま定義できます．

```systemverilog
module CPU(
    input logic clk,
    input logic rst,
    output DataPath dataOut
);
endmodule
```

型付きのポート宣言を使い，同じ名前を二度書く古い Verilog 形式は使わないでください．

## 推奨事項

* 1ファイル1モジュールを基本とする
* モジュール冒頭で必要な `import` を明示する
* 主要な信号群ごとに短いコメントを付ける
* 既存コードの命名やレイアウトをなるべく揃える

## 現行コードに合わせる際の注意

過去資料には，`define` を中心にした説明や `.v` 前提の説明が残っている場合があります．
現在は以下を優先してください．

* ファイル拡張子は `*.sv`
* 型は `typedef`
* 定数は `parameter` / `localparam`
* 共通定義は `package`
* ポート定義は SystemVerilog 形式
