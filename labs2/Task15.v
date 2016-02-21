`timescale 1ns/1ps

module ALU_tb();

parameter WIDTH = 4;

wire [2*WIDTH-1:0] o_res_b, o_res_g;
reg  [WIDTH-1:0]   i_var1, i_var2;
reg  [2:0]         i_sel;

integer i,j,k;
integer error_count;

event stop;

ALU_behavior #( .WIDTH ( WIDTH ) ) ALU_behavior_inst( .i_var1( i_var1 ),
                                                      .i_var2( i_var2 ),
                                                      .i_sel ( i_sel ),
                                                      .o_res ( o_res_b )
                                                    );
ALU_gate     #( .WIDTH ( WIDTH ) ) ALU_gate_inst    ( .i_var1( i_var1 ),
                                                      .i_var2( i_var2 ),
                                                      .i_sel ( i_sel ),
                                                      .o_res ( o_res_g )
                                                     );  
initial begin
i_var1 = 0 ;
i_var2 = 0 ;
i_sel = 0 ;
  for( i = 0 ; i < 5 ; i = i + 1 )
   for( j = 0 ; j < 2**WIDTH ; j = j + 1 )
    for( k = 0 ; k < 2**WIDTH ; k = k + 1 )begin
      #10
      i_var1 = k ;
      i_var2 = j ;
      i_sel = i ;
    end
  #15->stop;
end

initial begin
  #5 error_count = 0;
  forever begin #10
    if(o_res_b !== o_res_g )
    begin
      $display("ERROR!!! o_res_b = %d, o_res_g = %d",o_res_b, o_res_g);
      $display("i_var1 = %d\n,i_var2 = %d\n, i_sel = %d",i_var1, i_var2, i_sel);
      error_count = error_count + 1;
    end 
      
  end 
end

initial begin 
@(stop)
  if(error_count===0)
   $display("SUCCESS, error_count = %d", error_count);
  else
   $display("ERROR!!!, error_count =%d", error_count);
  $finish();
end

endmodule
