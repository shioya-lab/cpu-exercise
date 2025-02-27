
import BasicTypes::*;
import Types::*;

module CPU(

    input logic clk,    // クロック
    input logic rst,    // リセット
    
    output InsnAddrPath insnAddr,        // 命令メモリへのアドレス出力
    output DataAddrPath dataAddr,        // データバスへのアドレス出力
    output DataPath     dataOut,        // 書き込みデータ出力
                                        // dataAddr で指定したアドレスに対して書き込む値を出力する．
    output logic         dataWrEnable,    // データ書き込み有効

    input  InsnPath      insn,            // 命令メモリからの入力
    input  DataPath     dataIn            // 読み出しデータ入力
                                        // dataAddr で指定したアドレスから読んだ値が入力される．
);
    
    // PC
    InsnAddrPath pcOut;        // アドレス出力
    InsnAddrPath pcIn;            // 外部書き込みをする時のアドレス
    logic pcWrEnable;            // 外部書き込み有効
    
    // IMem
    InsnPath imemInsnCode;        // 命令コード
    
    // Decoder
    OpPath dcOp;                // OP フィールド
    RegNumPath dcRS;            // RS フィールド
    RegNumPath dcRT;            // RT フィールド
    RegNumPath dcRD;            // RD フィールド
    ShamtPath dcShamt;            // SHAMT フィールド
    FunctPath dcFunct;            // FUNCT フィールド
    ConstantPath dcConstat;    // CONSTANT フィールド

    // Controll
    ALUCodePath dcALUCode;        // ALU の制御コード
    BrCodePath dcBrCode;        // ブランチの制御コード
    logic dcIsSrcA_Rt;            // ソースの1個目が Rt かどうか
    logic dcIsDstRt;            // ディスティネーションがRtかどうか
    logic dcIsALUInConstant;    // ALU の入力が Constant かどうか
    logic dcIsLoadInsn;            // ロード命令かどうか
    logic dcIsStoreInsn;        // ストア命令かどうか

    // レジスタ・ファイル
    DataPath rfRdDataS;        // 読み出しデータ rs
    DataPath rfRdDataT;        // 読み出しデータ rt
    DataPath   rfWrData;        // 書き込みデータ
    RegNumPath rfWrNum;        // 書き込み番号
    logic       rfWrEnable;        // 書き込み制御 1の場合，書き込みを行う
    
    // ALU
    DataPath aluOut;            // ALU 出力
    DataPath aluInA;            // ALU 入力A
    DataPath aluInB;            // ALU 入力B
    
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
        pcIn,    // BranchUnit への入力は in と out が逆になるのを注意
        pcOut,
        dcBrCode,
        rfRdDataS,
        rfRdDataT,
        dcConstat
    );
    

    // Decoder
    Decoder decoder(
        dcOp,
        dcRS,
        dcRT,
        dcRD,
        dcShamt,
        dcFunct,
        dcConstat,    
        dcALUCode,
        dcBrCode,
        pcWrEnable,            // PC 書き込みを行うかどうか
        dcIsLoadInsn,        // ロード命令かどうか
        dcIsStoreInsn,        // ストア命令かどうか
        dcIsSrcA_Rt,        // ソースの1個目が Rt かどうか
        dcIsDstRt,            // ディスティネーションがRtかどうか
        rfWrEnable,            // ディスティネーション書き込みを行うかどうか
        dcIsALUInConstant,    // ALU の入力が Constant かどうか
        imemInsnCode
    );
    
    // RegisterFile
    RegisterFile regFile(
        clk,
        rfRdDataS,
        rfRdDataT,
        dcRS,
        dcRT,
        rfWrData,
        rfWrNum,
        rfWrEnable
    );
    
    // ALU
    ALU alu(
        aluOut,
        aluInA,
        aluInB,
        dcALUCode
    );
    

    // Connections & multiplexers
    always_comb begin
        
        // IMem
        imemInsnCode = insn;
        insnAddr     = pcOut;
        
        // Data memory
        dataOut  = rfRdDataT;
        dataAddr = rfRdDataS[ DATA_ADDR_WIDTH - 1 : 0 ] + EXPAND_ADDRESS( dcConstat );
        
        // Register write data
        rfWrData = dcIsLoadInsn ? dataIn : aluOut;
        
        // Register write num
        rfWrNum = dcIsDstRt ? dcRT : dcRD;

        // ALU
        aluInA = dcIsSrcA_Rt ? rfRdDataT : rfRdDataS;
        aluInB = dcIsALUInConstant ? dcConstat : rfRdDataT;

        // DMem write enable
        dataWrEnable = dcIsStoreInsn;
        
     end
    

endmodule

