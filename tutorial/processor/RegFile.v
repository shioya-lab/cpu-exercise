`include "Types.v"

module RegisterFile(
    input logic clk,

    output `DataPath rdDataA,
    output `DataPath rdDataB,

    input `RegNumPath rdNumA,
    input `RegNumPath rdNumB,

    input `DataPath wrData,
    input `RegNumPath wrNum,

    input logic wrEnable,
);
    `Data storage[ 0 : `REG_FILE_SIZE - 1 ];

    always_ff @( posedge clk) begin
        if (wrEnable) begin
            storage[wrNum] <= wrData;
        end
    end

    always_comb begin
        rdDataA = storage[rdNumA];
        rdDataB = storage[rdNumB];
    end
endmodule