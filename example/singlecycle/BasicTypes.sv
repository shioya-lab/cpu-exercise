
package BasicTypes;

//
// --- 真偽
//
parameter TRUE  = 1'b1;
parameter FALSE = 1'b0;

//
// --- 命令
//

// 命令幅は 32bit 
parameter INSN_WIDTH = 32;
typedef logic [ INSN_WIDTH-1:0 ] InsnPath;

// 命令のアドレス幅 11bit (512 エントリ x 4Byte = 9bit + 2bit)
parameter INSN_ADDR_WIDTH = 11;
parameter INSN_ADDR_SIZE  = 2048;
typedef logic [ INSN_ADDR_WIDTH-1:0 ] InsnAddrPath;

// リセット時のアドレス
parameter INSN_RESET_VECTOR = 0;

// PC のインクリメントバイト数
parameter INSN_PC_INC = 4;


parameter INSN_MEM_OFFSET = 2;
parameter INSN_MEM_WIDTH  = (INSN_ADDR_WIDTH - INSN_MEM_OFFSET);
parameter INSN_MEM_SIZE   = 512;



//
// --- データ・パス
//

// データ幅は32bit
parameter DATA_WIDTH = 32;

// データパス
typedef logic [ DATA_WIDTH-1:0 ] DataPath;

// データのアドレス幅 15bit
// メモリ : $0000-$3fff
// IO     : $4000-$7fff
parameter DATA_ADDR_WIDTH = 16;
typedef logic [ DATA_ADDR_WIDTH-1:0 ] DataAddrPath;

// 32bit (4 byte) = アドレスのオフセットが 2 bit
parameter DATA_MEM_OFFSET = $clog2(DATA_WIDTH/8);

// データメモリのエントリ数（ 2^13 = 8192エントリ ）
parameter DATA_MEM_ADDR_WIDTH = 13;
parameter DATA_MEM_SIZE  = 8192;
typedef logic [ DATA_MEM_ADDR_WIDTH-1:0 ] DataMemPath;




//
// IO
//


// LED
parameter LED_IN_WIDTH  = 4;
parameter LED_OUT_WIDTH = 8;

typedef logic [ LED_IN_WIDTH  - 1 : 0 ] LED_InPath;
typedef logic [ LED_OUT_WIDTH - 1 : 0 ] LED_OutPath;

typedef logic [ LED_IN_WIDTH * 8 - 1 : 0 ] LED_InArray;
typedef logic [ LED_OUT_WIDTH* 8 - 1 : 0 ] LED_OutArray;

function automatic LED_InArray GetNextLED(
    input LED_InArray ledIn,
    input integer index,
    input DataPath wrData
);
    LED_InArray ledOut = ledIn;
    ledOut[index * LED_IN_WIDTH +: LED_IN_WIDTH] = wrData[LED_IN_WIDTH-1:0];
    return ledOut;
endfunction

function automatic LED_InPath LED_InArrayAt(
    input LED_InArray data,
    input integer index 
);
    return data[ index * LED_IN_WIDTH  +: LED_IN_WIDTH  ];
endfunction

function automatic LED_OutPath LED_OutArrayAt(
    input LED_OutArray data, 
    input integer index
);
    return data[ index * LED_OUT_WIDTH +: LED_OUT_WIDTH ];
endfunction


// 追加ここから
// Dynamic_Display

parameter LED_DATA_WIDTH = 8;
parameter DD_IN_WIDTH = 32;
parameter DD_OUT_WIDTH = 8;
parameter DD_GATE_WIDTH = 4;

parameter LED_0_POS = 24;
parameter LED_1_POS = 16;
parameter LED_2_POS = 8;
parameter LED_3_POS = 0;

function automatic logic[7:0] ConvertToASCII(input logic[3:0] data);

    logic [7:0] ch;
    if (data < 4'hA) begin
        ch = "0" + {4'b0, data};
    end
    else if (data >= 4'hA) begin
        ch = "A" + {4'b0, data - 4'hA};
    end
    else begin
        ch = '0;
    end
    return ch;

endfunction

typedef logic [ LED_DATA_WIDTH - 1 : 0 ] LED_DataPath;
typedef logic [ DD_IN_WIDTH - 1 : 0 ] DD_InPath;
typedef logic [ DD_OUT_WIDTH - 1 : 0 ] DD_OutPath;
typedef logic [ DD_GATE_WIDTH - 1 : 0 ] DD_GatePath;

typedef logic [ DD_IN_WIDTH * 2 - 1 : 0 ] DD_InArray;
typedef logic [ DD_OUT_WIDTH * 2 - 1 : 0 ] DD_OutArray;
typedef logic [ DD_GATE_WIDTH * 2 - 1 : 0 ] DD_GateArray;

function automatic DD_InPath DD_InArrayAt(
    input DD_InArray data,
    input integer index
);
    return data[ index * DD_IN_WIDTH  +: DD_IN_WIDTH  ];
endfunction

function automatic DD_OutPath DD_OutArrayAt(
    input DD_OutArray data,
    input integer index
);
    return data[ index * DD_OUT_WIDTH +: DD_OUT_WIDTH ];
endfunction

function automatic DD_GatePath DD_GateArrayAt(
    input DD_GateArray data,
    input integer index
);
    return data[ index * DD_GATE_WIDTH +: DD_GATE_WIDTH ];
endfunction

parameter COUNT_WIDTH = 28;
typedef logic[ COUNT_WIDTH - 1 : 0 ] CountPath;
parameter DEF_COUNT = 28'h3000;
// ここまで

// LED control
//   0 : サイクル数とソート数をLEDに表示
//   1 : IO_ADDR_LED0 から IO_ADDR_LED7 に書いた値を表示
parameter LED_CTRL_SORT_RESULT = 1'b0;
parameter LED_CTRL_USER = 1'b1;


// LAMP?
parameter LAMP_WIDTH = 8;
typedef logic [ LAMP_WIDTH-1 : 0 ] LampPath;

// Sort count / Cycle
parameter CYCLE_WIDTH = 32;
typedef logic [ CYCLE_WIDTH-1 : 0 ] CyclePath;


// Debug
// typedef CyclePath LampPath;




//
// --- アドレスマップの定義
//

// アドレスのこのビットが立っていたらIO
parameter IO_ADDR_BIT_POS = 15;
parameter IO_ADDR_BEGIN   = 15'h8000;
parameter IO_ADDR_WIDTH   = 7;

function automatic logic [IO_ADDR_WIDTH-1:0] MAKE_IO_ADDR(input logic [IO_ADDR_WIDTH-1:0] address); 
    return address; //(`IO_ADDR_BEGIN + address)
endfunction

function automatic logic [IO_ADDR_WIDTH-1:0] PICK_IO_ADDR(input DataAddrPath address );
    return address[ 2 +:IO_ADDR_WIDTH ]; //(`IO_ADDR_BEGIN + address)
endfunction

function automatic logic [IO_ADDR_WIDTH-2:0] GET_OLED_ADDR(input DataAddrPath address );
    return address [2 +: 6];
endfunction

// アドレスマップ
parameter IO_ADDR_SORT_FINISH = MAKE_IO_ADDR( 7'h0 );// $8000: ソート終了 
parameter IO_ADDR_SORT_COUNT  = MAKE_IO_ADDR( 7'h1 );// $8004: ソート数   
parameter IO_ADDR_LAMP        = MAKE_IO_ADDR( 7'h2 );// $8008: ???
parameter IO_ADDR_LED_CTRL    = MAKE_IO_ADDR( 7'h3 );// $800C: LED 制御
//   0 : サイクル数とソート数をLEDに表示
//   1 : IO_ADDR_LED0 から IO_ADDR_LED1 に書いた値を表示

// parameter IO_ADDR_LED0 = MAKE_IO_ADDR( 5'h8 );// $4010 - $401e:
// parameter IO_ADDR_LED1 = MAKE_IO_ADDR( 5'h9 );// LED out
// parameter IO_ADDR_LED2 = MAKE_IO_ADDR( 5'ha );// Each register corresponds a 4-bit value.
// parameter IO_ADDR_LED3 = MAKE_IO_ADDR( 5'hb );
// parameter IO_ADDR_LED4 = MAKE_IO_ADDR( 5'hc );
// parameter IO_ADDR_LED5 = MAKE_IO_ADDR( 5'hd );
// parameter IO_ADDR_LED6 = MAKE_IO_ADDR( 5'he );
// parameter IO_ADDR_LED7 = MAKE_IO_ADDR( 5'hf );
parameter IO_ADDR_OLED_READY = MAKE_IO_ADDR( 7'h8 );// $8020: OLED ready
parameter IO_ADDR_OLED_UPDATE = MAKE_IO_ADDR( 7'h9 );// $8024: OLED update
parameter IO_ADDR_OLED_CLEAR = MAKE_IO_ADDR( 7'ha );// $8028: OLED clear


parameter IO_ADDR_SORT_START = MAKE_IO_ADDR( 7'h10 );// $8040: ソート開始
parameter IO_ADDR_BTNU       = MAKE_IO_ADDR( 7'h11 );// $8044: BTNU スイッチ
parameter IO_ADDR_CP         = MAKE_IO_ADDR( 7'h12 );// $8048: CP スイッチ
parameter IO_ADDR_CH         = MAKE_IO_ADDR( 7'h13 );// $804C: CH スイッチ
parameter IO_ADDR_CYCLE      = MAKE_IO_ADDR( 7'h14 );// $8050: 現在のサイクル

parameter IO_ADDR_OLED_CYCLE_START   = MAKE_IO_ADDR( 7'h18 );
parameter IO_ADDR_OLED_CYCLE_END     = MAKE_IO_ADDR( 7'h1f );
parameter IO_ADDR_OLED_ADDRESS_START = MAKE_IO_ADDR( 7'h20 );
parameter IO_ADDR_OLED_ADDRESS_END   = MAKE_IO_ADDR( 7'h27 );
parameter IO_ADDR_OLED_DATA_START    = MAKE_IO_ADDR( 7'h28 );
parameter IO_ADDR_OLED_DATA_END      = MAKE_IO_ADDR( 7'h2f );

parameter IO_ADDR_OLED_START = MAKE_IO_ADDR( 7'h40 );// $8100: OLED開始番地
parameter IO_ADDR_OLED_END   = MAKE_IO_ADDR( 7'h7f );// $81fc: OLED終了番地

endpackage
