`timescale 	1ns/1ps

module VM_tb();

////////////////////////////////////////////////////////////////////
//					INITIALIZATION PARAMETERS
////////////////////////////////////////////////////////////////////
parameter   PERIOD = 10;
//						DEFAULT BANKNOTE AMOUNT		
parameter   CASH_WIDTH = 10  ;				
parameter   CASH_100   = 100 ;
parameter   CASH_50    = 100 ;
parameter   CASH_20    = 100 ;
parameter   CASH_10    = 100 ;
parameter   CASH_5     = 100 ;
parameter   CASH_2     = 100 ;
parameter   CASH_1     = 100 ;
parameter   CASH_05    = 100 ;
parameter   CASH_025   = 100 ;
parameter   CASH_01    = 100 ;
parameter   CASH_005   = 100 ;
parameter   CASH_001   = 100 ;
//						DEFAULT PRODUCTS AMOUNT
parameter   AMOUNT_WIDTH 		 = 6 ;
parameter   AMOUNT_ESPRESSO      = 6 ;
parameter   AMOUNT_AMERICANO     = 6 ;   
parameter   AMOUNT_LATTE         = 6 ;
parameter   AMOUNT_TEA           = 6 ;
parameter   AMOUNT_MILK          = 6 ;
parameter   AMOUNT_HOT_CHOCOLATE = 6 ;
parameter   AMOUNT_NUTS          = 6 ;
parameter   AMOUNT_SNICKERS      = 6 ;
parameter   AMOUNT_BOUNTY        = 6 ; 
parameter   AMOUNT_GUMS          = 8 ;
//						DEFAULT PRICES
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
//						IDENTIFICATION NUMBER FOR EACH PRODUCT
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
////////////////////////////////////////////////////////////////////
//					INITIALIZATION VARIABLES
////////////////////////////////////////////////////////////////////
//input variables
reg	 		i_clk, i_rst_n;	//clock and reset
reg 		i_buy;			//input button to make the order
reg	[3:0]	i_product;		//input product identification number
reg [15:0]	i_money;		//input baknote
//output flags for buyers
wire 		o_busy;			//VM is working now
wire 		o_no_change;	//VM can't give a change
wire 	 	o_not_enough;	//VM need more money to give your order
wire 		o_other_product;//The chosen product is absent, make another selection
wire 	 	o_empty;		//VM is empty now
//output flags for VM
wire 		o_strobe_ch;	//give change
wire		o_strobe_pr;	//give product
//output variables																		
wire [3:0]	o_product;		//product delivery
wire [15:0] o_change;		//change delivery
//variables for test
integer		i;				//loop variable
integer 	error_count;	//error count
integer		product_tb;		//variables for input product that is used in test banch
integer 	payment_tb;		//variables for input payment that is used in test banch)
integer 	recieve_pr;		//recieve product
integer		recieve_money;	//recieve money
integer 	golden_change;	//correct change
integer 	sum;			//control the empty state of VM

reg signed [CASH_WIDTH-1:0]   control_cash [0:11];	//correct cash amount (compute in test bench)
reg signed [AMOUNT_WIDTH-1:0] control_pr   [1:10];	//correct product amount (comute in test bench)
////////////////////////////////////////////////////////////////////
//					VM MODULE INITIALIZATION
////////////////////////////////////////////////////////////////////
VM 	#(	.CASH_WIDTH(CASH_WIDTH),
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
		)				VM_inst1(	.i_clk(i_clk), 
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
////////////////////////////////////////////////////////////////////
//					TASK BUSY_CONTROL
////////////////////////////////////////////////////////////////////
// Control flag o_busy (set while working)
task busy_control;
input b; 
begin
	if( b ===0  )begin
		$display("ERROR, o_busy works wrong");
		error_count = error_count+1;
	end 
end
endtask
////////////////////////////////////////////////////////////////////
//					TASK CASH_CONTROL
////////////////////////////////////////////////////////////////////
// This task compute cash amount in VM_tb 
// and controls the issuance of existing banknotes 
task cash_control;
input [15:0] cash; 			//banknote
input mode;					//give change or take money
begin:	CONTR_CASH
	reg[3:0] ind;			

	case(cash)					
	10000:	ind = 0	;
	5000:	ind = 1	;
	2000:	ind = 2	;
	1000:	ind = 3	;
	500:	ind = 4	;
	200:	ind = 5	;
	100:	ind = 6	;
	50:		ind = 7	;
	25:		ind = 8	;
	10:		ind = 9	;
	5:		ind = 10;
	1:		ind = 11;
	default: disable	CONTR_CASH;	//unknow banknote => ent task
	endcase 

	case(mode)
	0:		control_cash[ind] = control_cash[ind] - 1;	//give change
	1:		control_cash[ind] = control_cash[ind] + 1;	//take money 
	default:	control_cash[ind] = control_cash[ind];
	endcase

	if(control_cash[ind] < 0) begin						//we haven't this banknote in VM, but we try to give it	
		error_count = error_count+1;
		$display("ERROR, VM is giving missing cash ' %d '", cash );   
	end 
end
endtask		
////////////////////////////////////////////////////////////////////
//					TASK RANDOM_INPUT_MONEY
////////////////////////////////////////////////////////////////////
// This task choose input banknote
task random_input_money;
input 		  o_other_product;
output [15:0] banknote;
begin
	if(!o_other_product) begin
		case($random()%11)
			0:  banknote = 10000; 
			1:  banknote = 5000 ;
			2:  banknote = 2000 ;    
			3:  banknote = 1000 ;   
			4:  banknote = 500  ;   
			5:  banknote = 200  ; 
			6:  banknote = 100  ; 
			7:  banknote = 50   ; 	
			8:  banknote = 25   ; 
			9:  banknote = 10   ;
			10: banknote = 5    ;
			11: banknote = 1    ; 
			default:banknote = 0;
		endcase
		$display("TAKE %d KOP", banknote);
	end
end
endtask
////////////////////////////////////////////////////////////////////
//					TASK RANDOM_INPUT_PRODUCT
////////////////////////////////////////////////////////////////////
task random_input_product;
input o_other_product;
output [3:0] product;
begin
	product = $random();
	if(o_other_product) 
		$display("SELECTED PRODUCT IS ABSENT, MAKE OTHER ORDER");
	case(product)
		ESPRESSO      : $display("SELECTED ESPRESSO, PRICE IS %d", PRICE_ESPRESSO)			;
		AMERICANO     : $display("SELECTED AMERICANO, PRICE IS %d", PRICE_AMERICANO)		;
		LATTE         : $display("SELECTED LATTE, PRICE IS %d", PRICE_LATTE)				;
		TEA           : $display("SELECTED TEA, PRICE IS %d", PRICE_TEA) 					;
		MILK          : $display("SELECTED MILK, PRICE IS %d", PRICE_MILK)					; 
		HOT_CHOCOLATE : $display("SELECTED HOT_CHOCOLATE, PRICE IS %d", PRICE_HOT_CHOCOLATE); 
		NUTS          : $display("SELECTED NUTS, PRICE IS %d", PRICE_NUTS) 					;
		SNICKERS      : $display("SELECTED SNICKERS, PRICE IS %d", PRICE_SNICKERS) 			;
		BOUNTY        : $display("SELECTED BOUNTY, PRICE IS %d", PRICE_BOUNTY) 				;
		GUMS          : $display("SELECTED GUMS, PRICE IS %d", PRICE_GUMS) 					;
		default       : $display("SELECTED WRONG PRODUCT") 									;
	endcase
end
endtask
////////////////////////////////////////////////////////////////////
//					CLOCK GENERATION AND START INITIALIZATION
////////////////////////////////////////////////////////////////////
initial begin: CLOCK
	//BUYER SIMULATION INITIAL
	i_clk   	= 0;
	i_rst_n 	= 0;
	i_buy   	= 0;
	i_product 	= 0;
	i_money 	= 0;
 	// VM-WORK CONTROL
	error_count = 0;
	product_tb 	= 0;
	payment_tb 	= 0;
	// 3 initial
	sum 		= 0;
	forever	#(PERIOD/2)	i_clk = ~i_clk;
end     //CLOCK     
////////////////////////////////////////////////////////////////////
//					BUYER SIMULATION
////////////////////////////////////////////////////////////////////
initial begin: BUYER
	@(negedge i_clk);
	i_rst_n = 1;
	$display("\n===================RESET=====================");
	@(negedge i_clk);

	forever begin: ATTEMT
		while( (o_busy === 1 ) && ( o_other_product === 0 ) && (!o_empty))begin: WAIT //buyer has to wait because VM is busy, doesn't wait for other product and isn't empty
			@(negedge i_clk);
			@(negedge i_clk);
		end//WAIT
		random_input_product(o_other_product,i_product);//choose product
		i_buy = 1;						//to make the order set i_buy
		@(negedge i_clk);
		i_buy = 0;						//stop making order
		busy_control(o_busy);
		@(negedge i_clk);				//take order
		random_input_money(o_other_product,i_money);	//choose input banknote
		i_product = 0;
		busy_control(o_busy);
		@(negedge i_clk);
		busy_control(o_busy);

		while( o_not_enough === 1 ) begin: MORE_CASH //not enough money to buy choosen product
			random_input_money(o_other_product,i_money);//choose input banknote
			@(negedge i_clk);
			busy_control(o_busy);
		end //MORE_CASH
		i_money = 0;
	end //ATTEMT
end  //BUYER   
////////////////////////////////////////////////////////////////////
//					VM-WORK CONTROL
////////////////////////////////////////////////////////////////////                  
initial begin
	@(posedge i_clk)

	forever begin: CONTROL 
		if(o_busy === 0 && i_buy === 1)	begin // VM is waiting and product was bought
			//initialization for evety cycle
			product_tb 		= 0;
			payment_tb 		= 0;
			recieve_money	= 0;
			recieve_pr		= 0;
			golden_change	= 0;
			@(posedge i_clk);
			product_tb <= i_product;	//take product
			@(posedge i_clk);
			
			while(o_other_product === 1)	begin: TAKE_PRODUCT //choose other product
				product_tb <= i_product;
				@(posedge i_clk);
			end//TAKE_PRODUCT
			$display("TAKE MONEY");
			payment_tb <= payment_tb + i_money;					//take money
			cash_control(i_money,1);							//add banknote to VM money
			@(posedge i_clk);

			while(o_not_enough === 1) begin: TAKE_CASH 			//product costs more 
				payment_tb <= payment_tb + i_money;				//take money
				cash_control(i_money,1);						//add banknote to VM money
				@(posedge i_clk);
			end //TAKE_CASH         
        
		     while((!o_strobe_ch)&&(!o_strobe_pr))				//wait for output data
				@(posedge i_clk);	

		    if(o_strobe_pr === 1) begin:O_PRODUCT_CONTROL 
				recieve_pr = o_product; 					
				control_pr[o_product] = control_pr[o_product] - 1;	//amount of this product decreases by 1
				$display("RIGHT PRODUCT %d, VM GIVES %d", product_tb, recieve_pr);
				if(recieve_pr !== product_tb) begin
					error_count = error_count + 1;
					$display("ERROR, we are giving wrong product");
				end
				if (control_pr[o_product]<0)	begin: ABSENT_PRODUCT
					error_count = error_count + 1;
					$display("ERROR, we are selling missing product ' %d '", o_product ); 
				end //ABSENT_PRODUCT
				@(posedge i_clk); 
		    end  //O_PRODUCT_CONTROL 

			if(o_no_change===1)begin: CHANGE_CALCULATION_1
				golden_change = payment_tb;
				product_tb = 0;
			end //CHANGE_CALCULATION_1
			else	begin: CHANGE_CALCULATION_2
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
			end //CHANGE_CALCULATION_2

			while(o_strobe_ch === 1)begin: O_CHANGE_CALCULATION
				recieve_money=recieve_money + o_change;
				if(o_change)
					$display("CHANGE IS %d", o_change);
				cash_control(o_change,0);
				@(posedge i_clk);
			end  //O_CHANGE_CALCULATION
			$display("TOTAL CHANGE IS %d KOP, RECIEVE MONEY IS %d KOP", golden_change, recieve_money);
			if(recieve_money !== golden_change) begin:O_CHANGE_CONTROL
				error_count = error_count + 1;
				$display("ERROR, we are giving wrong change");
			end //O_CHANGE_CONTROL
		end

		else	begin //wait
			@(posedge i_clk);
		end
	end //CONTROL 
end 
////////////////////////////////////////////////////////////////////
//					TOTAL_CONTROL
////////////////////////////////////////////////////////////////////
initial	begin
	forever	begin: TOTAL_CONTROL
		@(posedge i_clk);
		if(o_empty === 1)begin // waiting for the mpty state
			$display("\n===============FINISH RESUSTS=================");
			for( i = 1 ; i < 11 ; i = i + 1 ) // balance compute
				sum = sum + control_pr[i];
			if(sum !==0 )	begin: BALANCE_CONTROL
				error_count=error_count+1;
				$display("ERROR, o_empty but not empty. Total roduct = %d", sum);
			end //BALANCE
			if(error_count === 0)	begin
				$display("SIMULATION WAS SUCCESSFUL");
			end
			$display("CONTENT OF ERROR COUNTER: %0d", error_count);
			$finish();
		end
	end //TOTAL_CONTROL
end 	
////////////////////////////////////////////////////////////////////
//					FILLING VM WITH MONEY AND PRODUCTS
////////////////////////////////////////////////////////////////////
initial begin
	control_cash[0] = CASH_100;
	control_cash[1] = CASH_50 ;
	control_cash[2] = CASH_20 ;
 	control_cash[3] = CASH_10 ;
	control_cash[4] = CASH_5  ;
	control_cash[5] = CASH_2  ;
	control_cash[6] = CASH_1  ;
	control_cash[7] = CASH_05 ;
	control_cash[8] = CASH_025;
	control_cash[9] = CASH_01 ;
	control_cash[10]=CASH_005 ;
	control_cash[11]=CASH_001 ;

	control_pr[1] = AMOUNT_ESPRESSO 	;     
	control_pr[2] = AMOUNT_AMERICANO	;      
	control_pr[3] = AMOUNT_LATTE		;   
	control_pr[4] = AMOUNT_TEA 			; 
	control_pr[5] = AMOUNT_MILK			;
	control_pr[6] = AMOUNT_HOT_CHOCOLATE;
	control_pr[7] = AMOUNT_NUTS			;
	control_pr[8] = AMOUNT_SNICKERS		;
	control_pr[9] = AMOUNT_BOUNTY		;
	control_pr[10]=AMOUNT_GUMS			;  

	$display("\n===================START=====================");
end

endmodule

