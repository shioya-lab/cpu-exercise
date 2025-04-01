//
// 命令メモリ
//

import BasicTypes::*;
import Types::*;

module IMem(
    input     logic clk,    // クロック
    input     logic rst,    // リセット
    
    output    InsnPath       insn,
    input     InsnAddrPath addr
);

    InsnPath mem[ 0 : INSN_MEM_SIZE-1 ];
    InsnAddrPath addrLatch;

    always_ff @(posedge clk) begin
        if (rst) begin
            addrLatch <= '0;
        end
        else begin
            addrLatch <= addr;
        end
    end
    
    assign insn = mem[ addrLatch[ INSN_MEM_OFFSET +: INSN_MEM_WIDTH ] ];

    // 命令データの読み込み
    initial begin
`ifdef VIVADO_SYNTHESIS
        $readmemh( "IMem.dat", mem );
`elsif VIVADO_SIMULATION
        $readmemh( "../IMem.dat", mem );
`else 
        $readmemh( "./IMem.dat", mem );
`endif
    end

endmodule

