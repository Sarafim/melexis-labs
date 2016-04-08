`timescale 1ns/1ps

module subtractor_tb;
  
parameter WIDTH = 4;
 
reg  [WIDTH -1:0] i_a, i_b;
reg               i_borr;
 
wire [WIDTH-1:0]  o_sub;
wire              o_borr;

reg  [WIDTH-1:0]  golden_subtractor;
reg               golden_borr;

integer           i, j;
integer           error_count;

event stop;
subtractor #( .WIDTH ( WIDTH ) ) subtractor_inst( .i_a     ( i_a ),
                                                  .i_b     ( i_b ),
                                                  .i_borr ( i_borr ),
                                                  .o_sub   ( o_sub ),
                                                  .o_borr ( o_borr )
                                                );
                                                
initial begin
    i_borr = 0;
    i_a = 0;
		i_b = 0;
		golden_borr=0;
	  
       for( i = 0; i < 2**(WIDTH); i = i + 1 )
			   for( j = 0; j < 2**(WIDTH); j = j + 1 )begin
			     repeat(2) begin
			       #10
			       i_borr =~i_borr;
			       i_a = i;
			       i_b = j;
			       {golden_borr,golden_subtractor} = i_a - i_b - i_borr ;
			       golden_borr=golden_borr;
			     end 
		     end 
	#5 ->stop;

end

initial begin
  #5	error_count = 0;
  forever begin
    #10 if( ( golden_subtractor !== o_sub ) ||
            ( golden_borr      !== o_borr) 
            ) 
            begin
             error_count = error_count + 1;
             $display("i_a = %d, i_b = %d, i_borr = %d", i_a, i_b, i_borr);
             $display("ERROR,\ngolden_subtractor = %d, o_sub = %d,\ngolden_borr = %d, o_borr = %d", golden_subtractor, o_sub,golden_borr,o_borr);
             $display("time = ",$time);
             end
  
  end
end
initial begin

  @stop
  if( error_count > 0 )
    $display("ERROR!!! error_count = %d", error_count);
  else
    $display("SUCCESS!!! error_count = %d", error_count);
  $finish();
end
endmodule

