module mux_tb;

parameter WIDTH = 4;

reg  [2:0]   			 i_sel;
reg  [WIDTH-1:0] i_d0,i_d1,i_d2,i_d3,i_d4;
wire [WIDTH-1:0] o_data;
reg  [WIDTH-1:0] golden_mux;  

 
integer          i,j,k,l,m,n;
integer          error_count;

event stop;

mux #( .WIDTH ( WIDTH ) ) mux_inst( .i_sel(i_sel),
                                    .i_d0(i_d0),
                                    .i_d1(i_d1), 
                                    .i_d2(i_d2),
                                    .i_d3(i_d3), 
                                    .i_d4(i_d4),
                                    .o_data(o_data)
                                    );

initial begin

 for( n = 0; n < 5; n = n + 1 ) 
  for( i = 0; i < 2 ** WIDTH; i = i +  1 )
    for( j = 0; j < 2 ** WIDTH; j = j +  1 )
      for( k = 0; k < 2 ** WIDTH; k = k +  1 )
        for( l = 0; l < 2 ** WIDTH; l = l +  1 )
          for( m = 0; m < 2 ** WIDTH; m = m +  1 ) begin
            #10
            i_d0 = i;
            i_d1 = j;
            i_d2 = k;
            i_d3 = l;
            i_d4 = m;
            i_sel= n;
        end
  #10->stop;
 end
  
initial begin
  #5 error_count=0;
  forever begin
  case(i_sel)
    0: #10 golden_mux=i_d0;  
    1: #10 golden_mux=i_d1;
    2: #10 golden_mux=i_d2;
    3: #10 golden_mux=i_d3;
    4: #10 golden_mux=i_d4;
    default:#10 golden_mux = 0;
  endcase
    if(golden_mux!==o_data)begin
      $display("ERROR!!! golden_mux = %d, o_data = %d",golden_mux, o_data);
      $display("i_sel = %d\ni_d0 = %d\ni_d1 = %d\ni_d2 = %d\ni_d3 = %d\ni_d4 = %d\n",i_sel,i_d0,i_d1,i_d2,i_d3,i_d4);
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

