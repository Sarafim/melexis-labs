//Instructions Memory
`timescale 1ns/1ps

module Pipeline_Instruction_rom(	i_address, o_instruction );
input [31:0] i_address;
output  [31:0] o_instruction;

reg [31:0]	rom [0:2**10-1];

assign	o_instruction=rom[i_address[31:2]];

endmodule