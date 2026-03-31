# HDL の記述例

このページでは，SystemVerilog による組み合わせ回路や順序回路の記述例を説明します．

## 組み合わせ回路

### 基本的な書き方

組み合わせ回路は，基本的に `always_comb` で定義します．

```systemverilog
always_comb begin
    dst = sel ? a : b;
end
```

### 注意

* `always_comb` 内では `=` を使う
* `<=` は使わない
* 代入されない条件を作らない

代入漏れがあると，ラッチが生成される原因になります．

#### これはよい例

```systemverilog
always_comb begin
    if (sel == 1'b1) begin
        a = 1'b1;
    end
    else begin
        a = 1'b0;
    end
end
```

#### これはよくない例

```systemverilog
always_comb begin
    if (sel == 1'b1) begin
        a = 1'b1;
    end
end
```

### 2:1 マルチプレクサ

#### 3項演算子を使う場合

```systemverilog
always_comb begin
    dst = sel ? a : b;
end
```

#### `if` を使う場合

```systemverilog
always_comb begin
    if (sel == 1'b1) begin
        dst = a;
    end
    else begin
        dst = b;
    end
end
```

### 4:1 マルチプレクサ

#### `if` を使う場合

```systemverilog
always_comb begin
    if (sel == 2'd0) begin
        dst = a;
    end
    else if (sel == 2'd1) begin
        dst = b;
    end
    else if (sel == 2'd2) begin
        dst = c;
    end
    else begin
        dst = d;
    end
end
```

#### `case` を使う場合

```systemverilog
always_comb begin
    case (sel)
        2'd0: dst = a;
        2'd1: dst = b;
        2'd2: dst = c;
        default: dst = d;
    endcase
end
```

複数の代入を書く場合は `begin` / `end` で囲みます．

```systemverilog
always_comb begin
    case (sel)
        default: begin
            a = b;
            c = d;
        end
    endcase
end
```

### `assign` を使う場合

単純な組み合わせ回路なら，`assign` を使っても構いません．

```systemverilog
assign dst = srcA + srcB;
```

短い式なら `assign`，複数の分岐や複数信号の制御があるなら `always_comb` を使うと読みやすくなります．

## 順序回路

### D フリップ・フロップ

フリップ・フロップは，基本的に `always_ff` で定義します．

```systemverilog
always_ff @(posedge clk) begin
    q <= d;
end
```

### 同期リセット付き D フリップ・フロップ

```systemverilog
always_ff @(posedge clk) begin
    if (rst) begin
        q <= '0;
    end
    else begin
        q <= d;
    end
end
```

### 書き込み制御付き D フリップ・フロップ

```systemverilog
always_ff @(posedge clk) begin
    if (rst) begin
        q <= '0;
    end
    else if (wrEnable) begin
        q <= d;
    end
end
```

フリップ・フロップでは，値を保持したいときに `q <= q;` を明示的に書く必要はありません．

### 配列を使ったレジスタ・ファイル

```systemverilog
DataPath storage[0:REG_FILE_SIZE-1];

always_ff @(posedge clk) begin
    if (wrEnable) begin
        storage[wrNum] <= wrData;
    end
end

always_comb begin
    rdDataA = storage[rdNumA];
    rdDataB = storage[rdNumB];
end
```

## 使い分けの目安

* 単純な組み合わせ: `assign`
* 分岐を含む組み合わせ: `always_comb`
* クロック同期の更新: `always_ff`

## よくあるミス

* `always_comb` で代入漏れを作る
* `always_ff` で `=` を使う
* `always_comb` で `<=` を使う
* 幅付きの型を毎回 `logic [n:0]` で直接書いてしまう
* 型や定数を `package` にまとめずに散らす
