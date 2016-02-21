`timescale 1ns/1ps

module ALU_behavior( i_var1, i_var2, i_sel, o_res );

parameter WIDTH = 4;

input 	  [WIDTH-1:0] 	i_var1, i_var2;
input  	 [2:0]		 	i_sel;

output reg[2*WIDTH-1:0] o_res;

reg		  [2*WIDTH-1:0] res;
reg    [WIDTH-1:0]   sum,sub,nand_res,nor_res;
reg    [2*WIDTH-1:0] mult;

always@*begin
  sum = i_var1 + i_var2;
  sub = i_var1 - i_var2;
  mult = i_var1 * i_var2;
  nand_res = ~(i_var1 & i_var2);
  nor_res = ~(i_var1 | i_var2);
	case(i_sel)
	0:	o_res = {WIDTH*{1'b0},sum};
	1:	o_res = mult;
	2:	o_res = {WIDTH*{1'b0},nand_res};
	3:	o_res = {WIDTH*{1'b0},nor_res};
	4:	o_res = {WIDTH*{1'b0},sub};
	default: o_res = 0;
	endcase
end
	
endmodule
