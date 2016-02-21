`timescale 1ns/1ps
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
////////////////////////////////////////////////
//SUBTRACTOR
////////////////////////////////////////////////
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
/////////////////////////////////////////////////////////
////// PARAMETRIC MULTIPLIER (WIDTH = 4)
/////////////////////////////////////////////////////////
module multiplier( i_var1, i_var2, o_mult );

parameter WIDTH = 4;

input  [WIDTH-1:0]			  i_var1, i_var2;
output [2*WIDTH-1:0] 		  o_mult;

wire	 [WIDTH*WIDTH-1:0]and_mass;
wire	 [(WIDTH-1)*WIDTH-1:0]carry_mass;	
wire  [(WIDTH-1)*WIDTH-1:0]sum_mass;

genvar i ,j;

generate
	for( i = 0; i < WIDTH; i = i + 1)begin:horizontal
		for( j = 0; j < WIDTH; j = j + 1) begin:vertical
			assign and_mass[i*(WIDTH)+j] = i_var1[i] & i_var2[j];
		end
	end
endgenerate

generate
	for( j = 0; j < WIDTH; j = j + 1)begin:horizontal1
		for( i = 0; i < WIDTH-1; i = i + 1) begin:vertical1  
		  if( j == 0 )
				full_adder full_adder_inst (.i_a		( and_mass[(i+1)*(WIDTH)+j] ), //////////// 1 
											              .i_b		     ( and_mass[i*(WIDTH)+j+1] ),
											              .i_carry	  ( 1'b0 ),
											              .o_sum     ( sum_mass[i*(WIDTH)+j] ),
											              .o_carry	  ( carry_mass[i*(WIDTH)+j] )
											             );
											 
			else if ( ( i == ( WIDTH - 2 ) ) && ( j < ( WIDTH -1 ) ) )
			  full_adder full_adder_inst (.i_a		     ( and_mass[(i+1)*(WIDTH)+j] ),
											              .i_b		     ( and_mass[i*(WIDTH)+j+1] ),
					                  						  .i_carry	  ( carry_mass[i*(WIDTH)+j-1] ),
											              .o_sum     ( sum_mass[i*(WIDTH)+j] ),
											              .o_carry	  ( carry_mass[i*(WIDTH)+j] )
											              );	
			else if( ( i < ( WIDTH - 2 ) ) &&  ( j < ( WIDTH -1 ) ) )                         //////////// 2 
				full_adder full_adder_inst (.i_a	     	( and_mass[i*(WIDTH)+j+1] ),
											              .i_b		     ( carry_mass[i*(WIDTH)+j-1] ),
											              .i_carry	  ( sum_mass[(i+1)*(WIDTH)+j-1] ),
											              .o_sum     ( sum_mass[i*(WIDTH)+j] ),
										                .o_carry	  ( carry_mass[i*(WIDTH)+j] )
										               );	 
			else if ( ( i == 0 ) && ( j == ( WIDTH -1 ) ) )                         //////////// 2 
				full_adder full_adder_inst (.i_a	     	( carry_mass[i*(WIDTH)+j-1] ),
											              .i_b		     ( sum_mass[(i+1)*(WIDTH)+j-1] ),
											              .i_carry	  ( 1'b0 ),
											              .o_sum     ( sum_mass[i*(WIDTH)+j] ),
										                .o_carry	  ( carry_mass[i*(WIDTH)+j] )
										               );	 	
										               
										               /////////////////
			else if ( ( i < ( WIDTH - 2 ) ) && ( j == ( WIDTH -1 ) ) ) 
				full_adder full_adder_inst (.i_a	     	( carry_mass[(i-1)*(WIDTH)+j] ),
											              .i_b		     ( sum_mass[(i+1)*(WIDTH)+j-1] ),
											              .i_carry	  ( carry_mass[i*(WIDTH)+j-1] ),
											              .o_sum     ( sum_mass[i*(WIDTH)+j] ),
										                .o_carry	  ( carry_mass[i*(WIDTH)+j] )
										               );							               
										               ///////////////////
										               
			else if ( ( i == ( WIDTH - 2 ) ) && ( j == ( WIDTH -1 ) ) ) 
				full_adder full_adder_inst (.i_a	     	( and_mass[(i+1)*(WIDTH)+j] ),
											              .i_b		     ( carry_mass[i*(WIDTH)+j-1] ),
											              .i_carry	  ( carry_mass[(i-1)*(WIDTH)+j] ),
											              .o_sum     ( sum_mass[i*(WIDTH)+j] ),
										                .o_carry	  ( carry_mass[i*(WIDTH)+j] )
										               );							               						               						              
			end
	end
endgenerate
assign o_mult[0] = and_mass[0];
generate
	for( j = 0; j < WIDTH; j = j + 1)begin:horizontal2
		for( i = 0; i < WIDTH-1; i = i + 1) begin:vertical2  
			if( ( i == 0) || ( j == ( WIDTH - 1 ) ) )
				assign o_mult[i+j+1] = sum_mass[i*(WIDTH)+j];
		end
	end
	assign o_mult[2*WIDTH-1] = carry_mass[(WIDTH-1)*(WIDTH)-1];	
endgenerate

endmodule
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
module mux4( i_sel, i_d0, i_d1, i_d2, i_d3, o_data);

parameter WIDTH = 4;

input [1:0]   		 i_sel;
input [WIDTH-1:0]  i_d0,i_d1,i_d2,i_d3;
output[WIDTH-1:0]  o_data;

wire  [3:0] 				   one_hot;
genvar i;

decoder	 #( .WIDTH ( 2 ) ) decoder_inst (.i_data( i_sel ),
														.o_data( one_hot )													
													   );
generate
	for( i = 0; i < WIDTH; i = i + 1) begin: MUX
		assign o_data[i] = ((one_hot[0] & i_d0[i])|
								  (one_hot[1] & i_d1[i])|
								  (one_hot[2] & i_d2[i])|
								  (one_hot[3] & i_d3[i])								  
								  );
	end
	
endgenerate



endmodule
/////////////////////////////////////
//NAND
/////////////////////////////////////
module bitwise_nand( i_var1, i_var2, o_res);

parameter WIDTH = 4;

input  [WIDTH-1:0] i_var1,i_var2;
output [WIDTH-1:0] o_res;

genvar i;

generate
	for( i = 0 ; i < WIDTH ; i = i + 1 )begin:NAND
		nand  nand_inst (o_res[i], i_var1[i],i_var2[i]);
	end
endgenerate
endmodule
/////////////////////////////////////
//NOR
/////////////////////////////////////
module bitwise_nor( i_var1, i_var2, o_res);

parameter WIDTH = 4;

input  [WIDTH-1:0] i_var1,i_var2;
output [WIDTH-1:0] o_res;

genvar i;

generate
	for( i = 0 ; i < WIDTH ; i = i + 1 )begin:NOR
		nor  nor_inst (o_res[i], i_var1[i],i_var2[i]);
	end
endgenerate
endmodule
/////////////////////////////////////////////////////////
//ALU
/////////////////////////////////////////////////////////
module ALU_gate( i_var1, i_var2, i_sel, o_res );

parameter WIDTH = 4;

input  [WIDTH-1:0] 	i_var1, i_var2;
input  [2:0]		 	i_sel;

output [2*WIDTH-1:0] o_res;

wire	 [WIDTH-1:0]   sum, nor_res, nand_res; 
wire   [2*WIDTH-1:0] mult;
wire             		carry,borr;

wire	 [WIDTH-1:0]   adder;

genvar i;

generate 
	for( i = 0 ; i < WIDTH ; i = i + 1 )begin:SUB_OR_ADD
		assign adder[i] = ( ( ( ~i_var2[i] ) & i_sel[2] ) | ( i_var2[i] & ( ~i_sel[2] ) ) );
	end
endgenerate

adder_4bit #( .WIDTH ( WIDTH ) ) adder_4bit_inst( .i_a     ( i_var1 ),
                                                  .i_b     ( adder ),
                                                  .i_carry ( i_sel[2] ),
                                                  .o_sum   ( sum  ),
                                                  .o_carry ( carry )
                                                );
/*subtractor #( .WIDTH ( WIDTH ) ) subtractor_inst( .i_a     ( i_var1 ),
                                                  .i_b     ( i_var2 ),
                                                  .i_borr  ( 1'b1 ),
                                                  .o_sub   ( sub ),
                                                  .o_borr  ( borr )
                                                );
	*/															
multiplier #( .WIDTH ( WIDTH ) ) multiplier_inst( .i_var1  ( i_var1 ),
                                                  .i_var2  ( i_var2 ),
                                                  .o_mult  ( mult )
                                                );
bitwise_nand #( .WIDTH ( WIDTH ) ) bitwise_nand_inst( .i_var1 ( i_var1 ),
                                                      .i_var2 ( i_var2 ),
                                                      .o_res  ( nand_res )
                                                     );
bitwise_nor #( .WIDTH ( WIDTH ) ) bitwise_nnor_inst(  .i_var1  ( i_var1 ),
                                                      .i_var2 ( i_var2 ),
                                                      .o_res  ( nor_res )
                                                     );	
mux4 #( .WIDTH ( 2*WIDTH ) ) mux4_inst( .i_sel (i_sel[1:0]),
                                        .i_d0  ({WIDTH*{1'b0},sum}),
                                        .i_d1  (mult),
                                        .i_d2  ({WIDTH*{1'b0},nand_res}), 
                                        .i_d3  ({WIDTH*{1'b0},nor_res}),
                                        .o_data(o_res)
                                    );

endmodule
