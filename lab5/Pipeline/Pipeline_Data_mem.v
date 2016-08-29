//Data Memory
`timescale 1ns/1ps

module Pipeline_Data_mem(	i_clk,
					i_MemWrite,
					i_MemRead,
					i_address,
					i_data,
					o_data
					);
input i_clk;
input i_MemWrite;
input i_MemRead;
input [31:0]	i_address;
input [31:0]	i_data;

output [31:0]	o_data;

integer i;
reg [31:0] ram [0:31];
reg [31:0] adr_reg;

always @(posedge i_clk) begin
	if(i_MemWrite)
		ram[i_address] <= i_data;
end

assign o_data = ram[i_address] & {32{i_MemRead}};

endmodule
