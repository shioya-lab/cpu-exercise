
# アセンブルについて

アセンブリ言語から CPU が直接理解できるバイナリ・コード（数値の列）に変換することをアセンブルすると言います．

アセンブルを行う主なやり方としては，以下の様な方法があります．

+ 気合で手で計算する
+ エクセルを使う
+ アセンブラを作る

下に行くほど準備が大変ですが，1回準備が出来てしまえばあとは圧倒的に楽です．このページでは各方法について簡単に説明します．

## 気合で計算する

最も簡単ですが非常にめんどくさいです．また，どうしても変換時にミスが入る可能性が高いです．もし計算ミスで正しいバイナリ・コードが生成されていなかった場合，かなりわかりにくいバグの元となります．

なので，一番最初に簡単なコードの動作確認を行う場合はこれでも良いですが，後々を考えると全て手で計算するのはおすすめできません．

## エクセルを使う

各行を1命令として，各列のセルにレジスタ番号や op コード，命令のタイプなどを入力し，それらの数値から各命令のバイナリを生成する式を入力して，エクセルに計算させます．

この方法は，ミスが入りにくいと言う点で，手で計算するよりはかなりましです．



## アセンブラを作る

一番まともで，できあがってしまえば楽ですが，アセンブラを作るまでがちょっと大変です．
以下にひな形になるような C言語のコードを示します．チャレンジしてみる人は，このひながたを参考にするなどしてみてください．

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// 文字列の最大サイズ
#define MAX_STRING_SIZE 256

// 真/偽を表す定数
#define TRUE    1
#define FALSE   0

// GetToken で得られたトークン（単語）の文字を格納する変数
char token[ MAX_STRING_SIZE ];

// GetToken で使用する，1文字の先読みバッファ
int charBuf = EOF;

// c が空白文字かどうか
int IsSpace( int c )
{
    if( c == ' ' || c == '\t' || c == '\r' ){
        return TRUE;
    }
    else{
        return FALSE;
    }
}

// c が区切り文字かどうか
int IsSeparater( int c )
{
    if( c == ',' || c == '(' || c == ')' || c == '$' || c == ':' || c == '\n' ){
        return TRUE;
    }
    else{
        return FALSE;
    }
}

// file から1単語を読み出し，token に格納する
// ファイルの最後まで読んだ時は FALSE を返す．
// 次がまだあるときは TRUE を返す．
int GetToken( FILE* file )
{
    int c = 0;
    int i = 0;
    int initial = 1;

    // 単語を切り出すために，file から1文字先を読みだして
    // しまうことがあるので，そのような場合は charBuf 入れておく．
    
    // 前回読んだ結果が残っていたら，まずこれを使う
    if( charBuf != EOF ){
        c = charBuf;
        
        // 使い終わったので無効にしておく
        charBuf = EOF;
        
        token[i] = c;
        i++;
        
        if( IsSeparater(c) ){
            // 文字列の終端を作る
            token[i] = '\0';
            return TRUE;
        }
    }
    
    
    while( 1 ){
        
        // 1文字ファイルから読み出す
        c = fgetc( file );
        if( c == EOF ){
            break;
        }
        
        // スペースだった場合
        if( IsSpace(c) ){
            if( initial == TRUE ){
                // 最初は飛ばす
                continue;
            }
            else{
                // 既に文字の読み込みがあった場合は終了
                break;
            }
        }

        // 初期状態以外で区切り文字だったら，バッファに文字を積んでそこで終わる
        if( IsSeparater(c) && initial == FALSE ){
            charBuf = c;
            break;
        }
        
        token[i] = c;
        i++;

        // 初期状態で区切り文字だったらそこで終わる
        if( IsSeparater(c) && initial == TRUE ){
            break;
        }

        initial = FALSE;
    }
    
    // 文字列の終端を作る
    token[i] = '\0';

    // 1文字も読まれずに，バッファにも文字がない場合は
    // ファイルの終端まで達しているので FALSE を返す．
    if( i == 0 && charBuf == EOF ){
        return FALSE;
    }
    else{
        return TRUE;
    }
}

// トークンを1つ読んで， str と同じかどうか調べる
void GetAndCheckToken( FILE* file, char* str )
{
    if( GetToken( file ) == FALSE ){
            printf( "EOF\n" ); 
            exit(1);
    }
    if( strcmp( token, str ) != 0 ){
            printf( "Invalid token '%s'.\n", str ); 
            exit(1);
    }
}

// トークンを1つ読んで， 数字にして返す
int GetTokenNum( FILE* file )
{
    if( GetToken( file ) == FALSE ){
            printf( "EOF\n" ); 
            exit(1);
    }
    return atoi( token );
}


int main( int argc, char* argv[] )
{
    FILE* file;
    int i;
    int rs, rt, rd; // オペランド
    int imm;        // 即値

    // トークンをとっておくための文字列
    char op[ MAX_STRING_SIZE ];     
    char label[ MAX_STRING_SIZE ];
    
    
    // ファイルをオープン
    file = fopen( argv[1], "r" );
    if( !file ){
        fprintf( stderr, "Could not open '%s'.\n", argv[1] );
        return 0;
    }


    while( GetToken( file ) != FALSE ){
        
        
        if( strcmp( token, "add" ) == 0 ||
            strcmp( token, "sub" ) == 0
        ){
            // R形式
            strcpy( op, token );    // op をコピーしてとっておく

            GetAndCheckToken( file, "$" );  // $
            rd = GetTokenNum( file );       // rd の数字

            GetAndCheckToken( file, "," );  // ,

            GetAndCheckToken( file, "$" );  // $
            rs = GetTokenNum( file );       // rs の数字

            GetAndCheckToken( file, "," );  // ,

            GetAndCheckToken( file, "$" );  // $
            rt = GetTokenNum( file );       // rt の数字

            GetAndCheckToken( file, "\n" ); // 改行
            
            printf( "%s rd($%d), rs($%d), rt($%d)\n", op, rd, rs, rt );

        }
        else if(
            strcmp( token, "addi" ) == 0 ||
            strcmp( token, "subi" ) == 0
        ){
            // I形式
            strcpy( op, token );    // op をコピーしてとっておく

            GetAndCheckToken( file, "$" );  // $
            rd = GetTokenNum( file );       // rd の数字

            GetAndCheckToken( file, "," );  // ,

            GetAndCheckToken( file, "$" );  // $
            rs = GetTokenNum( file );       // rs の数字

            GetAndCheckToken( file, "," );  // ,

            imm = GetTokenNum( file );      // 数字

            GetAndCheckToken( file, "\n" ); // 改行
            
            printf( "%s rd($%d), rs($%d), #(%d)\n", op, rd, rs, imm );

        }
        else if( strcmp( token, "\n" ) == 0 ){
            // 空行は飛ばす
        }
        else{
            
            strcpy( label, token );
            
            // 定義にない場合は，ラベルの可能性がある
            // ":" の有無でチェック
            GetAndCheckToken( file, ":"  ); // :
            GetAndCheckToken( file, "\n" ); // 改行
        }
        
        
    }   
    
}
```
