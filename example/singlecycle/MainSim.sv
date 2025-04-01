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

    integer i;

    integer cycle;        // サイクル
    integer cycleX4;    // 4倍速サイクル

    logic countCycle;

    logic clkX4;        // 4倍速クロック
    logic rst;

    logic sigCH;
    logic btnU;
    logic sigCP;
    logic btnL;

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
        sigCH,
        btnU,
        sigCP,
	    SDIN,
        SCLK,
        DC,
        RES,
        VBAT,
        VDD,
        lamp,
        // led,
        // gate,
        // lamp,    // Lamp?
        clkX4,    // 4倍速クロック
        rst     // リセット（0でリセット）
    );

    // 検証動作を記述する
    initial begin
        
        //
        // 初期化
        //
        main.cpu.regFile.storage[0] = '0;
        for( i = 1; i < REG_FILE_SIZE; i++ ) begin
            main.cpu.regFile.storage[ i ] = 32'hcdcdcdcd;
        end
        
`ifdef VERILATOR_SIMULATION
        $dumpfile("wave.vcd");
        $dumpvars;
`endif
        main.cpu.pc.pc = 0;
        btnU = 1'b1;
        sigCH = 1'b0;
        sigCP = 1'b1;

        
        //
        // リセット
        //
        rst = 1'b1;
        #(CYCLE_TIME/8*3)

        rst = 1'b0;
        #(CYCLE_TIME/8)
        #(CYCLE_TIME)
        #(CYCLE_TIME)
        sigCH = 1'b1;
    

        //
        // シミュレーション開始
        //

        // 70 サイクル 
        #(CYCLE_TIME*70)
        sigCP = 1'b0;
        sigCH = 1'b0;
        rst = 1'b1;
        sigCH = 1'b1;
        #(CYCLE_TIME*5)
        rst = 1'b0;

        // 40
        #(CYCLE_TIME*40)
        sigCP = 1'b1;

        // 10
        #(CYCLE_TIME*10)
        sigCP = 1'b0;

        // 100 サイクル 
        #(CYCLE_TIME*100000)
        for (int i = 0; i < 8; i++) begin
            $display("%x", main.dmem.mem[4096+i]);
        end 
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
            
            if( countCycle ) begin

                cycleX4 = cycleX4 + 1;
                // 等速
                if( cycleX4 % 8 == 0 ) begin
                    cycle = cycle + 1 ;
                end

            end
            
            
            // カウント開始
            if( !rst && clkX4 ) begin
                countCycle = 1;
            end
        end
    end

endmodule


