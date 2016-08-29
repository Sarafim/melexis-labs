ncvlog -work worklib -cdslib /home/student/cds.lib  /home/student/design/melexis-labs/lab5/Pipeline/Pipeline_ALU.v 
ncvlog -work worklib -cdslib /home/student/cds.lib  /home/student/design/melexis-labs/lab5/Pipeline/Pipeline_Data_mem.v 
ncvlog -work worklib -cdslib /home/student/cds.lib  /home/student/design/melexis-labs/lab5/Pipeline/Pipeline_Extender.v 
ncvlog -work worklib -cdslib /home/student/cds.lib  /home/student/design/melexis-labs/lab5/Pipeline/Pipeline_Instruction_rom.v 
ncvlog -work worklib -cdslib /home/student/cds.lib  /home/student/design/melexis-labs/lab5/Pipeline/Pipeline_Next_PC.v 
ncvlog -work worklib -cdslib /home/student/cds.lib  /home/student/design/melexis-labs/lab5/Pipeline/Pipeline_PC.v 
ncvlog -work worklib -cdslib /home/student/cds.lib  /home/student/design/melexis-labs/lab5/Pipeline/Pipeline_Registers.v 
ncvlog -work worklib -cdslib /home/student/cds.lib  /home/student/design/melexis-labs/lab5/Pipeline/Pipeline_control_path.v 
ncvlog -work worklib -cdslib /home/student/cds.lib  /home/student/design/melexis-labs/lab5/Pipeline/Pipeline_coproc0.v 
ncvlog -work worklib -cdslib /home/student/cds.lib  /home/student/design/melexis-labs/lab5/Pipeline/Pipeline_data_path.v 
ncvlog -work worklib -cdslib /home/student/cds.lib  /home/student/design/melexis-labs/lab5/Pipeline/Pipeline_mips_top.v 
ncvlog -work worklib -cdslib /home/student/cds.lib  /home/student/design/melexis-labs/lab5/Pipeline/Pipeline_mips_top_tb.v  
ncelab -work worklib -cdslib /home/student/cds.lib  worklib.Pipeline_mips_top_tb 
ncsim  -cdslib /home/student/cds.lib  worklib.Pipeline_mips_top_tb:module  