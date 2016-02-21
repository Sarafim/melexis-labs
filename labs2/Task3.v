`timescale 1ns/1ps

module subtractor ( i_a, i_b, i_borr, o_sub, o_borr);

parameter WIDTH = 4;

input  [WIDTH-1:0] i_a, i_b;
input 				 i_borr;
output [WIDTH-1:0] o_sub;
output 				 o_borr;

wire   [WIDTH-2:0] borr;
wire	 [WIDTH-1:0] i_b_n;

assign i_b_n = ~i_b;

genvar i;

generate
	for( i = 0; i < WIDTH; i = i + 1)begin:SUBTRACTOR
		if( i == 0)
		begin
			assign o_sub[i] = i_a[i] ^ i_b_n[i] ^ i_borr;
			assign borr [i] = ( i_a[i] & i_b_n[i] )|( ( i_a[i] ^ i_b_n[i] ) & i_borr );
		end	
		else if( i == ( WIDTH-1 ) )
		begin
			assign o_sub[i] = i_a[i] ^ i_b_n[i] ^ borr[i-1];
			assign o_borr   = ( i_a[i] & i_b_n[i] )|( ( i_a[i] ^ i_b_n[i] ) & borr[i-1] );
		end
		else
		begin
			assign o_sub[i] = i_a[i] ^ i_b_n[i] ^ borr[i-1];
			assign borr [i] = ( i_a[i] & i_b_n[i] )|( ( i_a[i] ^ i_b_n[i] ) & borr[i-1] );
		end
	end
endgenerate
endmodule
