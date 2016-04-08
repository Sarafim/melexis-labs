`timescale 1ns / 1ps
/////////////////////////////////////////////////////////
////// HALF ADDDER
/////////////////////////////////////////////////////////
module half_adder( i_a, i_b, o_sum, o_carry );

input	 i_a, i_b;
output o_sum, o_carry;

assign o_sum = i_a^i_b;
assign o_carry = i_a & i_b; 

endmodule
/////////////////////////////////////////////////////////
////// FULL ADDDER
/////////////////////////////////////////////////////////
module full_adder( i_a, i_b, i_carry, o_sum, o_carry );

input 	i_a, i_b, i_carry;
output 	o_sum, o_carry;

wire 		half_sum, half_carry1, half_carry2;

half_adder half_adder_inst1(.i_a    ( i_a ),
								    .i_b    ( i_b ),
									 .o_sum  ( half_sum ),
									 .o_carry( half_carry1 )
									);
									
half_adder half_adder_inst2(.i_a    ( half_sum ),
									 .i_b    ( i_carry ),
									 .o_sum  ( o_sum ),
									 .o_carry( half_carry2 )
									);		
assign o_carry = half_carry1 | half_carry2;							
									
endmodule
/////////////////////////////////////////////////////////
////// PARAMETRIC ADDER (WIDTH = 4)
/////////////////////////////////////////////////////////
module adder_4bit ( i_a, i_b, i_carry, o_sum, o_carry );

parameter WIDTH = 4;

input  	[WIDTH-1:0] i_a, i_b;
input  				         i_carry;
output 	[WIDTH-1:0] o_sum;
output 				         o_carry;

wire 		[WIDTH-1:0]	carry;

genvar i;

generate
	for( i = 0; i < WIDTH; i = i + 1 )begin: ADDER
		if( i == 0 ) 
					full_adder full_adder (.i_a		( i_a[i] ),
												  .i_b		( i_b[i] ),
												  .i_carry	( i_carry ),
												  .o_sum    ( o_sum[i] ),
												  .o_carry	( carry[i] )
												 );
		 else if( i == (WIDTH-1) ) 
					full_adder full_adder (.i_a		( i_a[i] ),
												  .i_b		( i_b[i] ),
												  .i_carry	( carry[i-1] ),
												  .o_sum    ( o_sum[i] ),
												  .o_carry	( o_carry )
												  );
		else 
					full_adder full_adder (.i_a		( i_a[i] ),
												  .i_b		( i_b[i] ),
												  .i_carry	( carry[i-1] ),
												  .o_sum    ( o_sum[i] ),
												  .o_carry	( carry[i] )
												 );
				
		end
endgenerate
endmodule
//////////////////////////////////////////
//ADD OR SUB
/////////////////////////////////////////
`define SUB

module add_sub (i_var1, i_var2, o_res,o_carry);

parameter WIDTH = 4;

input  [WIDTH-1:0] 	i_var1, i_var2;
output [WIDTH-1:0]   o_res;
output					o_carry;
wire	 [WIDTH-1:0]   adder;
wire   					carry_in;

`ifdef SUB
	assign adder = ~i_var2;
	assign carry_in = 1'b1;
`else
	assign adder = i_var2;
	assign carry_in = 1'b0;
`endif

adder_4bit #( .WIDTH ( WIDTH ) ) adder_4bit_inst( .i_a     ( i_var1 ),
                                                  .i_b     ( adder ),
                                                  .i_carry ( carry_in ),
                                                  .o_sum   ( o_res  ),
                                                  .o_carry ( o_carry )
                                                );
																
endmodule
