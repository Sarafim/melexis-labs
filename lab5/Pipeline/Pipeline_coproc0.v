`timescale 1ns/1ps

module Pipeline_coproc0(
	i_clk,
	i_rst_n,
	i_we,
	i_addr,
	i_data,
	i_pc,
	i_overflow,
	i_invalid_instr,
	i_interrupt,
	i_eret,
	o_data,
	o_return_addr,
	o_instr_addr,
	o_interrupt
	);
	
input			i_clk;					
input 			i_rst_n;
input			i_we;
input 	[31:0]	i_addr;									// address for writing in coprocessor
input	[31:0]	i_data;	
input	[29:0]	i_pc;									// program counter
input			i_overflow;								// overflow exception
input			i_invalid_instr;						// invalid instruction exception
input			i_interrupt;							// external interrupt
input			i_eret;									// eret instrauction

output	reg	[31:0]	o_data;
output		[29:0]	o_return_addr;						// address for return
output	reg	[29:0]	o_instr_addr;						// address for transition
output				o_interrupt;						// interrupt was detected
//////////////////////////////////////////////////////////////////////////
//					Variables
//////////////////////////////////////////////////////////////////////////
//	31 	- global interrupt enable
//	8  	- external interrupt
//	1	- invalid instruction 
//	0 	- overflow 
reg		[31:0]	status_register;		//	mask register 						
reg 	[31:0] 	couse_register;			//	reason of the interrupt
reg 	[29:0]	epc;					//	exception programm counter

reg		we_epc;							//	write enable for epc
reg		int_proc;						//	set if exception is processed
//////////////////////////////////////////////////////////////////////////
//					Status and Couse registers
//////////////////////////////////////////////////////////////////////////
always@(posedge i_clk, negedge i_rst_n) begin
	if(!i_rst_n) begin
		status_register	<= 32'h80000007;
		couse_register	<= 0;
	end
	else begin 
		if(i_we & (i_addr == 32'h00000060)) 								// write data in staus/mask register
			status_register <= i_data;				

		if(i_we & (i_addr == 32'h00000068)) 								// write data in couse register
			couse_register <= i_data;
		else if(!int_proc)begin
			couse_register[0] <= i_interrupt;					// set if external interrupt was detected
			couse_register[1] <= i_invalid_instr;				// set if invalid instruction was detected
			couse_register[2] <= i_overflow;					// set if overflow was detected
		end	
	end
end
//////////////////////////////////////////////////////////////////////////
//					Interrupt searching
//////////////////////////////////////////////////////////////////////////
always@*begin

	we_epc =  ( ( status_register[0] & i_interrupt 	 ) |
			    ( status_register[1] & i_invalid_instr ) |
			    ( status_register[2] & i_overflow 	 )) &	//	interrupt was detected
			  ( ! int_proc ) & status_register[31]; 			
end
//////////////////////////////////////////////////////////////////////////
//					Interrupt processing
//////////////////////////////////////////////////////////////////////////
always@(posedge i_clk, negedge i_rst_n) begin
	if(!i_rst_n) 
		int_proc <= 0;
	else begin
		if(we_epc)
			int_proc <= 1;
		if(i_eret)
			int_proc <= 0;
	end
end

//////////////////////////////////////////////////////////////////////////
//					Exception program counter
//////////////////////////////////////////////////////////////////////////
always@(posedge i_clk, negedge i_rst_n) begin
	if(!i_rst_n) 
		epc	<= 0;
	else begin
		if(we_epc)
			epc <= i_pc;
		else if(i_we & (i_addr == 32'h00000070))	
			epc = i_data[31:2];
		end
end

//////////////////////////////////////////////////////////////////////////
//					Output
//////////////////////////////////////////////////////////////////////////
always@*begin
	case(i_addr)
		32'h00000060:	o_data = status_register; 
		32'h00000068:	o_data = couse_register;  
		32'h00000070:	o_data = {epc, 2'b00};
		default:		o_data = 32'h0000000;
	endcase	
end

always@*begin
	if(i_overflow|i_invalid_instr|i_interrupt)
		o_instr_addr = 30'h002;
	else
		o_instr_addr = 0;
end

assign o_return_addr = epc;
assign o_interrupt = we_epc;

endmodule