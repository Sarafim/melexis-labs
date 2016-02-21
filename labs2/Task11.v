`timescale 1ns/1ps

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

