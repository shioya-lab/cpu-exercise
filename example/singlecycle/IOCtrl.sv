//
// IO Controller
//

import BasicTypes::*;
import Types::*;

module DisplayDriver(
    input logic clk,
    input logic writeDisplay,
    input DisplayColumnIndex colIdx,
    input DisplayRowIndex rowIdx,
    input CharPath writeData,
    input CharPath curCycle[CURRENT_CYCLE_CHAR_NUM],
	output logic oledDC,
	output logic oledRES,
	output logic oledSCLK,
	output logic oledSDIN,
	output logic oledVBAT,
	output logic oledVDD
);

    //state machine codes
    localparam Idle       = 0;
    localparam Init       = 1;
    localparam Active     = 2;
    localparam Done       = 3;
    localparam FullDisp   = 4;
    localparam Write      = 5;
    localparam WriteWait  = 6;
    localparam UpdateWait = 7;

    CharPath regCycle[CURRENT_CYCLE_CHAR_NUM];

    CharPath writeBuffer[0:DISPLAY_ROW_NUM-1][0:DISPLAY_COLUMN_NUM-1] = '{
        '{"C", "y", "c", "l", "e", ":", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "}, 
        '{"S", "i", "z", "e", ":", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "}, 
        '{"A", "d", "d", "r", ":", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "}, 
        '{"D", "a", "t", "a", ":", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "}
    };
    always_ff @(posedge clk) begin
        if (writeDisplay) begin
            writeBuffer[rowIdx][colIdx] <= writeData;
        end
        writeBuffer[0][CURRENT_CYCLE_DISPLAY_COLUMN_POS+:CURRENT_CYCLE_CHAR_NUM] 
            <= curCycle;
    end
    
    localparam AUTO_START = 1; // determines whether the OLED will be automatically initialized when the board is programmed
    	
    //state machine registers.
    localparam STATE_BIT_WIDTH = 3;
    logic [STATE_BIT_WIDTH-1:0] state = Init;
        
    //oled control signals
    //command start signals, assert high to start command
    logic        update_start = 0;        //update oled display over spi
    logic        disp_on_start = AUTO_START;       //turn the oled display on
    logic        disp_off_start = 0;      //turn the oled display off
    logic        toggle_disp_start = 0;   //turns on every pixel on the oled, or returns the display to before each pixel was turned on
    logic        write_start = 0;         //writes a character bitmap into local memory
    //data signals for oled controls
    logic        update_clear = 0;        //when asserted high, an update command clears the display, instead of filling from memory
    DisplayFullIndex write_base_addr = 0;     //location to write character to, two most significant bits are row position, 0 is topmost. bottom seven bits are X position, addressed by pixel x position.
    DisplayFullIndex next_addr;
    CharPath     write_ascii_data = 0;    //ascii value of character to write to memory
    //active high command ready signals, appropriate start commands are ignored when these are not asserted high
    logic        disp_on_ready;
    logic        disp_off_ready;
    logic        toggle_disp_ready;
    logic        update_ready;
    logic        write_ready;
    
    //debounced button signals used for state transitions
    logic init_done;
    logic init_ready;
    


`ifdef VIVADO_SYNTHESIS
    OLEDCtrl oledCtrl (
        .clk (clk),
        .write_start (write_start),
        .write_ascii_data (write_ascii_data),
        .write_base_addr (write_base_addr),
        .write_ready (write_ready),
        .update_start (update_start),
        .update_clear (update_clear),
        .update_ready (update_ready),
        .disp_on_start (disp_on_start),
        .disp_on_ready (disp_on_ready),
        .disp_off_start (disp_off_start),
        .disp_off_ready (disp_off_ready),
        .toggle_disp_start (toggle_disp_start),
        .toggle_disp_ready (toggle_disp_ready),
        .SDIN (oledSDIN),
        .SCLK (oledSCLK),
        .DC (oledDC),
        .RES (oledRES),
        .VBAT (oledVBAT),
        .VDD (oledVDD)
    );
`endif
    
    assign init_done = disp_off_ready | toggle_disp_ready | write_ready | update_ready;//parse ready signals for clarity
    assign init_ready = disp_on_ready;
    assign next_addr = write_base_addr + 8;
    always_ff @(posedge clk)
        case (state)
            Idle: begin
                if (init_ready == 1'b1) begin
                    disp_on_start <= 1'b1;
                    state <= Init;
                end
            end
            Init: begin
                disp_on_start <= 1'b0;
                if (init_done == 1'b1)
                    state <= Active;
            end
            Active: begin // hold until ready, then accept input
                if (write_ready) begin
                    write_start <= 1'b1;
                    write_base_addr <= 'b0;
                    write_ascii_data <= writeBuffer[0][0];
                    state <= WriteWait;
                end
            end
            Write: begin
                write_start <= 1'b1;
                //write_ascii_data updated with write_base_addr
                state <= WriteWait;
            end
            WriteWait: begin
                write_start <= 1'b0;
                if (write_ready == 1'b1) begin
                    if (write_base_addr == 9'h3f8) begin
                        update_start <= 1'b1;
                        update_clear <= 1'b0;
                        state <= UpdateWait;
                    end
                    else begin
                        state <= Write;
                        write_base_addr <= write_base_addr + 9'h8;
                        write_ascii_data <= writeBuffer[next_addr[8:7]][next_addr[6:3]];
                    end
                end
            end
            UpdateWait: begin
                update_start <= 0;
                if (init_done == 1'b1)
                    state <= Active;
            end
            Done: begin
                disp_off_start <= 1'b0;
                if (init_ready == 1'b1)
                    state <= Idle;
            end
            default: state <= Idle;
        endcase

endmodule

// ここまで

module IOCtrl(
    input logic clk,
    input logic rst,
    
    output logic dmemWrEnable,    // データメモリ書き込み
    output DataPath dataToCPU,    // CPU へのデータ
    
    output LampPath lamp,         // Lamp

    input DataAddrPath addr,            // データアドレス
    input DataPath     dataFromCPU,    // データ本体
    input DataPath     dataFromDMem,    // データメモリ読み出し結果
    input logic        weFromCPU,        // 書き込み

    input logic btnC,
    input logic btnU,
    input logic btnD,

	output logic oledDC,
	output logic oledRES,
	output logic oledSCLK,
	output logic oledSDIN,
	output logic oledVBAT,
	output logic oledVDD
);
    // Controll registers
    struct packed {

        // A signal that indicates end of sort
        // (W)
        logic sortFinish;
        
        //  The count of sorted elements.
        // (W)
        DataPath sortCount;
        
        // Lamp?
        // (W)
        LampPath lamp;
        
        // A switch of input signals of the LED driver.
        // (W)
        logic     ledCtrl;
    
        
        // Cycle count
        logic        enableCycleCount;    // (W)
        CyclePath  cycleCount;            // (N/A)
        
        // Indicates start of sort.
        // This register is set when the 'btnc' is asserted and 
        // is not changed after being set.
        logic sortStart;
        
        // Externnal switches
        // (R)
        logic btnU;
        logic btnC;
        logic btnD;
    } ctrlReg, ctrlNext;

    // Output buffer
    struct packed {
        // Lamp (LED)
        LampPath lamp;
        
        // Display
        logic writeDisplay;
        DisplayColumnIndex colIdx;
        DisplayRowIndex rowIdx;
        CharPath writeData;
    } outReg, outNext;

    CharPath curCycleChar[CURRENT_CYCLE_CHAR_NUM];

    // Indicates whether an address is IO or not.
    logic isIO;

    DisplayDriver displayDriver (
        .clk(clk),
        .writeDisplay(outReg.writeDisplay),
        .writeData(outReg.writeData),
        .curCycle (curCycleChar),
        .colIdx(outReg.colIdx),
        .rowIdx(outReg.rowIdx),
        .oledDC(oledDC),
        .oledRES(oledRES),
        .oledSCLK(oledSCLK),
        .oledSDIN(oledSDIN),
        .oledVBAT(oledVBAT),
        .oledVDD(oledVDD)
    );

    //
    // Controll ロジック
    //
    always_comb begin
    
        //
        // --- IO / Data memory 判定
        //
        if (addr[IO_ADDR_BIT_POS]) begin
            isIO = TRUE;
            // IO 領域の場合はデータメモリの書き込みをシャットアウト
            dmemWrEnable = FALSE;
        end
        else begin
            isIO = FALSE;
            dmemWrEnable = weFromCPU;
        end

        //
        // --- 制御レジスタ
        //
        
        // 制御レジスタの次のサイクルの値
        ctrlNext = ctrlReg;
        dataToCPU = '0;
        outNext = '0;
        outNext.writeData = ConvertToASCII(dataFromCPU[HEXADECIMAL_BIT_WIDTH-1:0]);
        outNext.colIdx = GET_DISPLAY_COLOMN_ADDR(addr);
        outNext.rowIdx = GET_DISPLAY_ROW_ADDR(addr);
        
        // 書き込み
        if (isIO && weFromCPU) begin
            outNext.writeDisplay = addr[DISPLAY_WRITE_BIT_POS];
            case (PICK_IO_ADDR(addr)) 
                IO_ADDR_SORT_FINISH:    ctrlNext.sortFinish = dataFromCPU[0];
                IO_ADDR_SORT_COUNT:     ctrlNext.sortCount  = dataFromCPU;
                IO_ADDR_SORT_START:     ctrlNext.sortStart  = dataFromCPU[0];
                IO_ADDR_LAMP:           ctrlNext.lamp       = dataFromCPU[LAMP_WIDTH-1:0];
                default: begin
                end
            endcase    // case( addr ) 
        end    // if( isIO && weFromCPU ) begin

        // 読み出し
        if (isIO) begin
            // IO
            case (PICK_IO_ADDR(addr)) 
                IO_ADDR_BTNU:       dataToCPU[0] = ctrlReg.btnU;
                IO_ADDR_BTND:       dataToCPU[0] = ctrlReg.btnD;
                IO_ADDR_BTNC:       dataToCPU[0] = ctrlReg.btnC;    // ソートスタート
                IO_ADDR_CYCLE:      dataToCPU = ctrlReg.cycleCount;
                default:            dataToCPU = {DATA_WIDTH{1'bx}};
            endcase
        end
        else begin
            // データメモリ
            dataToCPU = dataFromDMem;
        end
        
        // サイクルカウント
        if ((ctrlReg.sortStart || ctrlReg.enableCycleCount) &&
            !ctrlReg.sortFinish
        ) begin
            ctrlNext.cycleCount = ctrlReg.cycleCount + 1'h1;
            ctrlNext.enableCycleCount = TRUE;
        end
        
        // Switchs
        // btnc/CE/CP
        ctrlNext.btnC = btnC;
        ctrlNext.btnU = btnU;
        ctrlNext.btnD = btnD;
        
        //
        // --- 出力バッファ
        //
        
        // LED & Lamp
        outNext.lamp = ctrlReg.lamp;

        // 出力
        lamp = outReg.lamp;
     end
    
    //
    // --- レジスタ
    //
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ctrlReg <= '0;
            outReg  <= '0;
            for (int i = 0; i < CURRENT_CYCLE_CHAR_NUM; i++) begin
                curCycleChar[i] <= '0;
            end

        end
        else begin
            ctrlReg <= ctrlNext;
            outReg  <= outNext;
            for (int i = 0; i < CURRENT_CYCLE_CHAR_NUM; i++) begin
                curCycleChar[CURRENT_CYCLE_CHAR_NUM-1-i] <= 
                    ConvertToASCII(ctrlReg.cycleCount[HEXADECIMAL_BIT_WIDTH*i+:HEXADECIMAL_BIT_WIDTH]);
            end
        end
    end

endmodule
