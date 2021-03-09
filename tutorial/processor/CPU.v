`include "Types.v"

module CPU(

	input logic clk,	// クロック
	input logic rst,	// リセット
	
	output `InsnAddrPath insnAddr,		// 命令メモリへのアドレス出力
	output `DataAddrPath dataAddr,		// データバスへのアドレス出力
	output `DataPath     dataOut,		// 書き込みデータ出力
										// dataAddr で指定したアドレスに対して書き込む値を出力する．
	output logic         dataWrEnable,	// データ書き込み有効

	input  `InsnPath 	 insn,			// 命令メモリからの入力
	input  `DataPath     dataIn			// 読み出しデータ入力
										// dataAddr で指定したアドレスから読んだ値が入力される．
);
	
	//PC
	`InsnAddrPath pcOut;
	`InsnAddrPath pcIn;
	logic pcWrEnable;

	//IMem
	`InsnPath imemInsnCode;

	//Decoder
	`OpPath dcOp;
	`RegNumPath dcRS;
	`RegNumPath dcRT;
	`RegNumPath dcRD;
	`ShamtPath dcShamt;
	`FunctPath dcFunct;
	`ConstantPath dcConstant;
	`ALUCodePath dcALUCode;
	`BrCodePath dcBrCode;
	logic dcIsSrcA_Rt;
	logic dcIsDstRt;
	logic dcIsALUInConstant;
	logic dcIsLoadInsn;
	logic dcIsStoreInsn;

	//Register files
	`DataPath rfRdDataS;
	`DataPath rfRdDataT;
	`DataPath rfWrData;
	`RegNumPath rfWrNum;
	logic rfWrEnable;

	//ALU
	`DataPath aluOut;
	`DataPath aluInA;
	`DataPath aluInB;

	logic brTaken;



endmodule

