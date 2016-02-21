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
