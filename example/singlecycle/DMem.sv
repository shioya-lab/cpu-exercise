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

// `ifdef MODEL_TECH
    
    //
    // ModelSim 用コード
    //
    
    DataPath mem[ 0 : DATA_MEM_SIZE-1 ];
    DataMemPath addrLatch;
    DataPath    dataLatch;
    logic        weLatch;

    always_ff @( posedge clk ) begin
        
        if( !rst ) begin
            addrLatch <= {DATA_MEM_ADDR_WIDTH{1'b0}};
            dataLatch <= {DATA_WIDTH{1'b0}};
            weLatch   <= FALSE;
        end
        else begin
            addrLatch <= addr[ DATA_MEM_OFFSET +: DATA_MEM_ADDR_WIDTH ];
            dataLatch <= dataIn;
            weLatch   <= wrEnable;
        end
        
        if( weLatch )
            mem[ addrLatch ] <= dataLatch;
    end
    
    assign dataOut = mem[ addrLatch ];

    // データの読み込み
    integer i;
    initial    begin
`ifdef VIVADO_SIMULATION
        $readmemh( "../DMem.dat", mem );
`else
        $readmemh( "./DMem.dat", mem );
`endif
    end

// `else 
    
//     //
//     // Altera QuartusII
//     //

//     lpm_ram_dq
//         body(
//             .address( addr[ DATA_MEM_OFFSET +: DATA_MEM_ADDR_WIDTH ] ),
//             .inclock( clk      ),
//             .data   ( dataIn   ),
//             .we     ( wrEnable ),
//             .q      ( dataOut  )
//             //.outclock( 1'b1 )
//         );
        
//     defparam
//         body.intended_device_family = "APEX20KE",
//         body.lpm_address_control    = "REGISTERED",
//         body.lpm_file    = "../DMem.mif",
//         body.lpm_indata  = "REGISTERED",
//         body.lpm_outdata = "UNREGISTERED",
//         body.lpm_type    = "LPM_RAM_DQ",
//         body.lpm_width   = DATA_WIDTH,
//         body.lpm_widthad = DATA_MEM_ADDR_WIDTH;

// `endif

endmodule

