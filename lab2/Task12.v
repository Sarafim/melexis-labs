`timescale 1ns/1ps

module bitwise_nor_tb();

parameter WIDTH = 4;

reg  [WIDTH-1:0] i_var1,i_var2;
wire [WIDTH-1:0] o_res; 

reg  [WIDTH-1:0] golden_res;

integer i,j;
integer error_count;

event stop;

bitwise_nor #( .WIDTH ( WIDTH ) ) bitwise_nnor_inst( .i_var1 ( i_var1 ),
                                                      .i_var2 ( i_var2 ),
                                                      .o_res  ( o_res )
                                                     );

initial begin
  for( i = 0 ; i < 2**WIDTH ; i = i + 1 )
    for( j = 0 ; j < 2**WIDTH ; j = j + 1 )begin
      #10
      i_var1=i;
      i_var2=j;
    end  
  
    #15->stop;    
end

initial begin
  #5 error_count = 0 ;
  forever begin #10
    golden_res = ~(i_var1|i_var2);
    if( golden_res != o_res )
    begin
      $display("ERROR!!! golden_res = %d, o_res = %d",golden_res, o_res);
      $display("i_var1 = %d\n,i_var2 = %d\n",i_var1,i_var2);
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



