`timescale 1ns/1ps

module add_sub_tb();

parameter WIDTH = 4;
parameter MODE  = 1;

reg  [WIDTH-1:0]   i_var1, i_var2;
wire [WIDTH-1:0]   o_res;
wire				          	o_carry;

reg [WIDTH-1:0]   golden_res;
reg               golden_carry;

integer i,j;
integer error_count;

event stop;
add_sub #( .WIDTH ( WIDTH ),
           .MODE  ( MODE ) 
          )                   add_sub( .i_var1(  i_var1 ),
                                       .i_var2 ( i_var2 ),
                                       .o_res  ( o_res ),
                                       .o_carry(o_carry)
                                      );

initial begin
i_var1 = 0 ;
i_var2 = 0 ;
  for( i = 0 ; i < 5 ; i = i + 1 )
   for( j = 0 ; j < 2**WIDTH ; j = j + 1 )begin
      #10
      i_var1 = j ;
      i_var2 = i ;
    end
  #15->stop;
end

initial begin
  #5 error_count = 0;
     golden_res = 0;
     golden_carry = 0;
  forever begin #10
    if( MODE ) begin
      { golden_carry,golden_res } = i_var1 + i_var2;
    end else begin
      { golden_carry , golden_res } = i_var1 - i_var2;
      golden_carry = ~golden_carry;
    end
    
    if( ( golden_res   !== o_res ) ||
        ( golden_carry !== o_carry) 
       )
    begin
      $display("ERROR!!! golden_res = %d, o_res = %d",golden_res, o_res);
      $display("ERROR!!! golden_carry = %d, o_carry = %d",golden_carry, o_carry);
      $display("i_var1 = %d\n,i_var2 = %d",i_var1, i_var2);
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

