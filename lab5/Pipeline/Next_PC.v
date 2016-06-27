//Next PC
`timescale 1ns/1ps
module Next_PC( i_PC,
				i_Imm,
				adr_JR,
				i_zero,
				i_J,
				i_Jr,
				i_beq,
				i_bne,
				o_PC,
				o_PCSrc
				);

input signed [29:0] i_PC;
input signed [25:0] i_Imm;
input [31:0]	adr_JR;
input	i_zero;
input	i_J;
input 	i_Jr;
input 	i_beq;
input 	i_bne;

output [29:0] o_PC;
output o_PCSrc;

wire signed [15:0] ext_Imm;
wire [29:0] branch;

assign 	ext_Imm = i_Imm[15:0];
assign 	branch = i_PC + ext_Imm;

assign 	o_PC = i_J ? {i_PC[29:26],i_Imm} : { i_Jr ? adr_JR[31:2] :branch};
assign 	o_PCSrc =	((~i_zero)&i_bne) |
					(i_zero&i_beq)	  |
					i_J|i_Jr;


endmodule