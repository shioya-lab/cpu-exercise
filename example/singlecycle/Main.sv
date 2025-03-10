
import BasicTypes::*;
import Types::*;

module Main(
    input logic sigCH,
    input logic sigCE,
    input logic sigCP,

    output DD_OutArray  led,    // 7seg
    output DD_GateArray gate,    // 7seg gate
    output LampPath     lamp,    // Lamp?
    
    input logic clkBase,    // 4倍速クロック
    input logic rst         // リセット（0でリセット）
);
    // 命令メモリとデータメモリは，FPGA の仕様により
    // アドレスを入力した1サイクル後にデータが読み出される．
    // このままではシングルサイクルマシンが作れないので，メモリには
    // 4倍速のクロックを入れてある．

    // Clock/Reset
    logic clkX4;
    logic clk;
    
    // IMem
    InsnAddrPath imemAddr;            // アドレス出力
    InsnPath       imemDataToCPU;    // 命令コード
    
    // Data Memory
    logic         dmemWrEnable;        // 書き込み有効
    
    // IOCtrl
    logic         dataWE_Req;
    
    // データ
    DataPath     dataToCPU;        // 出力
    DataAddrPath dataAddr;            // アドレス
    DataPath     dataFromCPU;        // 入力
    DataPath     dataFromDMem;        // データメモリ読み出し
    logic         dataWE_FromCPU;

    // Clock divider
    ClockDivider clockDivider(
        clk,
        rst,
        clkX4
    );
    
    // IO
    IOCtrl ioCtrl(
        clkX4,
        rst,
        dmemWrEnable,
        dataToCPU,
        
        led,    // LED
        gate,    // select 7seg
        lamp,    // Lamp?

        dataAddr,
        dataFromCPU,
        dataFromDMem,
        dataWE_Req,

        sigCH,
        sigCE,
        sigCP
    );
    
    // CPU
    CPU cpu(
        clk,
        rst,
        imemAddr,        // 命令メモリへのアドレス出力
        dataAddr,        // データメモリへのアドレス出力
        dataFromCPU,    // データメモリへの入力
        dataWE_FromCPU,    // データメモリ書き込み有効
        imemDataToCPU,    // 命令メモリからの出力
        dataToCPU        // データメモリからの出力
    );

    // IMem
    IMem imem( 
        clkX4,             // メモリは4倍速
        rst,
        imemDataToCPU,
        imemAddr
    );

    // Data memory
    DMem dmem(
        clkX4,            // メモリは4倍速
        rst,            // リセット
        dataFromDMem,
        dataAddr,
        dataFromCPU,
        dmemWrEnable
    );

    // Connections & multiplexers
    always_comb begin
        
        // クロック
        clkX4  = clkBase;
        
        // データメモリへの書き込みはクロックサイクル後半のみ有効
        dataWE_Req = !clk && dataWE_FromCPU;

     end
    

endmodule


