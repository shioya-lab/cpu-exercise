`include "Types.v"

module RegAdder(
    input logic clk, //clock
    input `DataPath dA, //data written into register
    input `DataPath dB, //which register to write
    output `DataPath out
);
	parameter CYCLE_TIME = 10; // 1サイクルを 10ns に設定

	`DataPath raRfRdDataA;	// 読み出しデータA
	`DataPath raRfRdDataB;	// 読み出しデータB

	`RegNumPath raRfRdNumA;	// 読み出しレジスタ番号A
	`RegNumPath raRfRdNumB;	// 読み出しレジスタ番号B

	`DataPath   raRfWrData;	// 書き込みデータ
	`RegNumPath raRfWrNum;	// 書き込みレジスタ番号
	logic raRfWrEnable;	// 書き込み制御 1の場合，書き込みを行う


    Adder adder(
        .srcA ( raRfRdDataA ),
        .srcB ( raRfRdDataB ),
        .dst ( out )
    );

	RegisterFile regFile(
		.clk( clk ),
		.rdDataA ( raRfRdDataA  ),
		.rdDataB ( raRfRdDataB  ),
		.rdNumA  ( raRfRdNumA   ),
		.rdNumB  ( raRfRdNumB   ),
		.wrData  ( raRfWrData   ),
		.wrNum   ( raRfWrNum    ),
		.wrEnable( raRfWrEnable )
	);

    initial begin
		raRfRdNumA   = 0;
		raRfRdNumB   = 0;
        raRfRdDataB = 0;
        raRfRdDataA = 0;
		raRfWrData   = 0;
		raRfWrNum    = 0;
		raRfWrEnable = 0;
        #CYCLE_TIME
		raRfWrEnable = 1;	raRfWrNum = 0;	raRfWrData = dA;  // $0に15を代入
        #CYCLE_TIME
		raRfWrEnable = 1;	raRfWrNum = 1;	raRfWrData = dB;  // $0に15を代入
        #CYCLE_TIME
        raRfWrEnable = 1; raRfRdNumA = 0; raRfRdNumB = 1;
		#(CYCLE_TIME*10)
		$finish;
    end

endmodule