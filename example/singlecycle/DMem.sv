//
// データメモリ
//

import BasicTypes::*;
import Types::*;

module DMem(
    input logic clk,    // クロック
    input logic rst,    // リセット
    
    output DataPath dataOut,
        
    input DataAddrPath addr,
    input DataPath     dataIn,
    input logic         wrEnable
);
    
    DataPath mem[ 0 : DATA_MEM_SIZE-1 ];
    DataMemPath addrLatch;
    DataPath    dataLatch;
    logic        weLatch;

    always_ff @( posedge clk ) begin
        if (rst) begin
            addrLatch <= '0;
            dataLatch <= '0;
            weLatch   <= FALSE;
        end
        else begin
            addrLatch <= addr[ DATA_MEM_OFFSET +: DATA_MEM_ADDR_WIDTH ];
            dataLatch <= dataIn;
            weLatch   <= wrEnable;
        end
        
        if (weLatch) begin
            mem[ addrLatch ] <= dataLatch;
        end
    end
    
    assign dataOut = mem[ addrLatch ];

    // データの読み込み
    initial begin
`ifdef VIVADO_SYNTHESIS
        $readmemh( "DMem.dat", mem );
`elsif VIVADO_SIMULATION
        $readmemh( "../DMem.dat", mem );
`else
        $readmemh( "./DMem.dat", mem );
`endif
    end


endmodule

