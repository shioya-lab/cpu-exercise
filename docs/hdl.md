
# HDL の記述例
このページでは，System Verilog による組み合わせ回路や記憶素子の記述例について説明します．

## 組み合わせ回路

### 基本的な書き方

組み合わせ回路は，基本的に always_comb 内で定義します．
```
always_comb begin
    dst = sel ? a : b;
end
```

#### 注意
* always_comb 内では"="（ブロッキング代入）のみを使用し，"<="（ノンブロッキング代入）は使用しないでください．
* always_comb 内で代入を行う場合，代入されない状態を作らないでください
* 特定の条件の時に代入されない → その場合，信号が変化しない → 信号を記憶しなければ と解釈されて，ラッチが生成されてしまいます
  * これはOK
      ```
      if( sel == 1 ) begin
          a = 1;
      end
      else begin
          a = 0;
      end
      ```
  * これは絶対だめ
      ```
      if( sel == 1 ) begin
          a = 1;
      end
      // sel が 1じゃない場合，aが代入されない
      ```
  * 対策：
    * if を書くときは必ず else を，case を書くときは 必ず defulat 節をつくる
    * あるいは，全ての信号に先頭で必ず代入を行うようにするか

### 2:1 マルチプレクサ

#### 3項演算子を使った書きかた
```
always_comb begin
    dst = sel ? a : b;
end
```

#### if 節を使った書きかた
```
always_comb begin
    if( sel == 1 ) begin
        dst = a;
    end
    else begin
        dst = b;
    end
end
```
 
### 4:1 マルチプレクサ

#### if 節を使った書きかた
```
always_comb begin
    if( sel == 0 ) begin
        dst = a;
    end
    else if( sel == 1 ) begin
        dst = b;
    end
    else if( sel == 2 ) begin
        dst = c;
    end
    else begin
        dst = d;
    end
end
```

#### case 節を使った書きかた
```
always_comb begin
    case( sel )
    0:  
        dst = a;
    1: 
        dst = b;
    2:
        dst = c;
    default:	// 必ず全ての場合に dst に値が代入されるようにすること
        dst = d;
    endcase
end
```
 
case の 各節に複数の代入を起きたい場合，begin と end で囲えばよいです
```
default:
begin
    a = b;
    c = d;
end
```
 

## 記憶素子

### Dフリップ・フロップ

* Dフリップ・フロップは，基本的に always_ff 内で定義します．
* "="ではなく，"<="を使ってください
    * 組み合わせ回路の場合とは逆なので注意！
```
always_ff @( posedge clk ) begin
    q <= d;
end
```

#### 非同期リセット付きDフリップ・フロップ

```
logic q;
always_ff @( posedge clk or negedge rst ) begin	
    // クロックの立ち上がりに同期
    // リセット信号が立ち下がった場合，即座にリセット
    if( !rst ) begin
        q <= 1'b0;
    end
    else begin
        q <= d;
    end
end
```
     
#### 書き込み制御付き非同期リセットDフリップ・フロップ

```
logic q;
always_ff @( posedge clk or negedge rst ) begin

    // クロックの立ち上がりに同期
    // リセット信号が立ち下がった場合，即座にリセット
    
    if( !rst ) begin
        q <= 1'b0;  // リセット
    end
    else if( wr != 0 ) begin
        q <= d;	// d を書き込む
    else begin
        q <= q;	// 変わらない
    end
end
```