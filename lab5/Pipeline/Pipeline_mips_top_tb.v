`timescale 1ns/1ps

module Pipeline_mips_top_tb();

parameter PERIOD = 10;

reg i_clk;
reg i_rst_n;
reg i_coproc0_interrupt_i;
reg [31:0] control_reg [0:31];
reg [31:0] control_ram [0:31];
integer i;
integer error_count;
integer test_num;
integer external_interrupt_timer;
Pipeline_mips_top Pipeline_mips_top_inst1(.i_clk(i_clk),
								 .i_rst_n(i_rst_n),
								 .i_coproc0_interrupt_i(i_coproc0_interrupt_i)
								 );

initial begin
i_clk = 0;
i_rst_n = 0;
error_count = 0;
test_num = 10;
external_interrupt_timer = 0;
case(test_num)
	1:	begin
			$display("---------------TEST #1 --------------");
			$readmemb("/home/student/design/melexis-labs/lab5/test/test1.dat", Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Instruction_rom_inst1.rom);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test1_control_reg.dat",control_reg);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test1_control_ram.dat",control_ram);
		end
	2:	begin
			$display("---------------TEST #2 --------------");
			$readmemb("/home/student/design/melexis-labs/lab5/test/test2.dat", Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Instruction_rom_inst1.rom);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test2_control_reg.dat",control_reg);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test2_control_ram.dat",control_ram);
	end	
	3:	begin
			$display("---------------TEST #3 --------------");
			$readmemb("/home/student/design/melexis-labs/lab5/test/test3.dat", Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Instruction_rom_inst1.rom);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test3_control_reg.dat",control_reg);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test3_control_ram.dat",control_ram);
	end	
	4:	begin
			$display("---------------TEST #4 --------------");
			$readmemb("/home/student/design/melexis-labs/lab5/test/test4.dat", Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Instruction_rom_inst1.rom);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test4_control_reg.dat",control_reg);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test4_control_ram.dat",control_ram);
	end	
	5:	begin
			$display("---------------TEST #5 --------------");
			$readmemb("/home/student/design/melexis-labs/lab5/test/test5.dat", Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Instruction_rom_inst1.rom);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test5_control_reg.dat",control_reg);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test5_control_ram.dat",control_ram);
	end	
	6:	begin
			$display("---------------TEST #6 --------------");
			$readmemb("/home/student/design/melexis-labs/lab5/test/test6.dat", Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Instruction_rom_inst1.rom);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test6_control_reg.dat",control_reg);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test6_control_ram.dat",control_ram);
	end	
	7:	begin
			$display("---------------TEST #7 --------------");
			$readmemb("/home/student/design/melexis-labs/lab5/test/test7.dat", Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Instruction_rom_inst1.rom);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test7_control_reg.dat",control_reg);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test7_control_ram.dat",control_ram);
	end	
	8:	begin
			$display("---------------TEST #8 --------------");
			$readmemb("/home/student/design/melexis-labs/lab5/test/test8.dat", Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Instruction_rom_inst1.rom);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test8_control_reg.dat",control_reg);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test8_control_ram.dat",control_ram);
	end	
	9:	begin
			$display("---------------TEST #9 --------------");
			$readmemb("/home/student/design/melexis-labs/lab5/test/test9.dat", Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Instruction_rom_inst1.rom);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test9_control_reg.dat",control_reg);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test9_control_ram.dat",control_ram);
	end	
	10:	begin
			$display("---------------TEST #10 --------------");
			$readmemb("/home/student/design/melexis-labs/lab5/test/test10.dat",Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Instruction_rom_inst1.rom);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test10_control_reg.dat",control_reg);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test10_control_ram.dat",control_ram);
			external_interrupt_timer = 8;
	end	
	11:	begin
			$display("---------------TEST #11 --------------");
			$readmemb("/home/student/design/melexis-labs/lab5/test/test11.dat", Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Instruction_rom_inst1.rom);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test11_control_reg.dat",control_reg);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test11_control_ram.dat",control_ram);
	end	
	default:begin
			$display("---------------TEST #1 --------------");
			$readmemb("/home/student/design/melexis-labs/lab5/test/test1.dat",Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Instruction_rom_inst1.rom);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test1_control_reg.dat",control_reg);
			$readmemh("/home/student/design/melexis-labs/lab5/test/test1_control_ram.dat",control_ram);
	end	
endcase
forever #(PERIOD/2) i_clk = ~i_clk;
end

initial begin
i_coproc0_interrupt_i = 0;
@(negedge i_clk);
if(external_interrupt_timer)begin
	repeat(external_interrupt_timer) begin
		@(negedge i_clk);
	end
	i_coproc0_interrupt_i = 1;
end
	@(negedge i_clk);
		i_coproc0_interrupt_i = 0;
end


initial begin
$display("----------------START ---------------");
@(negedge i_clk);
i_rst_n = 1;
while(Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.d_instruction !== 32'hxxxxxxxx) begin
@(negedge i_clk);
end
@(negedge i_clk);
@(negedge i_clk);
@(negedge i_clk);
@(negedge i_clk);
@(negedge i_clk);
$display("---------PROGRAM IS FINISHED---------");
$display("---------VERIFICATION STARTS---------");
for(i=0;i<32;i=i+1) begin
	if(i&(Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Registers_inst1.registers[i] !== control_reg[i])) begin
		error_count = error_count + 1;
		$display("ERROR");
		$display("reg[%d] = %h",i,Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Registers_inst1.registers[i]);
		$display("control_reg[%d] = %h",i,control_reg[i]);
	end
	if(Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Data_mem_inst1.ram[i] !== control_ram[i]) begin
		error_count = error_count + 1;
		$display("ERROR");
		$display("ram[%d] = %h",i,Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Data_mem_inst1.ram[i]);
		$display("control_ram[%d] = %h",i,control_ram[i]);
	end
end
$writememh("/home/student/design/melexis-labs/lab5/register_contents.dat",Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Registers_inst1.registers);
$writememh("/home/student/design/melexis-labs/lab5/ram_contents.dat",Pipeline_mips_top_tb.Pipeline_mips_top_inst1.Pipeline_data_path_inst1.Pipeline_Data_mem_inst1.ram);
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
