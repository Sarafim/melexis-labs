`timescale 1ns/1ps

module traffic_light(i_clk, i_rst_n, o_red, o_yellow, o_green);

parameter 	COUNTER_WIDTH	=	5;

parameter	RED				=	0;
parameter	YELLOW1			=	1;
parameter	GREEN				=	2;
parameter	YELLOW2			=	3;

parameter	RED_TIME			=	30;
parameter	YELLOW1_TIME	=	5;
parameter	GREEN_TIME		=	30;
parameter	YELLOW2_TIME	=	5;

input  i_clk, i_rst_n;
output reg o_red, o_yellow, o_green;

reg [ COUNTER_WIDTH - 1 : 0 ]		delay_time;
reg [ 1 : 0 ]							state, next_state;
reg										red, yellow, green;
reg										next_red, next_yellow, next_green;
reg										count_rst_n;
//counter

always @( posedge i_clk, negedge i_rst_n )begin
	if( !i_rst_n ) 
		delay_time <= 0;
	else if( !count_rst_n )
		delay_time <= 0;
	else
		delay_time <= delay_time + 1;
end
//FSM	
always @(posedge i_clk, negedge i_rst_n)
	if( !i_rst_n ) begin
		state		<= RED;
		red		<= 1;
		yellow	<= 0;
		green		<= 0;
	end
	else begin
		state 	<= next_state;
		red 		<= next_red;
		yellow 	<= next_yellow;
		green 	<= next_green;
	end

always @* begin
	next_state 	= state;
	next_red		= red;
	next_yellow = yellow;
	next_green	= green;
	count_rst_n = 1;
	case(state)
		RED		:	if( delay_time == RED_TIME -1 )begin
							next_state 	= YELLOW1;
							next_red 	= 0;
							next_yellow = 1;
							next_green	= 0;
							count_rst_n = 0;		
						end
		YELLOW1	:	if( delay_time == YELLOW1_TIME-1 )begin
							next_state 	= GREEN;
							next_red 	= 0;
							next_yellow = 0;
							next_green	= 1;
							count_rst_n = 0;
						end
		GREEN		:	if( delay_time == GREEN_TIME-1 )begin
							next_state 	= YELLOW2;
							next_red 	= 0;
							next_yellow = 1;
							next_green	= 0;
							count_rst_n = 0;							
						end					
		YELLOW2	:	if( delay_time == YELLOW2_TIME-1 )begin
							next_state 	= RED;
							next_red 	= 1;
							next_yellow = 0;
							next_green 	= 0;
							count_rst_n = 0;
						end					
		endcase
end

always@*begin
		o_red 	= red;
		o_yellow = yellow;
		o_green 	= green;	
	end
	
endmodule
	