`timescale 1 ns / 1 ps

module Shift_filter
				(
				i_clk,
				i_rst_n,
				i_filter,
				i_fop_fin,
				o_filter
				);

input	i_clk;
input	i_rst_n;
input 	[6:0]	i_fop_fin;		
input	signed	[17:0]	i_filter;	//1.17

output	reg signed	[17:0]	o_filter;	//1.17

///////////////////////////////////////////////////////////
//Module Architecture
///////////////////////////////////////////////////////////
	
reg signed	[17:0]	reg_i [0:10];
reg signed	[21:0]	mux1_o;
reg signed	[21:0]	inv_o;
reg signed	[21:0]	mux2_t;
reg signed	[21:0]	mux2_o;
reg signed	[24:0]	accum;
reg signed 	[17:0]  	sat_o;
reg signed 	[17:0]	reg_o; 

reg 	mode_mux2;	
reg 	we_enable;
reg 	accum_rst;
reg 	sync_rst;
reg [6:0]	count;

always @(posedge i_clk, negedge i_rst_n)
	begin:	COUNTER
		if(!i_rst_n) begin
			count <= i_fop_fin;
			we_enable <= 0;
			sync_rst <= 1;
		end	
		else begin
			if(count == i_fop_fin) begin
				count <= 0;
				we_enable <= 1;
				sync_rst <= 1;
			end
			else begin
				count <= count + 1'b1;
				we_enable <= 0;
			end
			if(count == 5'b1111)
				sync_rst <= 0;
		end
	end 	//COUNTER

always @(posedge i_clk, negedge i_rst_n)
	begin:	INPUT_REGISTER
		if(!i_rst_n) begin
			reg_i[0] <= 0;
			reg_i[1] <= 0;
			reg_i[2] <= 0;
			reg_i[3] <= 0;
			reg_i[4] <= 0;
			reg_i[5] <= 0;
			reg_i[6] <= 0;
			reg_i[7] <= 0;
			reg_i[8] <= 0;
			reg_i[9] <= 0;
			reg_i[10]<= 0;			
		end
		else 
			if(we_enable) begin
				reg_i[0] <= i_filter;
				reg_i[1] <= reg_i[0];
				reg_i[2] <= reg_i[1];
				reg_i[3] <= reg_i[2];
				reg_i[4] <= reg_i[3];
				reg_i[5] <= reg_i[4];
				reg_i[6] <= reg_i[5];
				reg_i[7] <= reg_i[6];
				reg_i[8] <= reg_i[7];
				reg_i[9] <= reg_i[8];
				reg_i[10]<= reg_i[9];
			end
	end 	//INPUT_REGISTER

always @*
	begin:	MUX1_17X15	
		case(count[3:0])
		1:	begin	
				mux1_o = reg_i[0];
				mode_mux2 = 1;
			end
		2:	begin
				mux1_o = reg_i[0]<<1;
				mode_mux2 = 1;
			end	
		3:	begin
				mux1_o = reg_i[1]<<3;
				mode_mux2 = 1;
			end
		4:	begin	
				mux1_o = reg_i[2]<<3;
				mode_mux2 = 1;
			end		
		5:	begin
				mux1_o = reg_i[4]<<3;
				mode_mux2 = 0;
			end
		6:	begin
				mux1_o = reg_i[4]<<1;	
				mode_mux2 = 0;
			end
		7:	begin	
				mux1_o = reg_i[4];
				mode_mux2 = 0;
			end	
		8:	begin
				mux1_o = reg_i[5]<<4;
				mode_mux2 = 0;
			end
		9:	begin
				mux1_o = reg_i[6]<<3;
				mode_mux2 = 0;
			end
		10:	begin
				mux1_o = reg_i[6]<<1;
				mode_mux2 = 0;
			end
		11:	begin
				mux1_o = reg_i[6];
				mode_mux2 = 0;
			end
		12:	begin
				mux1_o = reg_i[8]<<3;
				mode_mux2 = 1;
			end
		13:	begin
				mux1_o = reg_i[9]<<3;
				mode_mux2 = 1;
			end
		14:	begin	
				mux1_o = reg_i[10]<<1;
				mode_mux2 = 1;
			end
		15:	begin
				mux1_o = reg_i[10];
				mode_mux2 = 1;
			end
		default:	begin
						mux1_o = 0;
						mode_mux2 = 0;
					end
		endcase
	end 	//MUX1_17X15

always @*
	begin:	INV
		if(mux1_o[21]&&~(|mux1_o[20:0]))
			inv_o = 22'b01_1111_1111_1111_1111_1111;
		else
			inv_o = ~mux1_o + 1'b1;
	end 	//INV

always @*
	begin:	MUX2_2X22
		if(mode_mux2)
			mux2_o = inv_o;
		else
			mux2_o = mux1_o;
	end 	//MUX2_2X22

always @(posedge i_clk)
	begin:	ACCUM
		mux2_t = mux2_o&{25{sync_rst}};
		if(~(|count))
			accum <= 0;
		else
			accum <= accum + mux2_t;	
	end 	//ACCUM

always @*
	begin
		reg_o = accum[22:5];
		if(reg_o > 0)
			reg_o = reg_o + 1;
	end

always @(posedge i_clk, negedge i_rst_n)
	begin: 	O_FILTER
		$display("reg_o = %d",reg_o);
		if(!i_rst_n)
			o_filter <= 0;
		else if(!sync_rst)
				if(accum[24])
					if(accum[23])
						o_filter <= reg_o;
					else
						o_filter <= 18'h2_0000;
				else 
					if(!accum[23])
						o_filter <= reg_o;
					else
						o_filter <= 18'h1_FFFF;	
		
	end 	//O_FILTER

endmodule
