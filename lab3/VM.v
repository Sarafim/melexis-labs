`timescale 1ns/1ps
/////////////////////////////////////
//asynchrone input,
//control banknot if real money
//change sell signed
////////////////////////////////////
module VM(		i_clk, 
				i_rst_n,
				i_buy,
				i_product,
				i_money, 
				o_busy,
				o_no_change,
				o_not_enough, 
				o_other_product,
				o_change,
				o_strobe_ch,
				o_product, 
				o_strobe_pr,
				o_empty
				);
parameter   CASH_WIDTH = 6  ;				
parameter   [CASH_WIDTH-1:0]CASH_100   = 10 ;
parameter   [CASH_WIDTH-1:0]CASH_50    = 10 ;
parameter   [CASH_WIDTH-1:0]CASH_20    = 10 ;
parameter   [CASH_WIDTH-1:0]CASH_10    = 10 ;
parameter   [CASH_WIDTH-1:0]CASH_5     = 10 ;
parameter   [CASH_WIDTH-1:0]CASH_2     = 10 ;
parameter   [CASH_WIDTH-1:0]CASH_1     = 10 ;
parameter   [CASH_WIDTH-1:0]CASH_05    = 10 ;
parameter   [CASH_WIDTH-1:0]CASH_025   = 10 ;
parameter   [CASH_WIDTH-1:0]CASH_01    = 10 ;
parameter   [CASH_WIDTH-1:0]CASH_005   = 10 ;
parameter   [CASH_WIDTH-1:0]CASH_001   = 10 ;

parameter   AMOUNT_WIDTH = 10  ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_ESPRESSO      = 2 ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_AMERICANO     = 2 ;   
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_LATTE         = 2 ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_TEA           = 2 ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_MILK          = 2 ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_HOT_CHOCOLATE = 2 ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_NUTS          = 2 ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_SNICKERS      = 2 ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_BOUNTY        = 2 ; 
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_GUMS          = 2 ;

parameter   PRICE_ESPRESSO      = 1600 ;
parameter   PRICE_AMERICANO     = 1600 ;   
parameter   PRICE_LATTE         = 1600 ;
parameter   PRICE_TEA           = 1200 ;
parameter   PRICE_MILK          = 2000 ;
parameter   PRICE_HOT_CHOCOLATE = 1600 ;
parameter   PRICE_NUTS          = 1000 ;
parameter   PRICE_SNICKERS      = 2000 ;
parameter   PRICE_BOUNTY        = 2000 ; 
parameter   PRICE_GUMS          = 500 ;

localparam  ESPRESSO      = 1 ;
localparam  AMERICANO     = 2 ;   
localparam  LATTE         = 3 ;
localparam  TEA           = 4 ;
localparam  MILK          = 5 ;
localparam  HOT_CHOCOLATE = 6 ;
localparam  NUTS          = 7 ;
localparam  SNICKERS      = 8 ;
localparam  BOUNTY        = 9 ; 
localparam  GUMS          = 10;

localparam  START         = 1 ;
localparam  TAKE_ORDER    = 2 ;
localparam  TAKE_MONEY    = 3 ;
localparam  CHANGE_CALC   = 4 ;
localparam  CHANGE_SEL    = 5 ;
localparam  CASH_SEL      = 6 ;
localparam  GIVE_ORDER    = 7 ;
localparam  GIVE_MONEY    = 8 ;
localparam  EMPTY         = 9;

input			i_clk, i_rst_n, i_buy;
input	[3:0]	i_product;
input	[15:0]	i_money;

output reg			o_busy, o_no_change, o_not_enough, o_other_product,o_empty;
output reg	[3:0]	o_product;
output reg	[15:0]	o_change;
output reg			o_strobe_ch, o_strobe_pr;

reg [CASH_WIDTH-1:0] buf_add;
reg [CASH_WIDTH-1:0] cash_100,next_cash_100;
reg [CASH_WIDTH-1:0] cash_50,next_cash_50;
reg [CASH_WIDTH-1:0] cash_20,next_cash_20;
reg [CASH_WIDTH-1:0] cash_10,next_cash_10;
reg [CASH_WIDTH-1:0] cash_5,next_cash_5;
reg [CASH_WIDTH-1:0] cash_2,next_cash_2;
reg [CASH_WIDTH-1:0] cash_1,next_cash_1;
reg [CASH_WIDTH-1:0] cash_05,next_cash_05;
reg [CASH_WIDTH-1:0] cash_025,next_cash_025;
reg [CASH_WIDTH-1:0] cash_01,next_cash_01;
reg [CASH_WIDTH-1:0] cash_005,next_cash_005;
reg [CASH_WIDTH-1:0] cash_001,next_cash_001;

reg  [AMOUNT_WIDTH-1:0] buf_sub;  
reg  [AMOUNT_WIDTH-1:0] amount_espresso,espresso;
reg  [AMOUNT_WIDTH-1:0] amount_americano,americano;   
reg  [AMOUNT_WIDTH-1:0] amount_latte,latte;
reg  [AMOUNT_WIDTH-1:0] amount_tea,tea;
reg  [AMOUNT_WIDTH-1:0] amount_milk,milk;
reg  [AMOUNT_WIDTH-1:0] amount_hot_chokolate,hot_chokolate;
reg  [AMOUNT_WIDTH-1:0] amount_nuts,nuts;
reg  [AMOUNT_WIDTH-1:0] amount_snickers,snickers;
reg  [AMOUNT_WIDTH-1:0] amount_bounty,bounty; 
reg  [AMOUNT_WIDTH-1:0] amount_gums,gums;

reg	[5:0]	state;
reg			p_busy, p_no_change, p_not_enough, p_other_product,p_empty;
reg	[3:0]	p_product;
reg	[15:0]	p_change;
reg			p_strobe_ch, p_strobe_pr;

reg	[5:0]	next_state;
reg			next_p_busy, next_p_no_change, next_p_not_enough, next_p_other_product,next_p_empty;
reg	[3:0]	next_p_product;
reg	[15:0]	next_p_change;
reg			next_p_strobe_ch, next_p_strobe_pr;
 
reg	[15:0]    		payment,next_payment;
reg	[15:0]			change,next_change;
reg	[CASH_WIDTH-1:0]	amount, next_amount;
reg	[15:0]			price,next_price;
reg	[15:0]			try,next_try;
reg	[15:0]			change_sel,next_change_sel;
reg	[3:0]			r_product, next_r_product;  
reg	[9:0]			empty,next_empty;  
   
always @(posedge i_clk, negedge i_rst_n) begin
	if(!i_rst_n)begin
		cash_100	<= CASH_100;
		cash_50   <= CASH_50;
		cash_20   <= CASH_20;
		cash_10   <= CASH_10;
		cash_5    <= CASH_5;
		cash_2    <= CASH_2;
		cash_1    <= CASH_1;
		cash_05   <= CASH_05;
		cash_025  <= CASH_025;
		cash_01   <= CASH_01;
		cash_005  <= CASH_005;
		cash_001  <= CASH_001;
    
		amount_espresso      <= AMOUNT_ESPRESSO;
		amount_americano     <= AMOUNT_AMERICANO;   
		amount_latte         <= AMOUNT_LATTE;
		amount_tea           <= AMOUNT_TEA;
		amount_milk          <= AMOUNT_MILK;
		amount_hot_chokolate <= AMOUNT_HOT_CHOCOLATE;
		amount_nuts          <= AMOUNT_NUTS;
		amount_snickers      <= AMOUNT_SNICKERS;
		amount_bounty        <= AMOUNT_BOUNTY; 
		amount_gums          <= AMOUNT_GUMS;
    
		state           <= START;
		p_busy          <=  0;
		p_no_change     <=  0;
		p_not_enough    <=  0;
		p_other_product <=  0;
		p_product       <=  0;
		p_change        <=  0;
		p_strobe_ch     <=  0;
		p_strobe_pr     <=  0;
		p_empty         <=0 ;
    
		payment       <= 0;
		change        <= 0;
		amount        <= CASH_100;
		price         <= 0;
		try           <= 0;
		change_sel    <= 10000;
		r_product     <= 0;
		empty         <= 10'b11_1111_1111;
	end
	else	begin
		amount_espresso      <= espresso;
		amount_americano     <= americano;   
		amount_latte         <= latte;
		amount_tea           <= tea;
		amount_milk          <= milk;
		amount_hot_chokolate <= hot_chokolate;
		amount_nuts          <= nuts;
		amount_snickers      <= snickers;
		amount_bounty        <= bounty; 
		amount_gums          <= gums;
    
		cash_100  <= next_cash_100;
		cash_50   <= next_cash_50;
		cash_20   <= next_cash_20;
		cash_10   <= next_cash_10;
		cash_5    <= next_cash_5;
		cash_2    <= next_cash_2;
		cash_1    <= next_cash_1;
		cash_05   <= next_cash_05;
		cash_025  <= next_cash_025;
		cash_01   <= next_cash_01;
		cash_005  <= next_cash_005;
		cash_001  <= next_cash_001;
    
		state           <= next_state;
		p_busy          <= next_p_busy;
		p_no_change     <= next_p_no_change;
		p_not_enough    <= next_p_not_enough;
		p_other_product <= next_p_other_product;
		p_product       <= next_p_product;
		p_change        <= next_p_change;
		p_strobe_ch     <= next_p_strobe_ch;
		p_strobe_pr     <= next_p_strobe_pr;
		p_empty         <= next_p_empty;
    
		payment       <= next_payment;
		change        <= next_change;
		amount        <= next_amount;
		price         <= next_price;
		try           <= next_try;
		change_sel    <= next_change_sel;
		r_product     <= next_r_product;
		empty         <= next_empty;
	end
end

always@* begin
	espresso      = amount_espresso;
	americano     = amount_americano;   
	latte         = amount_latte;
	tea           = amount_tea;
	milk          = amount_milk;
	hot_chokolate = amount_hot_chokolate;
	nuts          = amount_nuts;
	snickers      = amount_snickers;
	bounty        = amount_bounty; 
	gums          = amount_gums;
  
	next_cash_100 = cash_100; 
	next_cash_50  = cash_50;
	next_cash_20  = cash_20;
	next_cash_10  = cash_10;
	next_cash_5   = cash_5;
	next_cash_2   = cash_2;
	next_cash_1   = cash_1;
	next_cash_05  = cash_05;
	next_cash_025 = cash_025;
	next_cash_01  = cash_01;
	next_cash_005 = cash_005;
	next_cash_001 = cash_001;
    
	next_state		= state;
	next_p_busy         = p_busy;
	next_p_no_change    = p_no_change;
	next_p_not_enough   = p_not_enough;
	next_p_other_product= p_other_product;
	next_p_product      = p_product;
	next_p_change       = p_change;
	next_p_strobe_ch    = p_strobe_ch;
	next_p_strobe_pr    = p_strobe_pr;
	next_p_empty        = p_empty;
     
	next_payment        = payment;
	next_change         = change;  
	next_amount         = amount;
	next_price          = price;
	next_try            = try;
	next_change_sel     = change_sel;
	next_r_product      = r_product;
	next_empty          = empty;
	buf_sub			=0;
	buf_add			=0;

	case(state)
		START       :	begin			                	       
						if(empty==0) begin 
							next_p_empty=~(|empty); 
							next_state = EMPTY; 
							next_p_busy= 1; 
						end 
						else begin 
							if( i_buy == 1) begin 
								next_state = TAKE_ORDER; 
								next_p_busy  = 1; 
								next_payment = 0; 
							end 
						end 
					end
		TAKE_ORDER  :	begin 
						next_r_product = i_product; 
						
						case (next_r_product) 
							ESPRESSO      : buf_sub = espresso; 
							AMERICANO     : buf_sub = americano; 
							LATTE         : buf_sub = latte; 
							TEA           : buf_sub = tea; 
							MILK          : buf_sub = milk; 
							HOT_CHOCOLATE : buf_sub = hot_chokolate; 
							NUTS          : buf_sub = nuts; 
							SNICKERS      : buf_sub = snickers; 
							BOUNTY        : buf_sub = bounty; 
							GUMS          : buf_sub = gums; 
							default       : buf_sub = 0; 
						endcase
						 
						if( buf_sub != 0 )	begin 
							buf_sub = buf_sub - 1'b1; 
							next_empty     = empty;
 
							case (next_r_product) 
							ESPRESSO      :	begin 
												espresso       = buf_sub; 
												next_price     = PRICE_ESPRESSO; 
												next_empty[ESPRESSO-1]  =|buf_sub; 
											end
							AMERICANO     :	begin 
												americano      = buf_sub; 
												next_price     = PRICE_AMERICANO; 
												next_empty[AMERICANO-1]  =|buf_sub; 
											end 
							LATTE         :	begin 
												latte          = buf_sub; 
												next_price     = PRICE_LATTE; 
												next_empty[LATTE-1]  =|buf_sub; 
											end 
							TEA           :	begin 
												tea            = buf_sub; 
												next_price     = PRICE_TEA; 
												next_empty[TEA-1]  =|buf_sub; 
											end 
							MILK          :	begin 
												milk           = buf_sub; 
												next_price     = PRICE_MILK; 
												next_empty[MILK-1]  =|buf_sub; 
											end 
							HOT_CHOCOLATE :	begin 
												hot_chokolate  = buf_sub; 
												next_price     = PRICE_HOT_CHOCOLATE; 
												next_empty[HOT_CHOCOLATE-1]  =|buf_sub; 
											end 
							NUTS          :	begin 
												nuts           = buf_sub; 
												next_price     = PRICE_NUTS; 
												next_empty[NUTS-1]  =|buf_sub; 
											end 
							SNICKERS      :	begin 
												snickers       = buf_sub; 
												next_price     = PRICE_SNICKERS; 
												next_empty[SNICKERS-1]  =|buf_sub; 
											end 
							BOUNTY        :	begin 
												bounty         = buf_sub; 
												next_price     = PRICE_BOUNTY; 
												next_empty[BOUNTY-1]  =|buf_sub; 
												end  
							GUMS          :	begin 
												gums           = buf_sub; 
												next_price     = PRICE_GUMS; 
												next_empty[GUMS-1]  =|buf_sub; 
											end 
							default       :	begin 
												buf_sub        = 0; 
											end
							endcase

							next_state = TAKE_MONEY;
							next_p_other_product = 0;
						end
						else	begin
							next_p_other_product = 1; 
						end
					end
		TAKE_MONEY  :	begin
						next_payment = payment + i_money;
						if( next_payment >= price )	begin
							next_state = CHANGE_CALC;
							next_p_not_enough = 0;
						end
						else	begin
							next_p_not_enough = 1;
						end

						case(i_money)
							10000 :    buf_add = cash_100;
							5000  :    buf_add = cash_50;
							2000  :    buf_add = cash_20;
							1000  :    buf_add = cash_10;
							500   :    buf_add = cash_5;
							200   :    buf_add = cash_2;
							100   :    buf_add = cash_1;
							50    :    buf_add = cash_05;
							25    :    buf_add = cash_025;
							10    :    buf_add = cash_01;
							5     :    buf_add = cash_005;
							1     :    buf_add = cash_001;
							default:	 buf_add=0;
						endcase

						buf_add = buf_add + 1'b1;
						case(i_money)
							10000 :    next_cash_100  = buf_add;
							5000  :    next_cash_50   = buf_add;
							2000  :    next_cash_20   = buf_add;
							1000  :    next_cash_10   = buf_add;
							500   :    next_cash_5    = buf_add;
							200   :    next_cash_2    = buf_add;
							100   :    next_cash_1    = buf_add;
							50    :    next_cash_05   = buf_add;
							25    :    next_cash_025  = buf_add;
							10    :    next_cash_01   = buf_add;
							5     :    next_cash_05   = buf_add;
							1     :    next_cash_001  = buf_add;
							default:	 buf_add=0;						  
						endcase
					end
		CHANGE_CALC :	begin
						next_change = payment - price;
						next_state = CHANGE_SEL;
					end               
		CHANGE_SEL  :	begin
						next_try = change - change_sel; 
                    		if( ( change >= next_try ) && ( amount > 0 ) ) begin 
                    			next_p_change = change_sel; 
                    			next_change = next_try; 
                    			next_amount = amount - 1'b1 ; 
                    		end 
                    		else begin 
                    			next_p_change = 0; 
                    			next_change = change; 
                    			next_amount = amount; 
                    			next_state = CASH_SEL; 
                    		end 
                    	end
		CASH_SEL    :	begin 
                    		case(change_sel) 
                    		10000:	begin 
                    					next_change_sel = 5000; 
                    					if( p_strobe_ch == 1 ) next_cash_100   = amount; 
                    					next_amount     = cash_50; 
                    				end
						5000 :	begin 
                    					next_change_sel = 2000; 
                    					if( p_strobe_ch == 1 ) next_cash_50    = amount; 
                    					next_amount     = cash_20; 
                    				end 
                    		2000 :	begin 
                    					next_change_sel = 1000; 
                    					if( p_strobe_ch == 1 ) next_cash_20    = amount; 
                    					next_amount     = cash_10; 
                    			end
						1000 :	begin 
                    					next_change_sel = 500; 
                    					if( p_strobe_ch == 1 ) next_cash_10    = amount; 
                    					next_amount     = cash_5; 
                    				end
						500  :	begin 
                    					next_change_sel = 200; 
                    					if( p_strobe_ch == 1 ) next_cash_5     = amount; 
                    					next_amount     = cash_2; 
                    				end
						200  :	begin 
                    					next_change_sel = 100; 
                    					if( p_strobe_ch == 1 ) next_cash_2     = amount; 
                    					next_amount     = cash_1; 
                    				end
						100  :	begin 
                    					next_change_sel = 50; 
                    					if( p_strobe_ch == 1 ) next_cash_1     = amount; 
                    					next_amount     = cash_05; 
                    				end 
                    		50   :	begin 
                    					next_change_sel = 25; 
                    					if( p_strobe_ch == 1 ) next_cash_05    = amount; 
                    					next_amount     = cash_025; 
                    				end 
                    		25   :	begin 
                    					next_change_sel = 10; 
                    					if( p_strobe_ch == 1 ) next_cash_025   = amount; 
                    					next_amount     = cash_01; 
                    				end 
                    		10   :	begin 
                    					next_change_sel = 5; 
                    					if( p_strobe_ch == 1 ) next_cash_01    = amount; 
                    					next_amount     = cash_005; 
                    				end 
                    		5    :	begin 
                    					next_change_sel = 1; 
                    					if( p_strobe_ch == 1 ) next_cash_005   = amount; 
                    					next_amount     = cash_001; 
                    				end 
                    		1    :	begin 
                    					next_change_sel = 10000; 
                    					if( p_strobe_ch == 1 ) next_cash_001   = amount; 
                    					next_amount     = cash_100; 
                    				end 
                    		default: 	next_state = START; 
                    		endcase

						if( ( change_sel == 1 ) && ( change != 0 ) ) begin
							next_state = CHANGE_SEL;
							next_change = payment;
							next_p_strobe_ch = 1;
							next_p_no_change = 1;
						end                       
						else begin
							if ( change == 0 ) begin
								next_change_sel = 10000;
								next_amount     = cash_100;
								if( p_strobe_ch == 1 ) begin
									next_state = START;
									next_p_strobe_ch = 0;
									next_p_no_change = 0;
									next_p_busy = 0;
								end
								else	begin
									next_state = GIVE_ORDER;
									next_p_strobe_pr = 1;
									next_p_product = r_product;
								end
							end
							else	begin
								next_state = CHANGE_SEL;
							end
						end
					end
		GIVE_ORDER:	begin
						next_p_strobe_pr = 0;
						next_p_product = 0;                 
						next_state = CHANGE_CALC;
						next_p_strobe_ch = 1;
					end
		EMPTY     :	begin next_state = EMPTY;
					end
	endcase
end				
always@*	begin
	o_busy=p_busy;
	o_no_change=p_no_change;
	o_not_enough=p_not_enough; 
	o_other_product=p_other_product;
	o_change=p_change;
	o_strobe_ch=p_strobe_ch;
	o_product=p_product; 
	o_strobe_pr=p_strobe_pr;
	o_empty = p_empty;
end				

endmodule

