//Registers
`timescale 1ns/1ps

module Registers(	i_clk,
					i_regWr,
					i_ra,
					i_rb,
					i_rw,
					i_busW,
					o_busA,
					o_busB
				);

input i_clk;
input i_regWr;
input [4:0] i_ra;
input [4:0] i_rb;
input [4:0] i_rw;
input [31:0] i_busW;

output reg[31:0] o_busA;
output reg[31:0] o_busB;

reg [31:0] registers [1:31];

always@(posedge i_clk) begin
	if(i_regWr)
		registers[i_rw] <= i_busW;
end
//registters[0] is NULL always
always@* begin
	case(i_ra)
	4'b0:	 o_busA = 4'b0;
	default: o_busA = registers[i_ra];
	endcase
	case(i_rb)
	4'b0:	 o_busB = 4'b0;
	default: o_busB = registers[i_rb];
	endcase
end
endmodule