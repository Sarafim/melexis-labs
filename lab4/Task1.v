`timescale 1 ns / 1 ps

module Shift_filter
				(
				i_clk,
				i_arst_n,
				i_filter,
				i_fop_fin,
				o_filter
				);

input	i_clk;
input	i_arst_n;
input 	[6:0]	i_fop_fin;		
input	signed	[17:0]	i_filter;	
output	reg signed	[17:0]	o_filter;	

///////////////////////////////////////////////////////////
//Module Architecture
///////////////////////////////////////////////////////////
	
reg signed	[17:0]	mem_reg [0:10];
reg signed	[21:0]	mux_select_reg;
reg signed	[21:0]	inv_mux_select_reg;
reg signed	[21:0]	accum_add;
reg signed	[21:0]	select_add;
reg signed	[24:0]	r_accum;
reg 	mux_select_mode;	
reg 	sync_rst_n;
reg [6:0]	counter;
integer i;

always @(posedge i_clk, negedge i_arst_n)begin:	COUNTER
	if(!i_arst_n) begin
		counter <= i_fop_fin;
		sync_rst_n <= 1;
	end	else begin
		if(counter == 5'b1111)
			sync_rst_n <= 0;
		if(counter == i_fop_fin) begin
			counter <= 0;
			sync_rst_n <= 1;
		end	else begin
			counter <= counter + 1'b1;
		end
	end
end 	//COUNTER

always @(posedge i_clk, negedge i_arst_n)begin:	INPUT_REGISTER
	if(!i_arst_n) 
		for(i = 0; i < 11; i = i + 1)
			mem_reg[i] <= 0;
	else 
		if(counter == i_fop_fin) begin
			mem_reg[0] <= i_filter;
			for(i = 1; i < 11; i = i + 1)
				mem_reg[i] <= mem_reg[i - 1];
		end
end 	//INPUT_REGISTER

always @*begin:	MUX1_17X15	//multiplexor for selecting register and selecting value 
	case(counter[3:0])
	1:	begin	
			mux_select_reg = mem_reg[0];
			mux_select_mode = 1;
		end
	2:	begin
			mux_select_reg = mem_reg[0]<<1;
			mux_select_mode = 1;
		end	
	3:	begin
			mux_select_reg = mem_reg[1]<<3;
			mux_select_mode = 1;
		end
	4:	begin	
			mux_select_reg = mem_reg[2]<<3;
			mux_select_mode = 1;
		end		
	5:	begin
			mux_select_reg = mem_reg[4]<<3;
			mux_select_mode = 0;
		end
	6:	begin
			mux_select_reg = mem_reg[4]<<1;	
			mux_select_mode = 0;
		end
	7:	begin	
			mux_select_reg = mem_reg[4];
			mux_select_mode = 0;
		end	
	8:	begin
			mux_select_reg = mem_reg[5]<<4;
			mux_select_mode = 0;
		end
	9:	begin
			mux_select_reg = mem_reg[6]<<3;
			mux_select_mode = 0;
		end
	10:	begin
			mux_select_reg = mem_reg[6]<<1;
			mux_select_mode = 0;
		end
	11:	begin
			mux_select_reg = mem_reg[6];
			mux_select_mode = 0;
		end
	12:	begin
			mux_select_reg = mem_reg[8]<<3;
			mux_select_mode = 1;
		end
	13:	begin
			mux_select_reg = mem_reg[9]<<3;
			mux_select_mode = 1;
		end
	14:	begin	
			mux_select_reg = mem_reg[10]<<1;
			mux_select_mode = 1;
		end
	15:	begin
			mux_select_reg = mem_reg[10];
			mux_select_mode = 1;
		end
	default:	begin
					mux_select_reg = 0;
					mux_select_mode = 0;
				end
	endcase
end 	//MUX1_17X15

always @*	begin:	INV
	if(mux_select_reg[21]&&~(|mux_select_reg[20:0]))
		inv_mux_select_reg = 22'h1FFFF;
	else
		inv_mux_select_reg = ~mux_select_reg + 1'b1;
end 	//INV

always @*
begin:	MUX2_2X22
	case(mux_select_mode)
	0:	select_add = mux_select_reg;
	1:	select_add = inv_mux_select_reg;
	endcase
end 	//MUX2_2X22

always @(posedge i_clk)	begin:	ACCUM 	//convolution
	accum_add = select_add & {25{sync_rst_n}};
	if(~(|counter)) 
		r_accum <= 0;
	else
		r_accum <= r_accum + accum_add;	
end 	//ACCUM

always @(posedge i_clk, negedge i_arst_n)begin: 	O_FILTER 	//rounding saturated result
	if(!i_arst_n)
		o_filter <= 0;
	else if(!sync_rst_n)begin
			if(!(r_accum[24]^r_accum[23]))
				o_filter <= r_accum[22:5] + {r_accum[4]&&(|r_accum[3:0]||r_accum[5])};
			else
				case(r_accum[24])
				0:	o_filter <= 18'h1_FFFF;	
				1:	o_filter <= 18'h2_0000;
				endcase
		end
end 	//O_FILTER

endmodule
