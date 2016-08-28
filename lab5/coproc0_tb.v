`timescale 1ns/1ps

module coproc0_tb();

reg			i_clk;					
reg 		i_rst_n;
reg			i_we;
reg [31:0]	i_addr;									// address for writing in coprocessor
reg	[31:0]	i_data;	
reg	[31:0]	i_pc;									// program counter
reg			i_overflow;								// overflow exception
reg			i_invalid_instr;						// invalid instruction exception
reg			i_interrupt;							// external interrupt
reg			i_eret;									// eret instrauction

wire	[31:0]	o_data;
wire	[31:0]	o_return_addr;						// address for return
wire	[31:0]	o_instr_addr;						// address for transition
wire			o_interrupt;						// interrupt was detected

coproc0 coproc0_inst1(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_we(i_we),
	.i_addr(i_addr),
	.i_data(i_data),
	.i_pc(i_pc),
	.i_overflow(i_overflow),
	.i_invalid_instr(i_invalid_instr),
	.i_interrupt(i_interrupt),
	.i_eret(i_eret),
	.o_data(o_data),
	.o_return_addr(o_return_addr),
	.o_instr_addr(o_instr_addr),
	.o_interrupt(o_interrupt)
	);

initial begin
	i_clk = 0;					
	i_rst_n = 0;
	i_we = 0;
	i_addr = 0;									// address for writing in coprocessor
	i_data = 0;	
	i_pc = 0;									// program counter
	i_overflow = 0;								// overflow exception
	i_invalid_instr = 0;						// invalid instruction exception
	i_interrupt = 0;							// external interrupt
	i_eret = 0;									// eret instrauction
	forever begin
		#10 i_clk =~i_clk;
	end
end

initial begin
	forever begin
		@(negedge i_clk)
		i_pc = i_pc+1;
	end
end
initial begin
	@(negedge i_clk);
	i_rst_n = 1;
	@(negedge i_clk);
	i_we = 1;	
	i_addr = 0;
	i_data = 32'h80000007;
	@(negedge i_clk);
	i_we = 0;	
	i_addr = 0;
	i_data = 32'h80000000;	
	@(negedge i_clk);
	i_overflow = 1;
	@(negedge i_clk);
	i_overflow = 0;


	repeat(10) begin
	@(negedge i_clk);
	end
	i_eret = 1;
	i_overflow = 1;
	@(negedge i_clk);
		i_overflow = 0;
			i_eret = 0;
	repeat(100) begin
	@(negedge i_clk);
	end
	$finish();
end

endmodule
