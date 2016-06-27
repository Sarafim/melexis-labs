ncvlog -work worklib -cdslib /home/student/cds.lib Pipeline_mips_top_tb.v Pipeline_mips_top.v Pipeline_data_path.v Pipeline_control_path.v ALU.v Data_mem.v Extender.v Instruction_rom.v Next_PC.v PC.v Registers.v
ncelab -work worklib -cdslib /home/student/cds.lib worklib.Pipeline_mips_top_tb 
ncsim  -cdslib /home/student/cds.lib  worklib.Pipeline_mips_top_tb:module 
rm -r *.log *.key
