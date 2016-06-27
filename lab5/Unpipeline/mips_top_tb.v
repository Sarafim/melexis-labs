`timescale 1ns/1ps

module mips_top_tb();

parameter PERIOD = 10;

reg i_clk;
reg i_rst_n;
reg [31:0] control_reg [0:31];
reg [31:0] control_ram [0:31];
integer i;
integer error_count;

mips_top mips_top_inst1(.i_clk(i_clk),
						.i_rst_n(i_rst_n)
						);

initial begin
i_clk = 0;
i_rst_n = 0;
error_count = 0;

$readmemb("test/test7.dat", mips_top_tb.mips_top_inst1.data_path_inst1.Instruction_rom_inst1.rom);


$readmemh("test/test7_control_reg.dat",control_reg);
$readmemh("test/test7_control_ram.dat",control_ram);

forever #(PERIOD/2) i_clk = ~i_clk;
end

initial begin
$display("----------------START ---------------");
@(negedge i_clk);
i_rst_n = 1;

while(mips_top_tb.mips_top_inst1.data_path_inst1.instruction !== 32'hxxxxxxxx)
@(negedge i_clk);

$display("---------PROGRAM IS FINISHED---------");
$display("---------VERIFICATION STARTS---------");
for(i=0;i<32;i=i+1) begin
	if(i&(mips_top_tb.mips_top_inst1.data_path_inst1.Registers_inst1.registers[i] !== control_reg[i])) begin
		error_count = error_count + 1;
		$display("ERROR");
		$display("reg[%d] = %h",i,mips_top_tb.mips_top_inst1.data_path_inst1.Registers_inst1.registers[i]);
		$display("control_reg[%d] = %h",i,control_reg[i]);
	end
	if(mips_top_tb.mips_top_inst1.data_path_inst1.Data_mem_inst1.ram[i] !== control_ram[i]) begin
		error_count = error_count + 1;
		$display("ERROR");
		$display("ram[%d] = %h",i,mips_top_tb.mips_top_inst1.data_path_inst1.Data_mem_inst1.ram[i]);
		$display("control_ram[%d] = %h",i,control_ram[i]);
	end
end
$writememh("ragister_contents.dat",mips_top_tb.mips_top_inst1.data_path_inst1.Registers_inst1.registers);
$writememh("ram_contents.dat",mips_top_tb.mips_top_inst1.data_path_inst1.Data_mem_inst1.ram);
$display("--------VERIFICATION FINISHED--------");
if(error_count === 0)
$display("---------------SUCCESS---------------\n");
else begin
	$display("TOO MANY BAGS");
	$display("ERROR COUNT = %d\n", error_count);
end
$display("CONTENTS OF REGISTERS IN \"ragister_contents.dat\"");
$display("CONTENTS OF RAM IN \"ram_contents.dat\"\n");
$finish();
end

endmodule
