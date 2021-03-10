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

	PC pc(
		.addrOut ( pcOut ),

		.clk ( clk ),
		.rst ( rst ),
		.addrIn ( pcIn ),
		.wrEnable ( pcWrEnable )
	);

	BranchUnit branch(
		.pcOut ( pcIn ),
		.pcIn ( pcOut ),
		.BrCodePath ( dcBrCode ),
		.regRS ( dcRS ),
		.regRT ( dcRT ),
		.constant ( dcConstant )
	);

	Decoder decoder(
		.op ( dcOp ),
		.rs ( dcRS ),
		.rt ( dcRT ),
		.rd ( dcRD ),
		.shamt ( dcShamt ),
		.funct ( dcFunct ),
		.constant ( dcConstant ),
		.aluCode ( dcALUCode ),
		.brCode ( dcBrCode ),
		.pcWrEnable ( pcWrEnable ),
		.isLoadInsn ( dcIsLoadInsn ),
		.isStoreInsn ( dcIsStoreInsn ),
		.isSrcA_Rt ( dcIsSrcA_Rt ),
		.isDstRt ( dcIsDstRt ),
		.rfWrEnable ( rfWrEnable ),
		.isALUInConstant ( dcIsALUInConstant ),

		.insn ( imemInsnCode )
	);

	RegisterFile regFile(
		.rdDataA ( rfRdDataS ),
		.rdDataB ( rfRdDataT ),

		.clk ( clk ),
		.rdNumA ( dcRS ),
		.rdNumB ( dcRT ),
		.wrData ( rfWrData ),
		.wrNum ( rfWrNum ),
		.wrEnable ( rfWrEnable )
	);

	ALU alu(
		.aluOut ( aluOut ),
		
		.aluInA ( aluInA ),
		.aluInB ( aluInB ),
		.code ( dcALUCode )
	);

	always_comb begin
		imemInsnCode = insn;
		insnAddr = pcOut;

		dataOut = rfRdDataT;
		dataAddr = rfRdDataS[ `DATA_ADDR_WIDTH - 1 : 0 ] + `EXPAND_ADDRESS( dcConstant );

		rfWrData = dcIsLoadInsn ? dataIn : aluOut;
		rfWrNum = dcIsDstRt ? dcRT : dcRD;

		aluInA = dcIsSrcA_Rt ? rfRdDataT : rfRdDataS;
		aluInB = dcIsALUInConstant ? dcConstant : rfRdDataT;

		dataWrEnable = dcIsStoreInsn;
	end

endmodule

