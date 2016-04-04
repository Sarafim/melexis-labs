`timescale 1ns/1ps

module traffic_light_tb();

parameter PERIOD         = 10;

parameter COUNTER_WIDTH	 =	5;
parameter	RED_TIME		    	=	30;
parameter	YELLOW1_TIME	  =	5;
parameter	GREEN_TIME		   =	20;
parameter	YELLOW2_TIME	  =	5;

reg  clk, rst_n;
reg  red, yellow, green;

reg  [COUNTER_WIDTH-1:0]    delay;
reg  [2**COUNTER_WIDTH-1:0] error_count;

wire o_red, o_yellow, o_green; 


traffic_light #(.COUNTER_WIDTH(COUNTER_WIDTH),
                .RED_TIME(RED_TIME),
                .YELLOW1_TIME(YELLOW1_TIME),
                .GREEN_TIME(GREEN_TIME),
                .YELLOW2_TIME(YELLOW2_TIME)
                )                               traffic_light_inst( .i_clk(clk),
                                                                    .i_rst_n(rst_n),
                                                                    .o_red(o_red),
                                                                    .o_yellow(o_yellow),
                                                                    .o_green(o_green)
                                                                    );
initial begin
  clk = 0;
  forever #(PERIOD/2) clk = ~clk;
end                                                                    

initial begin
  rst_n = 0;
  red <= 1;
  yellow <= 0;
  green <= 0;
  @( negedge clk );
  @( negedge clk );
  rst_n = 1;
repeat(2)begin
    red <= 1;
    yellow <= 0;
    green <= 0;
    repeat(RED_TIME)@( negedge clk );
    red <= 0;
    yellow <= 1;
    green <= 0;
    repeat(YELLOW1_TIME)@( negedge clk );
    red <= 0;
    yellow <= 0;
    green <= 1;
    repeat(GREEN_TIME)@( negedge clk );
    red <= 0;
    yellow <= 1;
    green <= 0;
    repeat(YELLOW2_TIME)@( negedge clk );
  end       

  if( error_count === 0)
    $display("SIMULATION WAS SUCCESSFUL");
  else
    $display("WE HAVE TOO MUCH ERRORS");
  
  $display("error_count = %d",error_count); 
  $finish();
end

initial begin
  error_count = 0;
  forever begin
    @(posedge clk)
    if(  o_red     !== red     ||
         o_yellow  !== yellow  ||
         o_green   !== green
       ) begin
          error_count = error_count + 1;
          $display("ERROR. TRAFFIC LIGHT DOESN'T WORK");
          $display("o_red = %d, red = %d", o_red, red);
          $display("o_yellow = %d, yellow = %d", o_yellow, yellow);
          $display("o_green = %d, green = %d", o_green, green);
          $display("time = %d", $time());
        end 
  end
end
endmodule
