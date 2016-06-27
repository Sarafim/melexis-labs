ncvlog -work worklib -cdslib /home/student/cds.lib mips_top_tb.v mips_top.v data_path.v Control_path.v ALU.v Data_mem.v Extender.v Instruction_rom.v Next_PC.v PC.v Registers.v
ncelab -work worklib -cdslib /home/student/cds.lib worklib.mips_top_tb 
ncsim  -cdslib /home/student/cds.lib  worklib.mips_top_tb:module 
rm -r *.log *.key
