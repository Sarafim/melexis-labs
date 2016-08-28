//ALU
`timescale 1ns/1ps

module ALU(	i_data_A, 		//first  input register
			i_data_B, 		//second input register
			i_ALU_Ctrl,		//control wire
			i_sh_amount,	//size for shift
			o_data, 		//output result
			o_zero, 		//zero flag
			o_overflow,		//overflow flag
			);

input [10:0]	i_ALU_Ctrl;

input [31:0]	i_data_A;
input signed[31:0]	i_data_B;
input [4:0]		i_sh_amount;

output reg [31:0] o_data;

output	o_zero;
output	o_overflow;
////////////////////////////////////////////////////////////////////
//					INITIALIZATION VARIABLES
////////////////////////////////////////////////////////////////////
//Control
wire [1:0]	i_ALU_sel;	//Shift=00, SLT=01, ARITH=10, Logic=11
wire [2:0]	i_sh_op;	//SLL=000, 	SRL =010, SRA=011, 	ROR=001
wire		i_lui;		//LUI
//						//SLLV=100, SRLV=110, SRAV=111, RORV=101
wire [1:0]	i_log_op;	//AND,ANDI=00, OR,ORI=01, XOR,XORI=10, NOR=11 
wire		i_ar_op_en; // enable for overflow
wire 		i_ar_op;	//ADD,ADDU,ADDI=0, SUB,SUBU,SUBI=1
wire		i_slt_op;	//SLT = 0, SLTU = 1;

assign {i_ALU_sel,i_sh_op,i_lui,i_log_op,i_ar_op_en, i_ar_op,i_slt_op} = i_ALU_Ctrl;
//Barrel Shifter
reg signed[62:0]	sh_extend;		//extended i_data_A
wire [4:0]  sh_amount;		//size for shift
wire [31:0]	sh_result;		//result of the barrel shifter(control S0)
wire [46:0]	sh_mux4;		//after 1 mux(control S4)
wire [38:0]	sh_mux3;		//after 2 mux(control S3)
wire [34:0] sh_mux2;		//after 3 mux(control S2)
wire [32:0] sh_mux1;		//after 4 mux(control S1)
//Adder
wire [32:0]	add_result;		//result of the adder
//Logic Unit
reg [31:0] log_or;			//variable for or operation
reg [31:0] log_result;		//result of the logic unit
//ALU selection

////////////////////////////////////////////////////////////////////
//					Barrel Shifter
////////////////////////////////////////////////////////////////////
assign sh_amount = i_lui ? 5'b01111 : ({5{&(~i_sh_op[1:0])}}^(i_sh_op[2]?i_data_A[4:0]:i_sh_amount));	//sellection of the shift size 


always @* begin: EXTENDER

	case(i_sh_op[1:0])
	2'b00:	sh_extend = {i_data_B, 31'b0};				//SLL, SLLV
	2'b10:	sh_extend = {31'b0, i_data_B};				//SRL, SRLV
	2'b11:	sh_extend = i_data_B; 						//SRA, SRA
	2'b01:	sh_extend = {i_data_B[30:0], i_data_B};		//ROR, RORV
	default:sh_extend = 63'b0;	
	endcase	
end //EXTENDER
assign sh_mux4 = sh_amount[4]?sh_extend[62:16]:sh_extend[46:0];
assign sh_mux3 = sh_amount[3]?sh_mux4[46:8]:sh_mux4[38:0];
assign sh_mux2 = sh_amount[2]?sh_mux3[38:4]:sh_mux3[34:0];
assign sh_mux1 = sh_amount[1]?sh_mux2[34:2]:sh_mux2[32:0];
assign sh_result = sh_amount[0]?sh_mux1[32:1]:sh_mux1[31:0];
////////////////////////////////////////////////////////////////////
//					ADDER
////////////////////////////////////////////////////////////////////
assign 	add_result = i_data_A + (i_data_B^{32{i_ar_op}}) + {31'b0,i_ar_op};
////////////////////////////////////////////////////////////////////
//					Logic Unit
////////////////////////////////////////////////////////////////////
always @* begin:LOGIC_UNIT
	log_or = i_data_A | i_data_B;
	case(i_log_op)
	2'b00:		log_result = i_data_A & i_data_B;
	2'b01:		log_result = log_or;
	2'b10:		log_result = i_data_A ^  i_data_B;
	2'b11:		log_result =~log_or;
	default:	log_result = 32'b0;
	endcase
end//LOGIC_UNIT
////////////////////////////////////////////////////////////////////
//					ALU SELECTION
////////////////////////////////////////////////////////////////////
always @* begin:ALU_SELECTION
	case(i_ALU_sel)
	2'b00: 	o_data = sh_result;			//barrel shifter
	2'b01: 	o_data = i_slt_op ?  ((~i_data_A[31])&((i_data_B[31]))||(add_result[31]&~(add_result[32]))):(add_result[31])&&(|add_result);		
			//SLT: signed comparison and unsigned comparison 
	2'b10: 	o_data = add_result[31:0];		//adder
	2'b11: 	o_data = log_result;		//logic unit
	default:o_data = 32'b0;
	endcase								
end//ALU_SELECTION
assign o_overflow = i_ar_op_en & (i_ar_op ?														//form overflow
					((!i_data_A[31] &&  i_data_B[31] &&  o_data[31])||			//sub
					 ( i_data_A[31] && !i_data_B[31] && !o_data[31])):
					((!i_data_A[31] && !i_data_B[31] &&  o_data[31])||			//add
					 ( i_data_A[31] &&  i_data_B[31] && !o_data[31])));

assign o_zero = ~(|o_data);															//form zero

endmodule
