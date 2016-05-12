onbreak resume
onerror resume
vsim -novopt work.Task1_matlab_tb
add wave sim:/Task1_matlab_tb/u_Task1_matlab/clk
add wave sim:/Task1_matlab_tb/u_Task1_matlab/clk_enable
add wave sim:/Task1_matlab_tb/u_Task1_matlab/reset
add wave sim:/Task1_matlab_tb/u_Task1_matlab/filter_in
add wave sim:/Task1_matlab_tb/u_Task1_matlab/filter_out
add wave sim:/Task1_matlab_tb/filter_out_ref
run -all
