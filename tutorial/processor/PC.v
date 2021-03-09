`include "Types.v"

module PC(
    input logic clk,
    input logic rst,
    output `InsnAddrPath addrOut,

    input `InsnAddrPath addrIn,
    input logic wrEnable
);

    `InsnAddrPath pc;
    always_ff @(posedge clk or negedge rst) begin
        if(!rst) begin
            pc <= `INSN_RESET_VECTOR;
        end
        else if(wrEnable) begin
            pc <= addrIn;
        end
        else begin
            pc <= pc + `INSN_PC_INC;
        end
    end

    assign addrOut = pc;
endmodule