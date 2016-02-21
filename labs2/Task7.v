//////////////////////////////////////////
//DECODER
///////////////////////////////////////////
module decoder(i_data, o_data);

parameter WIDTH = 2;

input  [WIDTH-1:0] 	 i_data;
output [2**WIDTH-1:0] o_data; 

genvar i;

generate
  for ( i = 0; i < 2**WIDTH; i = i + 1 ) begin: DC
    assign o_data[i] = (i_data==i) ? 1'b1 : 1'b0;
  end
endgenerate

endmodule
/////////////////////////////////////
//MULTIPLEXER
/////////////////////////////////////
module mux( i_sel, i_d0, i_d1, i_d2, i_d3, i_d4, o_data);

parameter WIDTH = 4;

input [2:0]   					i_sel;
input [WIDTH-1:0]  i_d0,i_d1,i_d2,i_d3,i_d4;
output[WIDTH-1:0]  o_data;

wire  [7:0] 				   one_hot;
genvar i;

decoder	 #( .WIDTH ( 3 ) ) decoder_inst (.i_data( i_sel ),
														.o_data( one_hot )													
													   );
generate
	for( i = 0; i < WIDTH; i = i + 1) begin: MUX
		assign o_data[i] = ((one_hot[0] & i_d0[i])|
								  (one_hot[1] & i_d1[i])|
								  (one_hot[2] & i_d2[i])|
								  (one_hot[3] & i_d3[i])|
								  (one_hot[4] & i_d4[i])
								  );
	end
	
endgenerate



endmodule
