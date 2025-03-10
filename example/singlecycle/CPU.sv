
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
    OpInfo dcOpinfo;
    OpPath dcOp;                // OP フィールド
    RegNumPath rs1;            // RS フィールド
    RegNumPath rs2;            // RT フィールド
    RegNumPath dcRD;            // RD フィールド
    ShamtPath dcShamt;            // SHAMT フィールド
    FunctPath dcFunct;            // FUNCT フィールド
    ConstantPath dcConstat;    // CONSTANT フィールド

    // Controll
    ALUCodePath aluCode;        // ALU の制御コード
    BrCodePath dcBrCode;        // ブランチの制御コード
    logic dcIsSrcA_Rt;            // ソースの1個目が Rt かどうか
    logic dcIsDstRt;            // ディスティネーションがRtかどうか
    logic dcIsALUInConstant;    // ALU の入力が Constant かどうか
    logic dcIsLoadInsn;            // ロード命令かどうか
    logic dcIsStoreInsn;        // ストア命令かどうか

    // レジスタ・ファイル
    DataPath rfRdData1;        // 読み出しデータ rs
    DataPath rfRdData2;        // 読み出しデータ rt
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
        brTaken,
        pcOut,
        dcOpinfo.funct3,
        rfRdData1,
        rfRdData2,
        dcOpinfo.constant
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
        aluCode,
        dcOpinfo.funct7
    );
    

    // Connections & multiplexers
    always_comb begin
        
        // IMem
        imemInsnCode = insn;
        insnAddr     = pcOut;

        pcWrEnable = brTaken && dcOpinfo.isBranch;
        
        // Data memory
        dataOut  = rfRdData2;
        dataAddr = EXPAND_ADDRESS(rfRdData1 + dcOpinfo.constant);
        
        // Register write data
        rfWrData = dcOpinfo.isLoad ? dataIn : aluOut;
        
        // Register write num
        rfWrNum = dcOpinfo.rd;

        // ALU
        aluInA = rfRdData1;
        aluInB = dcOpinfo.isALUInConstant ? dcOpinfo.constant : rfRdData2;
        if (dcOpinfo.isALUInConstant && dcOpinfo.funct7 == OP_FUNCT7_SUB) begin
            aluInB = -aluInB;
        end
        aluCode = dcOpinfo.funct3;

        // DMem write enable
        dataWrEnable = dcOpinfo.isStore;
        
     end
    

endmodule

