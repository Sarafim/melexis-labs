ncvlog -work worklib -cdslib /home/student/design/cds.lib  ALU.v Control_path.v coproc0.v Data_mem.v data_path.v Extender.v Instruction_rom.v mips_top.v mips_top_tb.v Next_PC.v PC.v Registers.v
ncelab -work worklib -cdslib /home/student/design/cds.lib  worklib.mips_top_tb 
ncsim  -cdslib /home/student/design/cds.lib  worklib.mips_top_tb:module 
rm -r *.log *.key
