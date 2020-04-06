//
// IO Controller
//

`include "Types.v"

// 7seg選択用追加モジュール

`define GATE_LED_0	4'b1000
`define GATE_LED_1	4'b0100
`define GATE_LED_2	4'b0010
`define GATE_LED_3	4'b0001


module	DynamicDisplay(
	output	`DD_OutPath		ddOut,
	output	`DD_GatePath	ddGate,	
	input	`DD_InPath		ddIn,
	input	logic			clk,
	input	logic			rst
	);

`LED_DataPath	led_0, led_1, led_2, led_3;
`DD_GatePath	gate;
`CountPath 	clkCount;
logic	ctrlSig;

	always_comb begin
		led_0 = ddIn[ `LED_0_POS +: `LED_DATA_WIDTH ];
		led_1 = ddIn[ `LED_1_POS +: `LED_DATA_WIDTH ];
		led_2 = ddIn[ `LED_2_POS +: `LED_DATA_WIDTH ];
		led_3 = ddIn[ `LED_3_POS +: `LED_DATA_WIDTH ];
		ddGate = ~gate;
	end

	always@( posedge clk or negedge rst) begin
		if( !rst )begin
			clkCount <= `COUNT_WIDTH'd0;
		end
		else if( clkCount >= `DEF_COUNT - `COUNT_WIDTH'd1)begin
			clkCount <= `COUNT_WIDTH'd0;
		end
 		else begin
			clkCount <= clkCount + `COUNT_WIDTH'd1;
		end
	end

	always@( posedge clk or negedge rst) begin
		if( !rst )begin
			ctrlSig <= `FALSE;
		end
		else if( clkCount >= `DEF_COUNT - 28'd1 )begin
			ctrlSig <= `TRUE;
		end
		else begin
			ctrlSig <= `FALSE;
		end
	end

	always@( posedge clk or negedge rst) begin
		if( !rst )begin
			gate <= `GATE_LED_0;
		end
		else if( ctrlSig == `TRUE )begin
			case( gate )
			default:     gate <= `GATE_LED_1;	
			`GATE_LED_1: gate <= `GATE_LED_2;
			`GATE_LED_2: gate <= `GATE_LED_3;
			`GATE_LED_3: gate <= `GATE_LED_0;
			endcase
		end
		else begin
			gate <= gate;
		end
	end

	always@( posedge clk or negedge rst ) begin
		if( !rst )begin
			ddOut <= `LED_DATA_WIDTH'd0;
		end
		else begin
			case( gate )
			`GATE_LED_0: ddOut <= led_0;
			`GATE_LED_1: ddOut <= led_1;
			`GATE_LED_2: ddOut <= led_2;
			`GATE_LED_3: ddOut <= led_3;
			default: ddOut <= `LED_DATA_WIDTH'd0;
			endcase
		end
	end

endmodule


module DD_Driver(
	output `DD_OutArray dstArray,
	output `DD_GateArray gateArray,
	input  `DD_InArray  srcArray,
	input	logic	clk,
	input	logic	rst
);
	
	generate 
	
		genvar i;

		for( i = 0; i < 2; i = i + 1 ) begin	: DD
			DynamicDisplay
				DD_Driver( 
					`DD_OutArrayAt(  dstArray,  i ), 
					`DD_GateArrayAt( gateArray, i ),
					`DD_InArrayAt(   srcArray,  i ),
					clk,
					rst
				);
	 	end
	 	
	endgenerate

endmodule

// ここまで

module IOCtrl(

	input logic clk,
	input logic rst,
	
	output logic dmemWrEnable,	// データメモリ書き込み
	output `DataPath dataToCPU,	// CPU へのデータ
	
	output `DD_OutArray		led,	// 7seg
	output `DD_GateArray	gate,	// 7seg gate
	output `LampPath 		lamp,	// Lamp?
	

	input `DataAddrPath addr,			// データアドレス
	input `DataPath     dataFromCPU,	// データ本体
	input `DataPath     dataFromDMem,	// データメモリ読み出し結果
	input logic         weFromCPU,		// 書き込み

	input logic sigCH,
	input logic sigCE,
	input logic sigCP


);
	// Controll registers
	struct packed {

		// A signal that indicates end of sort
		// (W)
		logic sortFinish;
		
		//  The count of sorted elements.
		// (W)
		`DataPath sortCount;
		
		// Lamp?
		// (W)
		`LampPath lamp;
		
		// A switch of input signals of the LED driver.
		// (W)
		logic     ledCtrl;
		
		// Input signals of the LED driver.
		// (W)
		`LED_InArray led;
		
		// Cycle count
		logic		enableCycleCount;	// (W)
		`CyclePath  cycleCount;			// (N/A)
		
		// Indicates start of sort.
		// This register is set when the 'ch' is asserted and 
		// is not changed after being set.
		logic sortStart;
		
		// Externnal switches
		// (R)
		logic ce;
		logic ch;
		logic cp;
		
		
	} ctrlReg, ctrlNext, ctrlInit;

	// Output buffer
	struct packed {
		`LED_OutArray led;
		`LampPath lamp;
	} outReg, outNext;	
	
	// Indicates whether an address is IO or not.
	logic isIO;
	
	
	
	// LED Driver
	`LED_InArray  ledDrvIn;		// 4-bitx8 input
	`LED_OutArray ledDrvOut;	// 7-bitx8 output
	LED_Driver ledDrv0( ledDrvOut, ledDrvIn );

	
	// Dynamic Display
	`DD_OutArray	ddDrvOut;
	`DD_GateArray		ddDrvGate;
	DD_Driver ddDrv0( ddDrvOut, ddDrvGate, outReg.led, clk, rst );
	
	//
	// Controll ロジック
	//
	always_comb begin
	
		//
		// --- IO / Data memory 判定
		//
		if( addr[`IO_ADDR_BIT_POS] ) begin
			isIO = `TRUE;
			// IO 領域の場合はデータメモリの書き込みをシャットアウト
			dmemWrEnable = `FALSE;
		end
		else begin
			isIO = `FALSE;
			dmemWrEnable = weFromCPU;
		end

		//
		// --- 制御レジスタ
		//
		
		// 制御レジスタの次のサイクルの値
		ctrlNext = ctrlReg;
		

		// 書き込み
		if( isIO && weFromCPU ) begin

			case( `PICK_IO_ADDR( addr ) ) 

				`IO_ADDR_SORT_FINISH:	ctrlNext.sortFinish = dataFromCPU[0];
				`IO_ADDR_SORT_COUNT: 	ctrlNext.sortCount  = dataFromCPU;
				`IO_ADDR_LED_CTRL: 		ctrlNext.ledCtrl    = dataFromCPU[0];

				`IO_ADDR_LED0: `LED_InArrayAt( ctrlNext.led, 0 ) = dataFromCPU[ `LED_IN_WIDTH-1 : 0 ];
				`IO_ADDR_LED1: `LED_InArrayAt( ctrlNext.led, 1 ) = dataFromCPU[ `LED_IN_WIDTH-1 : 0 ];
				`IO_ADDR_LED2: `LED_InArrayAt( ctrlNext.led, 2 ) = dataFromCPU[ `LED_IN_WIDTH-1 : 0 ];
				`IO_ADDR_LED3: `LED_InArrayAt( ctrlNext.led, 3 ) = dataFromCPU[ `LED_IN_WIDTH-1 : 0 ];
				`IO_ADDR_LED4: `LED_InArrayAt( ctrlNext.led, 4 ) = dataFromCPU[ `LED_IN_WIDTH-1 : 0 ];
				`IO_ADDR_LED5: `LED_InArrayAt( ctrlNext.led, 5 ) = dataFromCPU[ `LED_IN_WIDTH-1 : 0 ];
				`IO_ADDR_LED6: `LED_InArrayAt( ctrlNext.led, 6 ) = dataFromCPU[ `LED_IN_WIDTH-1 : 0 ];
				`IO_ADDR_LED7: `LED_InArrayAt( ctrlNext.led, 7 ) = dataFromCPU[ `LED_IN_WIDTH-1 : 0 ];
				
				default: 		 		ctrlNext.lamp       = dataFromCPU[ `LAMP_WIDTH-1 : 0 ];

			
			endcase	// case( addr ) 

		end	// if( isIO && weFromCPU ) begin
					
					
		// 読み出し
		if( isIO ) begin

			// IO
			case( `PICK_IO_ADDR( addr ) ) 
				`IO_ADDR_SORT_START: dataToCPU = ctrlReg.sortStart;
				`IO_ADDR_CE: dataToCPU = ctrlReg.ce;
				`IO_ADDR_CP: dataToCPU = ctrlReg.cp;
				`IO_ADDR_CH: dataToCPU = ctrlReg.ch;		// ソートスタート
				default:	 dataToCPU = `DATA_WIDTH'hx;
			endcase

		end else
		begin

			// データメモリ
			dataToCPU = dataFromDMem;

		end
		
		
		// LED ドライバ
		if( ctrlReg.ledCtrl == `LED_CTRL_USER ) begin
			ledDrvIn = ctrlReg.led;
		end
		else begin
			ledDrvIn = ctrlReg.cycleCount;
		end
		
		
		// サイクルカウント
		if( ( !ctrlReg.ch || ctrlReg.enableCycleCount ) &&
		    !ctrlReg.sortFinish
		) begin
			ctrlNext.cycleCount = ctrlReg.cycleCount + 1'h1;
			ctrlNext.enableCycleCount = `TRUE;
			ctrlNext.sortStart = `TRUE;
		end
		
		
		// Switchs
		// CH/CE/CP
		ctrlNext.ch = sigCH;
		ctrlNext.ce = sigCE;
		ctrlNext.cp = sigCP;

		
		//
		// --- 出力バッファ
		//
		
		// LED & Lamp
		outNext.lamp = ctrlReg.lamp;
		outNext.led  = ledDrvOut;

		// 出力
		led  = ddDrvOut;
		lamp = outReg.lamp;
		gate = ddDrvGate;
		
		//
		// リセット
		//
		ctrlInit = 0;
		ctrlInit.ch = 1'b1;
		ctrlInit.cp = 1'b1;
		ctrlInit.ce = 1'b1;
 	end
	

	//
	// --- レジスタ
	//
	always_ff @( posedge clk or negedge rst) begin
		if( !rst ) begin
			ctrlReg <= ctrlInit;
			outReg  <= 0;
		end
		else begin
			ctrlReg <= ctrlNext;
			outReg  <= outNext;
		end
	end


endmodule

