
`include "Types.v" 
module H3_RegAdderSim;

	parameter CYCLE_TIME = 10; // 1サイクルを 10ns に設定

    integer cycle;
    logic clk;

    `DataPath dataA;
    `DataPath dataB;
    `DataPath dataout;

    RegAdder regadder(
        .clk (clk),
        .dA (dataA),
        .dB (dataB),
        .out (dataout)
    );


	initial begin 
		clk <= 1'b1;
		cycle <= 0;
		
		// 半サイクルごとに clk を反転
	    forever #(CYCLE_TIME / 2) begin
	    	clk <= !clk ;
	    	cycle <= cycle + 1;
	    end
	end


    initial begin
        dataA = 1;
        dataB = 2;
        #360;
        $finish;
    end
endmodule