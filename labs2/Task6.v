`timescale 1ns/1ps

module multiplier_tb;
  
parameter WIDTH = 6;
 
reg  [WIDTH - 1:0] i_a, i_b;
wire [2*WIDTH-1:0]  o_mult;


reg  [2*WIDTH-1:0]  golden_mult;

integer           i, j;
integer           error_count;

event stop;

multiplier #( .WIDTH ( WIDTH ) ) multiplier_inst( .i_var1  ( i_a ),
                                                  .i_var2  ( i_b ),
                                                  .o_mult  ( o_mult )
                                                );
                                                
initial begin
    i_a = 0;
		i_b = 0;
		  for( i = 0; i < 2**WIDTH; i = i + 1 )
			 for( j = 0; j < 2**WIDTH; j = j + 1 )begin
				#10
				i_a = i;
				i_b = j;
				golden_mult = i_a * i_b;
		  end 
		
  #5 ->stop;

end

initial begin
  	#5 error_count = 0;
  forever begin
    #10 if( golden_mult !== o_mult)
            begin
             error_count = error_count + 1;
             $display("i_a = %d, i_b = %d", i_a, i_b);
             $display("ERROR, golden_mult = %d, o_mult = %d", golden_mult, o_mult);
             $display("time = ",$time);
             end
  
  end
end
initial begin

  @stop
  if( error_count > 0 )
    $display("ERROR!!! error_count =%d", error_count);
  else
    $display("SUCCESS!!! error_count =%d", error_count);
  $finish();
end
endmodule
