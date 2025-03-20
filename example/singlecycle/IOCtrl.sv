//
// IO Controller
//

import BasicTypes::*;
import Types::*;

// 7seg選択用追加モジュール

localparam GATE_LED_0 = 4'b1000;
localparam GATE_LED_1 = 4'b0100;
localparam GATE_LED_2 = 4'b0010;
localparam GATE_LED_3 = 4'b0001;


module    DynamicDisplay(
    output    DD_OutPath        ddOut,
    output    DD_GatePath    ddGate,    
    input    DD_InPath        ddIn,
    input    logic            clk,
    input    logic            rst
    );

LED_DataPath    led_0, led_1, led_2, led_3;
DD_GatePath    gate;
CountPath     clkCount;
logic    ctrlSig;

    always_comb begin
        led_0 = ddIn[ LED_0_POS +: LED_DATA_WIDTH ];
        led_1 = ddIn[ LED_1_POS +: LED_DATA_WIDTH ];
        led_2 = ddIn[ LED_2_POS +: LED_DATA_WIDTH ];
        led_3 = ddIn[ LED_3_POS +: LED_DATA_WIDTH ];
        ddGate = ~gate;
    end

    always@( posedge clk or negedge rst) begin
        if( !rst )begin
            clkCount <= {COUNT_WIDTH{1'b0}};
        end
        else if( clkCount >= DEF_COUNT - 1'b1)begin
            clkCount <= {COUNT_WIDTH{1'b0}};
        end
         else begin
            clkCount <= clkCount + 1'b1;
        end
    end

    always@( posedge clk or negedge rst) begin
        if( !rst )begin
            ctrlSig <= FALSE;
        end
        else if( clkCount >= DEF_COUNT - 1'd1 )begin
            ctrlSig <= TRUE;
        end
        else begin
            ctrlSig <= FALSE;
        end
    end

    always@( posedge clk or negedge rst) begin
        if( !rst )begin
            gate <= GATE_LED_0;
        end
        else if( ctrlSig == TRUE )begin
            case( gate )
            default:    gate <= GATE_LED_1;    
            GATE_LED_1: gate <= GATE_LED_2;
            GATE_LED_2: gate <= GATE_LED_3;
            GATE_LED_3: gate <= GATE_LED_0;
            endcase
        end
        else begin
            gate <= gate;
        end
    end

    always@( posedge clk or negedge rst ) begin
        if( !rst )begin
            ddOut <= {LED_DATA_WIDTH{1'b0}};
        end
        else begin
            case( gate )
            GATE_LED_0: ddOut <= led_0;
            GATE_LED_1: ddOut <= led_1;
            GATE_LED_2: ddOut <= led_2;
            GATE_LED_3: ddOut <= led_3;
            default: ddOut <= {LED_DATA_WIDTH{1'b0}};
            endcase
        end
    end

endmodule


module DD_Driver(
    output DD_OutArray dstArray,
    output DD_GateArray gateArray,
    input  DD_InArray  srcArray,
    input    logic    clk,
    input    logic    rst
);
    
    generate 
    
        genvar i;

        for( i = 0; i < 2; i = i + 1 ) begin    : DD
            DynamicDisplay
                DD_Driver( 
                    dstArray[i * DD_OUT_WIDTH +: DD_OUT_WIDTH], 
                    gateArray[i * DD_GATE_WIDTH +: DD_GATE_WIDTH],
                    srcArray[i * DD_IN_WIDTH +: DD_IN_WIDTH],
                    clk,
                    rst
                );
         end
         
    endgenerate

endmodule

module OLED_Driver(
    input logic clk,
    input logic writeOLED,
    input logic updateOLED,
    input logic clearOLED,
    input logic [7:0] ch,
    input logic [8:0] index,
    input logic[7:0] writeData,
    input DataPath curCycle,
    output logic oledReady,
	output logic oledDC,
	output logic oledRES,
	output logic oledSCLK,
	output logic oledSDIN,
	output logic oledVBAT,
	output logic oledVDD,
    output logic[7:0] debugLed
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
    localparam clearWait  = 8;

    logic [7:0] regWriteData;
    logic regWrite;
    logic [8:0] regIndex;
    logic [7:0] regCycle[8];

    logic [7:0] writeBuffer[0:3][0:15] = '{
        '{"C", "y", "c", "l", "e", ":", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "}, 
        '{"S", "i", "z", "e", ":", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "}, 
        '{"A", "d", "d", "r", ":", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "}, 
        '{"D", "a", "t", "a", ":", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "}
    };
    always@(posedge clk) begin
        if (regWrite) begin
            writeBuffer[regIndex[8:7]][regIndex[6:3]] <= regWriteData;
        end
        regIndex <= index;
        regWrite <= writeOLED;
        regWriteData <= writeData;
        for (int i = 0; i < 8; i++) begin
            regCycle[7-i] <= ConvertToASCII(curCycle[4*i +: 4]);
        end
        writeBuffer[0][8:15] <= regCycle;
    end
    
    localparam AUTO_START = 1; // determines whether the OLED will be automatically initialized when the board is programmed
    	
    //state machine registers.
    reg [3:0] state = (AUTO_START == 1) ? Init : Idle;
    reg [5:0] count = 0;//loop index variable
        
    //oled control signals
    //command start signals, assert high to start command
    reg        update_start = 0;        //update oled display over spi
    reg        disp_on_start = AUTO_START;       //turn the oled display on
    reg        disp_off_start = 0;      //turn the oled display off
    reg        toggle_disp_start = 0;   //turns on every pixel on the oled, or returns the display to before each pixel was turned on
    reg        write_start = 0;         //writes a character bitmap into local memory
    //data signals for oled controls
    reg        update_clear = 0;        //when asserted high, an update command clears the display, instead of filling from memory
    reg  [8:0] write_base_addr = 0;     //location to write character to, two most significant bits are row position, 0 is topmost. bottom seven bits are X position, addressed by pixel x position.
    reg  [7:0] write_ascii_data = 0;    //ascii value of character to write to memory
    //active high command ready signals, appropriate start commands are ignored when these are not asserted high
    wire       disp_on_ready;
    wire       disp_off_ready;
    wire       toggle_disp_ready;
    wire       update_ready;
    wire       write_ready;
    logic [8:0] tmp_addr;
    
    //debounced button signals used for state transitions
    wire       rst;     // CPU RESET BUTTON turns the display on and off, on display_on, local memory is filled from string parameters
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
    
//    assign ch = 8'h54;
    assign init_done = disp_off_ready | toggle_disp_ready | write_ready | update_ready;//parse ready signals for clarity
    assign init_ready = disp_on_ready;
    assign tmp_addr = write_base_addr + 8;
    always@(posedge clk)
        case (state)
            Idle: begin
                if (rst == 1'b1 && init_ready == 1'b1) begin
                    disp_on_start <= 1'b1;
                    state <= Init;
                end
            end
            Init: begin
                disp_on_start <= 1'b0;
                if (rst == 1'b0 && init_done == 1'b1)
                    state <= Active;
            end
            Active: begin // hold until ready, then accept input
                if (rst && disp_off_ready) begin
                    disp_off_start <= 1'b1;
                    state <= Done;
                end else if (write_ready) begin
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
                        write_ascii_data <= writeBuffer[tmp_addr[8:7]][tmp_addr[6:3]];
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
                if (rst == 1'b0 && init_ready == 1'b1)
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
    
    output DD_OutArray        led,    // 7seg
    output DD_GateArray    gate,    // 7seg gate
    output LampPath         lamp,    // Lamp?

    input DataAddrPath addr,            // データアドレス
    input DataPath     dataFromCPU,    // データ本体
    input DataPath     dataFromDMem,    // データメモリ読み出し結果
    input logic         weFromCPU,        // 書き込み

    input logic sigCH, // btnC
    input logic btnU, // btnU
    input logic sigCP, // btnD
    input logic btnL,

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
        
        // Input signals of the LED driver.
        // (W)
        LED_InArray led;
        
        // Cycle count
        logic        enableCycleCount;    // (W)
        CyclePath  cycleCount;            // (N/A)
        
        // Indicates start of sort.
        // This register is set when the 'btnc' is asserted and 
        // is not changed after being set.
        logic sortStart;
        
        // Externnal switches
        // (R)
        logic btnu;
        logic btnc;
        logic cp;
        // LampPath ledOut;
    } ctrlReg, ctrlNext, ctrlInit;

    // Output buffer
    struct packed {
        LED_OutArray led;
        LampPath lamp;
        logic [7:0] ch;
        logic [8:0] oledIndex;
        logic writeOLED;
        logic updateOLED;
        logic clearOLED;
    } outReg, outNext;

    struct packed {
        logic [7:0] ch;
        logic [8:0] oledIndex;
        logic writeOLED;
    } oledCtrlReg, oledCtrlNext;
    
    // Indicates whether an address is IO or not.
    logic isIO;
    
    logic writeOLED;
    logic updateOLED;
    logic clearOLED;
    logic [7:0] write_ascii_data;
    logic [8:0] write_base_addr;
    logic oledReady;
    // LED Driver
    LED_InArray  ledDrvIn;        // 4-bitx8 input
    LED_OutArray ledDrvOut;    // 7-bitx8 output
    LED_Driver ledDrv0( ledDrvOut, ledDrvIn );

    logic [5:0] wrIndex;
    logic[7:0] writeData;
    logic [2:0] offset;
    
    // Dynamic Display
    DD_OutArray    ddDrvOut;
    DD_GateArray        ddDrvGate;
    DD_Driver ddDrv0( ddDrvOut, ddDrvGate, outReg.led, clk, rst );

    logic [7:0] debugLed, ledTest;

    OLED_Driver oledDrv0 (
        .clk(clk),
        .writeOLED(writeOLED),
        .updateOLED(updateOLED),
        .clearOLED (clearOLED),
        .ch(write_ascii_data),
        .writeData(writeData),
        .curCycle (ctrlReg.cycleCount),
        .index(write_base_addr),
        .oledReady(oledReady),
        .oledDC(oledDC),
        .oledRES(oledRES),
        .oledSCLK(oledSCLK),
        .oledSDIN(oledSDIN),
        .oledVBAT(oledVBAT),
        .oledVDD(oledVDD),
        .debugLed (debugLed)
    );

    //
    // Controll ロジック
    //
    always_comb begin
    
        //
        // --- IO / Data memory 判定
        //
        if( addr[IO_ADDR_BIT_POS] ) begin
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
        offset = 0;
        writeOLED = FALSE;
        write_base_addr = 0;
        write_ascii_data = 0;
        writeData = ConvertToASCII(dataFromCPU[3:0]);
        offset = 3'b111 - addr[4:2];

        // 書き込み
        if( isIO && weFromCPU ) begin
            writeOLED = addr[7];
            if (addr[6:5] == 2'b00) begin
                write_base_addr = {3'b001, offset, 3'b000};
                writeOLED = TRUE;
            end
            else if (addr[6:5] == 2'b01) begin
                write_base_addr = {3'b011, offset, 3'b000};
                writeOLED = TRUE;
            end
            else if (addr[6:5] == 2'b10) begin
                write_base_addr = {3'b101, offset, 3'b000};
                writeOLED = TRUE;
            end
            else if (addr[6:5] == 2'b11) begin
                write_base_addr = {3'b111, offset, 3'b000};
                writeOLED = TRUE;
            end
            case( PICK_IO_ADDR( addr ) ) 

                IO_ADDR_SORT_FINISH:    ctrlNext.sortFinish = dataFromCPU[0];
                IO_ADDR_SORT_COUNT:     ctrlNext.sortCount  = dataFromCPU;
                IO_ADDR_LAMP:           ctrlNext.lamp       = dataFromCPU[ LAMP_WIDTH-1 : 0 ];

                default: begin
                end
            endcase    // case( addr ) 

        end    // if( isIO && weFromCPU ) begin
                    
                    
        // 読み出し
        if( isIO ) begin

            // IO
            case( PICK_IO_ADDR( addr ) ) 
                IO_ADDR_SORT_START: dataToCPU[0] = sigCH;
                IO_ADDR_BTNU: dataToCPU[0] = btnU;
                IO_ADDR_CP: dataToCPU[0] = ctrlReg.cp;
                IO_ADDR_CH: dataToCPU[0] = ctrlReg.btnc;        // ソートスタート
                IO_ADDR_CYCLE: dataToCPU = ctrlReg.cycleCount;
                default:     dataToCPU = {DATA_WIDTH{1'bx}};
            endcase
        end else
        begin

            // データメモリ
            dataToCPU = dataFromDMem;

        end
        
        
        // LED ドライバ
        if( ctrlReg.ledCtrl == LED_CTRL_USER ) begin
            ledDrvIn = ctrlReg.led;
        end
        else begin
            ledDrvIn = ctrlReg.cycleCount;
        end
        
        
        // サイクルカウント
        if( ( ctrlReg.btnc || ctrlReg.enableCycleCount ) &&
            !ctrlReg.sortFinish
        ) begin
            ctrlNext.cycleCount = ctrlReg.cycleCount + 1'h1;
            ctrlNext.enableCycleCount = TRUE;
            ctrlNext.sortStart = TRUE;
        end
        
        
        // Switchs
        // btnc/CE/CP
        ctrlNext.btnc = sigCH;
        ctrlNext.btnu = btnU;
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
        // lamp = {{4'b0}, sigCH, btnU, sigCP, btnL};

        // writeOLED = outReg.writeOLED;
        // write_ascii_data = ConvertToASCII(outReg.ch[3:0]);
        // write_base_addr = outReg.oledIndex;
        updateOLED = outReg.updateOLED;
        clearOLED = outReg.clearOLED;
        // lamp = write_ascii_data;
        // ledOut = ctrlReg.ledOut;
        
        //
        // リセット
        //
        ctrlInit = 0;
        // ctrlInit.btnc = 1'b1;
        // ctrlInit.cp = 1'b1;
        // ctrlInit.ce = 1'b1;
     end
    

    //
    // --- レジスタ
    //
    always_ff @( posedge clk or negedge rst) begin
        if( !rst ) begin
            ctrlReg <= ctrlInit;
            outReg  <= 0;
            ledTest <= 0;
        end
        else begin
            ctrlReg <= ctrlNext;
            outReg  <= outNext;
            // if (btnU)
            //     ledTest <= ledTest + 1;
        end
    end


endmodule

