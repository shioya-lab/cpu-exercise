//
// 検証用モジュール
//


// 基本的な型を定義したファイルの読み込み
import BasicTypes::*;
import Types::*;

//
// 全体の検証用モジュール
//
module MainSim;

    parameter CYCLE_TIME = 200; // 1サイクルを 200ns に設定

    integer cycle;        // サイクル
    integer cycleX4;    // 4倍速サイクル

    logic countCycle;

    logic clkX4;        // 4倍速クロック
    logic rst;

    logic btnC;
    logic btnU;
    logic btnD;

    LampPath lamp;    // Lamp?
	//OLED command pins
	logic SDIN;
	logic SCLK;
	logic DC;
	logic RES;
	logic VBAT;
	logic VDD;

    // Main モジュール
    Main main(
        btnC,
        btnU,
        btnD,
	    SDIN,
        SCLK,
        DC,
        RES,
        VBAT,
        VDD,
        lamp,
        clkX4,    // 4倍速クロック
        rst     // リセット（0でリセット）
    );

    // 検証動作を記述する
    initial begin
        
        //
        // 初期化
        //
        main.cpu.regFile.storage[0] = '0;
        for (int i = 1; i < REG_FILE_SIZE; i++) begin
            main.cpu.regFile.storage[ i ] = 32'hcdcdcdcd;
        end
        
`ifdef VERILATOR_SIMULATION
        $dumpfile("wave.vcd");
        $dumpvars;
`endif
        main.cpu.pc.pc = 0;
        btnU = 1'b0;
        btnC = 1'b0;
        btnD = 1'b0;

        
        //
        // リセット
        //
        rst = 1'b1;
        #(CYCLE_TIME/8*3)

        rst = 1'b0;
        #(CYCLE_TIME/8)
        #(CYCLE_TIME)
        #(CYCLE_TIME)
        btnC = 1'b1;
    

		//
		// シミュレーション開始
		//

		// 100 サイクル 
		#(CYCLE_TIME*100)
		$finish;
    end

    // クロック
    initial begin 
        countCycle = 0;
        clkX4   = 1'b1;
        cycleX4 = 0;
        cycle = 0;
        
        forever #(CYCLE_TIME / 2 / 4) begin
    
            // 4倍速
            clkX4 = !clkX4 ;
            
            if (countCycle) begin

                cycleX4 = cycleX4 + 1;
                // 等速
                if (cycleX4 % 8 == 0) begin
                    cycle = cycle + 1 ;
                end
            end
            
            // カウント開始
            if (!rst && clkX4) begin
                countCycle = 1;
            end
        end
    end

endmodule
