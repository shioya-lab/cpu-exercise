//
// 減算器の検証用モジュール
//



// 基本的な型を定義したファイルの読み込み
`include "Types.v" 



// シミュレーションの単位時間の設定
// #~ と書いた場合，この時間が経過する．
`timescale 1ns/1ns


//
// 減算器の検証用のモジュール
//
module H3_Simulator;
    `DataPath SubtractorInA, SubtractorInB;
    `DataPath SubtractorOut;

    Subtractor subtractor(
        .dst ( SubtractorOut ),
        .srcA ( SubtractorInA ),
        .srcB ( SubtractorInB )
    );

    initial begin
        SubtractorInA = 13;
        SubtractorInB = 14;

        #40

        SubtractorInA = 9;
        SubtractorInB = 9;

        #20

        $finish;
    end

    initial
        $monitor(
            $stime,
            " a(%d) + b(%d) = c(%d)",
            SubtractorInA,
            SubtractorInB,
            SubtractorOut
        );

endmodule


