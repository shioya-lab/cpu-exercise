
import BasicTypes::*;
import Types::*;

module CPU(
    input logic clk,    // クロック
    input logic rst,    // リセット
    
    output InsnAddrPath insnAddr,       // 命令メモリへのアドレス出力
    output DataAddrPath dataAddr,       // データバスへのアドレス出力
    output DataPath     dataOut,        // 書き込みデータ出力
                                        // dataAddr で指定したアドレスに対して書き込む値を出力する．
    output logic        dataWrEnable,   // データ書き込み有効

    input  InsnPath     insn,           // 命令メモリからの入力
    input  DataPath     dataIn          // 読み出しデータ入力
                                        // dataAddr で指定したアドレスから読んだ値が入力される．
);
    
    // PC
    InsnAddrPath pcOut;        // アドレス出力
    InsnAddrPath pcIn;         // 外部書き込みをする時のアドレス
    logic pcWrEnable;          // 外部書き込み有効
    
    // IMem
    InsnPath imemInsnCode;     // 命令コード
    
    // Decoder
    OpInfo dcOpinfo;

    // レジスタ・ファイル
    DataPath rfRdData1;        // 読み出しデータ rs
    DataPath rfRdData2;        // 読み出しデータ rt
    DataPath   rfWrData;       // 書き込みデータ
    RegNumPath rfWrNum;        // 書き込み番号
    logic       rfWrEnable;    // 書き込み制御 1の場合，書き込みを行う
    
    // ALU
    DataPath aluOut;           // ALU 出力
    DataPath aluInA;           // ALU 入力A
    DataPath aluInB;           // ALU 入力B
    
    // Branch
    logic brTaken;

    // PC
    PC pc(
        clk,
        rst,
        pcOut,
        pcIn,
        pcWrEnable
    );

    // Branch Unit
    BranchUnit branch(
        brTaken,
        dcOpinfo.funct3,
        rfRdData1,
        rfRdData2
    );
    

    // Decoder
    Decoder decoder(
        dcOpinfo,
        imemInsnCode
    );
    
    // RegisterFile
    RegisterFile regFile(
        clk,
        rfRdData1,
        rfRdData2,
        dcOpinfo.rs1,
        dcOpinfo.rs2,
        rfWrData,
        rfWrNum,
        dcOpinfo.regWrEnable
    );
    
    // ALU
    ALU alu(
        aluOut,
        aluInA,
        aluInB,
        dcOpinfo.funct3,
        dcOpinfo.funct7
    );
    

    // Connections & multiplexers
    always_comb begin
        
        // IMem
        imemInsnCode = insn;
        insnAddr     = pcOut;

        if (dcOpinfo.isJump) begin
            pcWrEnable = TRUE;
        end
        else if (dcOpinfo.isBranch) begin
            pcWrEnable = brTaken;
        end
        else begin
            pcWrEnable = FALSE;
        end
        pcIn = pcOut + EXPAND_BR_DISPLACEMENT(dcOpinfo.imm);
        
        // Data memory
        dataOut  = rfRdData2;
        dataAddr = GET_ADDR(rfRdData1 + dcOpinfo.imm);
        
        // Register write data
        rfWrData = dcOpinfo.isJump ? {21'b0, pcOut} + INSN_PC_INC:
            (dcOpinfo.isLoad ? dataIn : aluOut);
        
        // Register write num
        rfWrNum = dcOpinfo.rd;

        // ALU
        aluInA = rfRdData1;
        aluInB = dcOpinfo.isALUInImm ? dcOpinfo.imm : rfRdData2;
        if (!dcOpinfo.isALUInImm && dcOpinfo.funct7 == OP_FUNCT7_SUB) begin
            aluInB = -aluInB;
        end

        // DMem write enable
        dataWrEnable = dcOpinfo.isStore;
        
    end

endmodule
