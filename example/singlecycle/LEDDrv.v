//
// LED Driver
//

`include "Types.v"

`define LED_OUT_0 	8'b0011_1111
`define LED_OUT_1 	8'b0000_0110
`define LED_OUT_2 	8'b0101_1011
`define LED_OUT_3 	8'b0100_1111
`define LED_OUT_4 	8'b1110_0110
`define LED_OUT_5 	8'b1110_1101
`define LED_OUT_6 	8'b1111_1101
`define LED_OUT_7 	8'b0010_0111
`define LED_OUT_8 	8'b0111_1111
`define LED_OUT_9 	8'b0110_1111
`define LED_OUT_A 	8'b0111_0111
`define LED_OUT_B 	8'b0111_1100
`define LED_OUT_C 	8'b0101_1000
`define LED_OUT_D 	8'b0101_1110
`define LED_OUT_E 	8'b0111_1001
`define LED_OUT_F	8'b0111_0001
//`define LED_OUT_ERR 8'b0011_1001


`define LED_IN_0 	4'h0
`define LED_IN_1 	4'h1
`define LED_IN_2 	4'h2
`define LED_IN_3 	4'h3
`define LED_IN_4 	4'h4
`define LED_IN_5 	4'h5
`define LED_IN_6 	4'h6
`define LED_IN_7 	4'h7
`define LED_IN_8 	4'h8
`define LED_IN_9 	4'h9
`define LED_IN_A 	4'ha
`define LED_IN_B 	4'hb
`define LED_IN_C 	4'hc
`define LED_IN_D 	4'hd
`define LED_IN_E 	4'he
`define LED_IN_F	4'hf


module SevenSegDriver(
	output `LED_OutPath ssOut,
	input  `LED_InPath  ssIn
);

	always_comb begin
		case( ssIn )
		default :  ssOut = `LED_OUT_0;
		`LED_IN_1: ssOut = `LED_OUT_1;
		`LED_IN_2: ssOut = `LED_OUT_2;
		`LED_IN_3: ssOut = `LED_OUT_3;
		`LED_IN_4: ssOut = `LED_OUT_4;
		`LED_IN_5: ssOut = `LED_OUT_5;
		`LED_IN_6: ssOut = `LED_OUT_6;
		`LED_IN_7: ssOut = `LED_OUT_7;
		`LED_IN_8: ssOut = `LED_OUT_8;
		`LED_IN_9: ssOut = `LED_OUT_9;
		`LED_IN_A: ssOut = `LED_OUT_A;
		`LED_IN_B: ssOut = `LED_OUT_B;
		`LED_IN_C: ssOut = `LED_OUT_C;
		`LED_IN_D: ssOut = `LED_OUT_D;
		`LED_IN_E: ssOut = `LED_OUT_E;
		`LED_IN_F: ssOut = `LED_OUT_F;
		endcase
 	end
	

endmodule



module LED_Driver(
	output `LED_OutArray dstArray,
	input  `LED_InArray  srcArray
);
	

	generate 
	
		genvar i;

		for( i = 0; i < 8; i = i + 1 ) begin : SevenSeg
			SevenSegDriver 
				ssDriver( 
					`LED_OutArrayAt( dstArray, i ), 
					`LED_InArrayAt(  srcArray, i ) 
				);
	 	end
	 	
	endgenerate

endmodule

