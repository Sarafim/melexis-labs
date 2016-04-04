`timescale 1ns/1ps
module VM_tb();

parameter   PERIOD = 10;

parameter   CASH_WIDTH = 10  ;				
parameter   [CASH_WIDTH-1:0]CASH_100   = 100 ;
parameter   [CASH_WIDTH-1:0]CASH_50    = 100 ;
parameter   [CASH_WIDTH-1:0]CASH_20    = 100 ;
parameter   [CASH_WIDTH-1:0]CASH_10    = 100 ;
parameter   [CASH_WIDTH-1:0]CASH_5     = 100 ;
parameter   [CASH_WIDTH-1:0]CASH_2     = 100 ;
parameter   [CASH_WIDTH-1:0]CASH_1     = 100 ;
parameter   [CASH_WIDTH-1:0]CASH_05    = 100 ;
parameter   [CASH_WIDTH-1:0]CASH_025   = 100 ;
parameter   [CASH_WIDTH-1:0]CASH_01    = 100 ;
parameter   [CASH_WIDTH-1:0]CASH_005   = 100 ;
parameter   [CASH_WIDTH-1:0]CASH_001   = 100 ;

parameter   AMOUNT_WIDTH = 6  ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_ESPRESSO      = 6 ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_AMERICANO     = 6 ;   
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_LATTE         = 6 ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_TEA           = 6 ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_MILK          = 6 ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_HOT_CHOCOLATE = 6 ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_NUTS          = 6 ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_SNICKERS      = 6 ;
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_BOUNTY        = 6 ; 
parameter   [AMOUNT_WIDTH-1:0]AMOUNT_GUMS          = 8 ;

parameter   PRICE_ESPRESSO      = 1600 ;
parameter   PRICE_AMERICANO     = 1600 ;   
parameter   PRICE_LATTE         = 1600 ;
parameter   PRICE_TEA           = 1200 ;
parameter   PRICE_MILK          = 2100 ;
parameter   PRICE_HOT_CHOCOLATE = 1600 ;
parameter   PRICE_NUTS          = 1000 ;
parameter   PRICE_SNICKERS      = 2100 ;
parameter   PRICE_BOUNTY        = 2100 ; 
parameter   PRICE_GUMS          = 600 ;

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

reg	 	i_clk, i_rst_n, i_buy;
reg	[3:0]	i_product;
reg     [15:0]	i_money;

wire 		o_busy, o_no_change, o_not_enough, o_other_product,o_empty;
wire 	[3:0]	o_product;
wire	[15:0]  o_change;
wire 		o_strobe_ch, o_strobe_pr;

reg 	[3:0]	product;
reg 	[3:0]	i;
integer 	error_count;
integer		product_tb,recieve_pr;
integer 	golden_change,recieve_money;
integer 	payment_tb;
integer 	sum;

reg signed [CASH_WIDTH-1:0]   control_cash [0:11];
reg signed [AMOUNT_WIDTH-1:0] control_pr   [1:10];

initial begin
	control_cash[0]=CASH_100;
	control_cash[1]=CASH_50;
	control_cash[2]=CASH_20;
 	control_cash[3]=CASH_10;
	control_cash[4]=CASH_5;
	control_cash[5]=CASH_2;
	control_cash[6]=CASH_1;
	control_cash[7]=CASH_05;
	control_cash[8]=CASH_025;
	control_cash[9]=CASH_01;
	control_cash[10]=CASH_005;
	control_cash[11]=CASH_001;
	control_pr[1]=AMOUNT_ESPRESSO;     
	control_pr[2]=AMOUNT_AMERICANO;      
	control_pr[3]=AMOUNT_LATTE;   
	control_pr[4]=AMOUNT_TEA; 
	control_pr[5]=AMOUNT_MILK;
	control_pr[6]=AMOUNT_HOT_CHOCOLATE;
	control_pr[7]=AMOUNT_NUTS;
	control_pr[8]=AMOUNT_SNICKERS;
	control_pr[9]=AMOUNT_BOUNTY;
	control_pr[10]=AMOUNT_GUMS;  
end

VM #(.CASH_WIDTH(CASH_WIDTH),
	.CASH_100(CASH_100),
	.CASH_50(CASH_50),
	.CASH_20(CASH_20),
	.CASH_10(CASH_10),
	.CASH_5(CASH_5),
	.CASH_2(CASH_2),
	.CASH_1(CASH_1),
	.CASH_05(CASH_05),
	.CASH_025(CASH_025),
	.CASH_01(CASH_01),
	.CASH_005(CASH_005),
	.CASH_001(CASH_001),
	.AMOUNT_WIDTH(AMOUNT_WIDTH),
	.AMOUNT_ESPRESSO(AMOUNT_ESPRESSO),
	.AMOUNT_AMERICANO(AMOUNT_AMERICANO),
	.AMOUNT_LATTE(AMOUNT_LATTE),       
	.AMOUNT_TEA(AMOUNT_TEA),
	.AMOUNT_MILK(AMOUNT_MILK),
	.AMOUNT_HOT_CHOCOLATE(AMOUNT_HOT_CHOCOLATE),
	.AMOUNT_NUTS(AMOUNT_NUTS),
	.AMOUNT_SNICKERS(AMOUNT_SNICKERS),
	.AMOUNT_BOUNTY(AMOUNT_BOUNTY),
	.AMOUNT_GUMS(AMOUNT_GUMS),
	.PRICE_ESPRESSO(PRICE_ESPRESSO),
	.PRICE_AMERICANO(PRICE_AMERICANO),
	.PRICE_LATTE(PRICE_LATTE),
	.PRICE_TEA(PRICE_TEA),
	.PRICE_MILK(PRICE_MILK),
	.PRICE_HOT_CHOCOLATE(PRICE_HOT_CHOCOLATE),
	.PRICE_NUTS(PRICE_NUTS),
	.PRICE_SNICKERS(PRICE_SNICKERS),
	.PRICE_BOUNTY(PRICE_BOUNTY),
	.PRICE_GUMS(PRICE_GUMS)
	)									VM_inst1(			.i_clk(i_clk), 
														.i_rst_n(i_rst_n),
														.i_buy(i_buy),
														.i_product(i_product),
														.i_money(i_money),
														.o_busy(o_busy),
														.o_no_change(o_no_change),
														.o_not_enough(o_not_enough),
														.o_other_product(o_other_product),
														.o_change(o_change),
														.o_strobe_ch(o_strobe_ch),
														.o_product(o_product),
														.o_strobe_pr(o_strobe_pr),
														.o_empty(o_empty)
														);

task busy_control;
input b; 
begin
	if( b == 0  )begin
		$display("ERROR with o_busy");
		error_count = error_count+1;
	end 
end
endtask

task cash_control;
input [15:0] cash; 
input mode;
begin:	CONTR_CASH
	reg[3:0] ind;

	case(cash)
	10000:	ind=0;
	5000:	ind=1;
	2000:	ind=2;
	1000:	ind=3;
	500:		ind=4;
	200:		ind=5;
	100:		ind=6;
	50:		ind=7;
	25:		ind=8;
	10:		ind=9;
	5:		ind=10;
	1:		ind=11;
	default:	disable	CONTR_CASH;
	endcase 

	case(mode)
	0:		control_cash[ind] = control_cash[ind] - 1;
	1:		control_cash[ind] = control_cash[ind] + 1;	
	default:	control_cash[ind]=control_cash[ind];
	endcase

	if(control_cash[ind]<0) begin
		error_count = error_count+1;
		$display("ERROR, we are giving missing cash ' %d '", cash );   
	end 
end
endtask		
		                                                    
initial begin
	i_clk=0;
	forever	#(PERIOD/2)	i_clk = ~i_clk;
end          

initial begin
	i_rst_n = 0;
	i_buy = 0;
	i_product = 0;
	i_money = 0;
	@(negedge i_clk);
	i_rst_n = 1;
	@(negedge i_clk);

	repeat(10) begin
		for( product = 0; product<15;product=product + 1'b1)begin

			while( (o_busy == 1 ) && ( o_other_product == 0 ) && (!o_empty))begin 
				@(negedge i_clk);
			end

			i_buy = 1;
			@(negedge i_clk);
			i_buy = 0;
			i_product = product;
			busy_control(o_busy);
			@(negedge i_clk);
			i_product = 0;
			i_money = 500;
			busy_control(o_busy);
			@(negedge i_clk);
			busy_control(o_busy);

			while( o_not_enough == 1 ) begin 
				i_money = 500;
				@(negedge i_clk);
				busy_control(o_busy);
			end

			i_money = 0;
		end
	end

	@(negedge i_clk);
	busy_control(o_busy);
	@(negedge i_clk);
	busy_control(o_busy);
	@(negedge i_clk);
	busy_control(o_busy);
	@(negedge i_clk);
	busy_control(o_busy);
	@(negedge i_clk);

	$finish(); 
end     
                  
initial begin

	error_count = 0;
	product_tb = 0;
	payment_tb = 0;
	@(posedge i_clk)

	forever begin
		if(o_busy == 0 && i_buy == 1)	begin
			product_tb = 0;
			payment_tb = 0;
			recieve_money=0;
			recieve_pr=0;
			golden_change=0;
			@(posedge i_clk);
			product_tb <= i_product;
			@(posedge i_clk);
			
			while(o_other_product == 1)	begin
				product_tb <= i_product;
				@(posedge i_clk);
			end

			payment_tb <= payment_tb + i_money;
			cash_control(i_money,1);
			@(posedge i_clk);

			while(o_not_enough == 1) begin
				payment_tb <= payment_tb + i_money;
				cash_control(i_money,1);
				@(posedge i_clk);
			end          
        
		     while((!o_strobe_ch)&&(!o_strobe_pr))	
				@(posedge i_clk);
		     
			if(o_strobe_pr==1)	begin 
				recieve_pr=o_product; 
				control_pr[o_product]=control_pr[o_product]-1;
				if (control_pr[o_product]<0)	begin
					error_count=error_count+1;
					$display("ERROR, we are selling missing product ' %d '", o_product ); 
				end
				@(posedge i_clk); 
		     end  

			if(o_no_change==1)begin
				golden_change=payment_tb;
				product_tb = 0;
			end
			else	begin
				case(product_tb)
				ESPRESSO      : golden_change = payment_tb - PRICE_ESPRESSO;
				AMERICANO     : golden_change = payment_tb - PRICE_AMERICANO;
				LATTE         : golden_change = payment_tb - PRICE_LATTE;
				TEA           : golden_change = payment_tb - PRICE_TEA;
				MILK          : golden_change = payment_tb - PRICE_MILK;
				HOT_CHOCOLATE : golden_change = payment_tb - PRICE_HOT_CHOCOLATE;
				NUTS          : golden_change = payment_tb - PRICE_NUTS;
				SNICKERS      : golden_change = payment_tb - PRICE_SNICKERS;
				BOUNTY        : golden_change = payment_tb - PRICE_BOUNTY;
				GUMS          : golden_change = payment_tb - PRICE_GUMS; 
				endcase
			end

			while(o_strobe_ch==1)begin
				recieve_money=recieve_money+o_change;
				cash_control(o_change,0);
				@(posedge i_clk);
			end  
		end
		else	begin
			@(posedge i_clk);
		end
	end
end

initial	begin
	sum=0;
	forever	begin
		@(posedge i_clk);
		if(o_empty == 1)begin
			for(i=1;i<11;i=i+1)
				sum=sum+control_pr[i];
			if(sum!=0)	begin
				error_count=error_count+1;
				$display("ERROR, o_empty but not empty. Total roduct = %d", sum);
			end
			if(error_count == 0)	begin
				$display("Simulation was successful");
			end
			$finish();
		end
	end
end
endmodule

