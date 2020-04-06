//
// --- 真偽
//
`define TRUE  1'b1
`define FALSE 1'b0

//
// --- 命令
//

// 命令幅は 32bit 
`define INSN_WIDTH 32
`define InsnPath logic [ `INSN_WIDTH-1:0 ]

// 命令のアドレス幅 11bit (512 エントリ x 4Byte = 9bit + 2bit)
`define INSN_ADDR_WIDTH 11
`define INSN_ADDR_SIZE  2048
`define InsnAddrPath logic [ `INSN_ADDR_WIDTH-1:0 ]

// リセット時のアドレス
`define INSN_RESET_VECTOR 0

// PC のインクリメントバイト数
`define INSN_PC_INC `INSN_ADDR_WIDTH'h4


`define INSN_MEM_OFFSET 2
`define INSN_MEM_WIDTH  (`INSN_ADDR_WIDTH - `INSN_MEM_OFFSET)
`define INSN_MEM_SIZE   512



//
// --- データ・パス
//

// データ幅は16bit
`define DATA_WIDTH 16

// データパス
`define DataPath logic [ `DATA_WIDTH-1:0 ]

// データのアドレス幅 15bit
// メモリ : $0000-$3fff
// IO     : $4000-$7fff
`define DATA_ADDR_WIDTH 15
`define DataAddrPath logic [ `DATA_ADDR_WIDTH-1:0 ]

// 16bit (2 byte) = アドレスのオフセットが 1 bit
`define DATA_MEM_OFFSET 1

// データメモリのエントリ数（ 2^13 = 8192エントリ ）
`define DATA_MEM_ADDR_WIDTH 13
`define DATA_MEM_SIZE  8192
`define DataMemPath logic [ `DATA_MEM_ADDR_WIDTH-1:0 ]




//
// IO
//
	
	
// LED
`define LED_IN_WIDTH  4
`define LED_OUT_WIDTH 8

`define LED_InPath  logic [ `LED_IN_WIDTH  - 1 : 0 ]
`define LED_OutPath logic [ `LED_OUT_WIDTH - 1 : 0 ]

`define LED_InArray  logic [ `LED_IN_WIDTH * 8 - 1 : 0 ]
`define LED_OutArray logic [ `LED_OUT_WIDTH* 8 - 1 : 0 ]

`define	LED_InArrayAt(  data, index ) data[ index * `LED_IN_WIDTH  +: `LED_IN_WIDTH  ]
`define	LED_OutArrayAt( data, index ) data[ index * `LED_OUT_WIDTH +: `LED_OUT_WIDTH ]


// 追加ここから
// Dynamic_Display

`define LED_DATA_WIDTH	8
`define DD_IN_WIDTH 32
`define DD_OUT_WIDTH 8
`define DD_GATE_WIDTH	4

`define LED_0_POS 24
`define LED_1_POS 16
`define LED_2_POS 8
`define LED_3_POS 0

`define LED_DataPath logic [ `LED_DATA_WIDTH - 1 : 0 ]
`define DD_InPath	 logic [ `DD_IN_WIDTH - 1 : 0 ]
`define DD_OutPath	 logic [ `DD_OUT_WIDTH - 1 : 0 ]
`define DD_GatePath	 logic [ `DD_GATE_WIDTH - 1 : 0 ]

`define DD_InArray   logic [ `DD_IN_WIDTH * 2 - 1 : 0 ]
`define DD_OutArray  logic [ `DD_OUT_WIDTH * 2 - 1 : 0 ]
`define DD_GateArray logic [ `DD_GATE_WIDTH * 2 - 1 : 0 ]

`define DD_InArrayAt(  data, index ) data[ index * `DD_IN_WIDTH  +: `DD_IN_WIDTH  ]
`define DD_OutArrayAt( data, index ) data[ index * `DD_OUT_WIDTH +: `DD_OUT_WIDTH ]
`define DD_GateArrayAt( data, index ) data[ index * `DD_GATE_WIDTH +: `DD_GATE_WIDTH ]

`define COUNT_WIDTH 28
`define CountPath logic[ `COUNT_WIDTH - 1 : 0 ]
`define DEF_COUNT 28'h3000
// ここまで

// LED control
//   0 : サイクル数とソート数をLEDに表示
//   1 : IO_ADDR_LED0 から IO_ADDR_LED7 に書いた値を表示
`define LED_CTRL_SORT_RESULT 	1'b0
`define LED_CTRL_USER			1'b1


// LAMP?
`define LAMP_WIDTH 8
`define LampPath logic [ `LAMP_WIDTH-1 : 0 ]

// Sort count / Cycle
`define CYCLE_WIDTH 32
`define CyclePath logic [ `CYCLE_WIDTH-1 : 0 ]


// Debug
`define DebugPath `LampPath




//
// --- アドレスマップの定義
//

// アドレスのこのビットが立っていたらIO
`define IO_ADDR_BIT_POS 14
`define IO_ADDR_BEGIN   14'h4000
`define IO_ADDR_WIDTH   5

`define MAKE_IO_ADDR( address ) (address) //(`IO_ADDR_BEGIN + address)
`define PICK_IO_ADDR( address ) (address[ 1 +:`IO_ADDR_WIDTH ]) //(`IO_ADDR_BEGIN + address)

// アドレスマップ
`define IO_ADDR_SORT_FINISH	`MAKE_IO_ADDR( 5'h0 )		// $4000: ソート終了 
`define IO_ADDR_SORT_COUNT 	`MAKE_IO_ADDR( 5'h1 )		// $4002: ソート数   
`define IO_ADDR_LAMP 		`MAKE_IO_ADDR( 5'h2 )		// $4004: ???
`define IO_ADDR_LED_CTRL	`MAKE_IO_ADDR( 5'h3 )		// $4006: LED 制御
														//   0 : サイクル数とソート数をLEDに表示
														//   1 : IO_ADDR_LED0 から IO_ADDR_LED1 に書いた値を表示

`define IO_ADDR_LED0 		`MAKE_IO_ADDR( 5'h8 )		// $4010 - $401e:
`define IO_ADDR_LED1 		`MAKE_IO_ADDR( 5'h9 )		// LED out
`define IO_ADDR_LED2 		`MAKE_IO_ADDR( 5'ha )		// Each register corresponds a 4-bit value.
`define IO_ADDR_LED3 		`MAKE_IO_ADDR( 5'hb )
`define IO_ADDR_LED4 		`MAKE_IO_ADDR( 5'hc )
`define IO_ADDR_LED5 		`MAKE_IO_ADDR( 5'hd )
`define IO_ADDR_LED6 		`MAKE_IO_ADDR( 5'he )
`define IO_ADDR_LED7 		`MAKE_IO_ADDR( 5'hf )


`define IO_ADDR_SORT_START	`MAKE_IO_ADDR( 5'h10 )		// $4020: ソート開始
`define IO_ADDR_CE			`MAKE_IO_ADDR( 5'h11 )		// $4022: CE スイッチ
`define IO_ADDR_CP 			`MAKE_IO_ADDR( 5'h12 )		// $4024: CP スイッチ
`define IO_ADDR_CH 			`MAKE_IO_ADDR( 5'h13 )		// $4026: CH スイッチ
`define IO_ADDR_CYCLE 		`MAKE_IO_ADDR( 5'h14 )		// $4028: 現在のサイクル


