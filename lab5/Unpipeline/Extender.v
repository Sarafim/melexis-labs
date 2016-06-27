//Extender
`timescale 1ns/1ps

module Extender(i_data, 
				i_ExtOp,//1=signed Extend, 0 = unsigned Extend
				o_data
				);

input [15:0] i_data;
input i_ExtOp;

output reg [31:0] o_data;

reg [15:0] ext;

always@*begin
	ext = {16{i_data[15]&i_ExtOp}};
	o_data = {ext,i_data};
end

endmodule