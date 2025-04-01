//
// クロック分周器
// 1/4 クロックを作る
//


import BasicTypes::*;
import Types::*;

module ClockDivider(
    output logic clk,
    input  logic rst,
    input  logic clkX4
);

//`define RIPPLE_CLOCK_DIVIDER

`ifdef RIPPLE_CLOCK_DIVIDER

    logic clkRegX2;
    logic clkRegX4;

    always_ff @(posedge clkX4 or posedge rst) begin
        if (rst) begin
            clkRegX2 <= 1'b0;
        end
        else begin
            clkRegX2 <= !clkRegX2;
        end
    end

    always_ff @(posedge clkRegX2 or posedge rst) begin
        if (rst) begin
            clkRegX4 <= 1'b0;
        end
        else begin
            clkRegX4 <= !clkRegX4;
        end
    end
    
    assign clk = clkRegX4;

`else
    logic [1:0] state;
    logic clkReg;
    
    parameter STATE_0 = 0;
    parameter STATE_1 = 1;
    parameter STATE_2 = 2;
    parameter STATE_3 = 3;

    always_ff @( posedge clkX4 or posedge rst ) begin
        
        if (rst) begin
            state  <= STATE_0;
            clkReg <= 0;
        end
        else begin
            case( state ) 
            default: state <= STATE_1;
            STATE_1: state <= STATE_2;
            STATE_2: state <= STATE_3;
            STATE_3: state <= STATE_0;
            endcase


            case( state ) 
            default: clkReg <= 1;
            STATE_1: clkReg <= 1;
            STATE_2: clkReg <= 0;
            STATE_3: clkReg <= 0;
            endcase
        end
    end

    always_comb begin
        clk = clkReg;
    end

`endif

endmodule
        
        