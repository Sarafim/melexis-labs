`timescale 1ns/1ps
module adder_4bit_tb;
  
parameter WIDTH = 4;
 
reg  [WIDTH -1:0] i_a, i_b;
reg               i_carry;
 
wire [WIDTH-1:0]  o_sum;
wire              o_carry;

reg  [WIDTH-1:0]  golden_sum;
reg               golden_carry;

integer           i, j;
integer           error_count;

event stop;
adder_4bit #( .WIDTH ( WIDTH ) ) adder_4bit_inst( .i_a     ( i_a ),
                                                  .i_b     ( i_b ),
                                                  .i_carry ( i_carry ),
                                                  .o_sum   ( o_sum ),
                                                  .o_carry ( o_carry )
                                                );
                                                
initial begin
    i_carry = 1;
    i_a = 0;
		i_b = 0;
    repeat(2) begin 
		  #10 i_carry = i_carry^1;
		  { golden_carry, golden_sum } = i_a + i_b + i_carry;
		  for( i = 0; i < 2**WIDTH; i = i + 1 )
			 for( j = 0; j < 2**WIDTH; j = j + 1 )begin
				#10
				i_a = i;
				i_b = j;
				{ golden_carry, golden_sum } = i_a + i_b + i_carry;
		  end 
		end
  #5 ->stop;

end

initial begin
  #15	error_count = 0;
  forever begin
    #10 if( ( golden_carry !== o_carry ) ||
            ( golden_sum   !== o_sum)
            ) 
            begin
             error_count = error_count + 1;
             $display("i_a = %d, i_b = %d, i_carry = %d", i_a, i_b, i_carry);
             $display("ERROR, golden_sum = %d, o_sum = %d,\n\tgolden_carry = %d, o_carry = %d,", golden_sum, o_sum, golden_carry, o_carry);
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
