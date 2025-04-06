
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
typedef logic [INSN_WIDTH-1:0] InsnPath;

// 命令のアドレス幅 11bit (512 エントリ x 4Byte = 9bit + 2bit)
parameter INSN_ADDR_WIDTH = 11;
parameter INSN_ADDR_SIZE  = 2048;
typedef logic [INSN_ADDR_WIDTH-1:0] InsnAddrPath;

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
typedef logic [DATA_WIDTH-1:0] DataPath;

parameter CHAR_BIT_WIDTH = 8;
typedef logic [CHAR_BIT_WIDTH-1:0] CharPath;

parameter HEXADECIMAL_BIT_WIDTH = 4;
typedef logic [HEXADECIMAL_BIT_WIDTH-1:0] HexadecimalPath;

// データのアドレス幅 15bit
// メモリ : $0000-$3fff
// IO     : $4000-$7fff
parameter DATA_ADDR_WIDTH = 16;
typedef logic [DATA_ADDR_WIDTH-1:0] DataAddrPath;

function automatic DataAddrPath GET_ADDR(input DataPath data);
    return data[DATA_ADDR_WIDTH-1:0];
endfunction

// 32bit (4 byte) = アドレスのオフセットが 2 bit
parameter DATA_MEM_OFFSET = $clog2(DATA_WIDTH/8);

// データメモリのエントリ数（ 2^13 = 8192エントリ ）
parameter DATA_MEM_ADDR_WIDTH = 13;
parameter DATA_MEM_SIZE  = 8192;
typedef logic [DATA_MEM_ADDR_WIDTH-1:0] DataMemPath;

//
// IO
//

function automatic CharPath ConvertToASCII(
    input HexadecimalPath data
);

    CharPath ch;
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


parameter COUNT_WIDTH = 28;
typedef logic[COUNT_WIDTH-1:0] CountPath;
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
    return address[2+:IO_ADDR_WIDTH]; //(`IO_ADDR_BEGIN + address)
endfunction


// アドレスマップ
parameter IO_ADDR_SORT_FINISH = MAKE_IO_ADDR( 7'h0 );// $8000: ソート終了 
parameter IO_ADDR_SORT_COUNT  = MAKE_IO_ADDR( 7'h1 );// $8004: ソート数   
parameter IO_ADDR_LAMP        = MAKE_IO_ADDR( 7'h2 );// $8008: LED Lamp
parameter IO_ADDR_SORT_START  = MAKE_IO_ADDR( 7'h3 );// $800C: ソート開始

parameter IO_ADDR_BTNU       = MAKE_IO_ADDR( 7'h4 );// $8010: BTNU スイッチ
parameter IO_ADDR_CP         = MAKE_IO_ADDR( 7'h5 );// $8014: CP スイッチ
parameter IO_ADDR_CH         = MAKE_IO_ADDR( 7'h6 );// $8018: CH スイッチ
parameter IO_ADDR_CYCLE      = MAKE_IO_ADDR( 7'h7 );// $801C: 現在のサイクル

parameter IO_ADDR_DISPLAY_CYCLE_BEGIN = MAKE_IO_ADDR( 7'h8 ); // $8080 - $803C 1000 0000 - 0011 1100
parameter IO_ADDR_DISPLAY_CYCLE_END   = MAKE_IO_ADDR( 7'hf ); // $809C
parameter IO_ADDR_DISPLAY_SIZE_BEGIN  = MAKE_IO_ADDR( 7'h10 ); // $80A0 - $805C 1010 0000 - 0101 1100
parameter IO_ADDR_DISPLAY_SIZE_END    = MAKE_IO_ADDR( 7'h17 ); // $80BC - $805C
parameter IO_ADDR_DISPLAY_ADDR_BEGIN  = MAKE_IO_ADDR( 7'h18 ); // $80C0 - $807C
parameter IO_ADDR_DISPLAY_ADDR_END    = MAKE_IO_ADDR( 7'h1f ); // $80DC - $807C
parameter IO_ADDR_DISPLAY_DATA_BEGIN  = MAKE_IO_ADDR( 7'h20 ); // $80E0 - $809C
parameter IO_ADDR_DISPLAY_DATA_END    = MAKE_IO_ADDR( 7'h27 ); // $80FC - $809C 1010 0000 - 1011 1100

parameter DISPLAY_WRITE_BIT_POS = 7;

parameter DISPLAY_ROW_NUM = 4;
parameter DISPLAY_ROW_INDEX_BIT_POS = 5;
parameter DISPLAY_ROW_INDEX_BIT_WIDTH = 2;
typedef logic [DISPLAY_ROW_INDEX_BIT_WIDTH-1:0] DisplayRowIndex;

parameter DISPLAY_COLUMN_NUM = 16;
parameter DISPLAY_COLUMN_INDEX_BIT_POS = 2;
parameter DISPLAY_COLUMN_INDEX_BIT_WIDTH = 3;
typedef logic [DISPLAY_COLUMN_INDEX_BIT_WIDTH-1:0] DisplayColumnIndex;

parameter DISPLAY_INDEX_BIT_WIDTH = 
    DISPLAY_ROW_INDEX_BIT_WIDTH + DISPLAY_COLUMN_INDEX_BIT_WIDTH + 1;
typedef logic [DISPLAY_INDEX_BIT_WIDTH-1:0] DisplayIndex;

parameter DISPLAY_OFFSET_BIT_WIDTH = 3;

parameter DISPLAY_FULL_INDEX_BIT_WIDTH = DISPLAY_INDEX_BIT_WIDTH + DISPLAY_OFFSET_BIT_WIDTH;
typedef logic [DISPLAY_FULL_INDEX_BIT_WIDTH-1:0] DisplayFullIndex;

function automatic DisplayColumnIndex GET_DISPLAY_COLOMN_ADDR(
    input DataAddrPath address
);
    return address [DISPLAY_COLUMN_INDEX_BIT_POS+:DISPLAY_COLUMN_INDEX_BIT_WIDTH];
endfunction

function automatic DisplayRowIndex GET_DISPLAY_ROW_ADDR(
    input DataAddrPath address
);
    return address [DISPLAY_ROW_INDEX_BIT_POS+:DISPLAY_ROW_INDEX_BIT_WIDTH];
endfunction

endpackage
