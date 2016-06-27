//Control path
`timescale 1ns/1ps
 
 module Pipeline_control_path(	i_clk,
		 						i_rst_n,
					 			i_opcode,			//instruction [31:26]
		 					 	i_funct,			//instruction [5:0]
		 				 		i_overflow,			//overflow from ALU	
		 				 		i_R6_21,			//instruction [6,21]
		 				 		i_rs,				//rs addr for bypass and stall
		 				 		i_rt,				//rt addr for bypass and stall
		 				 		i_rw_d,				//RegWr
								i_rw_ex,			//RegWr reg at execute phase
								i_rw_mem,			//RegWr reg	at memory phase
								i_rw_w,				//RegWr reg	at write back phase
		 					 	o_RegDst,			//Rt = 1 or Rd = 0 at RW
								o_RegWr,			//write in Registers = 1
								o_ExtOp,			//signed = 1 or unsigned = 0 extend of Imm16 befor ALU
								o_ALUSrc,			//R  = 0 or I = 1  instruction goes to ALU
								o_ALUCtrl,			//ALU Control
								o_MemRead,			//read from Data memory = 1
								o_MemWrite,			//write to Data Memory = 0
								o_MemtoReg,			//write to Registers from Data memory = 1 ot from ALU = 0
								o_J,				//Jump
								o_Jr,				//Jump to address in register
								o_Beq,				//beq
								o_Bne,				//bne
								o_ASrc,				//bypass_mux for rs
								o_BSrc,				//bypass_mux for rt
								o_stall				//stall signal
							 	);

input 		i_clk;
input		i_rst_n;
input [5:0]	i_opcode;
input [5:0] i_funct;
input [4:0] i_rs;
input [4:0] i_rt;
input [4:0] i_rw_d;
input [4:0] i_rw_ex;
input [4:0] i_rw_mem;
input [4:0] i_rw_w;
input 		i_overflow;
input [1:0] i_R6_21;

output				o_RegDst;			
output	reg 		o_RegWr;			
output				o_ExtOp;			
output				o_ALUSrc;			
output	reg [9:0] 	o_ALUCtrl;			
output	reg 		o_MemRead;			
output	reg 		o_MemWrite;			
output	reg 		o_MemtoReg;			
output				o_J;
output 				o_Jr;				
output				o_Beq;				
output				o_Bne;
output reg [1:0] 	o_ASrc;
output reg [1:0] 	o_BSrc;
output 				o_stall;
////////////////////////////////////////////////////////////////////
//					INITIALIZATION VARIABLES
////////////////////////////////////////////////////////////////////
wire			RegDst;			
wire			RegWr;			
wire			ExtOp;			
wire			ALUSrc;			
wire	[9:0] 	ALUCtrl;			
wire			MemRead;			
wire			MemWrite;			
wire			MemtoReg;			
wire			J;
wire 			Jr;				
wire			Beq;				
wire			Bne;

wire 			add_sub_addi;
reg				add_sub_addi_r;

reg				ex_MemRead;
reg 			ex_MemWrite;
reg 			ex_MemtoReg;
reg 			ex_RegWr;
reg 			mem_RegWr;
//Main Control
reg [12:0]	main_control;						//o_RegDst, t_RegWr, o_ExtOp, o_ALUSrc, o_MemRead, o_MemWrite, o_MemtoReg, o_J, o_Beq, o_Bne;
//ALU Control
reg [9:0]	alu_funct;							//o_ALUCtrl for R instruction
reg [9:0]	alu_opcode;							//o_ALUCtrl for I instruction
//Bypass
wire read_A;
wire read_B;
wire write_d;
reg write_ex;
reg write_mem;
reg write_w;
//stall
wire stall;
reg stall_r;
////////////////////////////////////////////////////////////////////
//					OUTPUT
////////////////////////////////////////////////////////////////////
assign 	o_ExtOp = ExtOp;			
assign	o_ALUSrc = ALUSrc;
assign	o_J = J;
assign 	o_Jr = Jr;				
assign	o_Beq = Beq;				
assign	o_Bne = Bne;
assign 	o_RegDst = RegDst;

assign add_sub_addi = (((!({i_funct[5:2], i_funct[0]} ^ 5'b10000))&(!(i_opcode^6'b000000))) || !( i_opcode^6'b001000 ) ); //if overflow, write nothing

//pipeline
always@(posedge i_clk, negedge i_rst_n) begin
	if(!i_rst_n)begin
		o_ALUCtrl <= 10'h000;
		
		{ex_MemRead, ex_MemWrite, ex_MemtoReg} <= 3'b000;			
		{o_MemRead, o_MemWrite,	o_MemtoReg}	<= 3'b000;

		ex_RegWr <= 1'b0;
		mem_RegWr <= 1'b0;	
		o_RegWr <= 1'b0;

		write_ex <= 1'b0;
		write_mem <= 1'b0;
		write_w <= 1'b0;

		add_sub_addi_r <= 1'b0;
	end
	else begin
		o_ALUCtrl <= {10{!stall}}&ALUCtrl;
		
		{ex_MemRead, ex_MemWrite, ex_MemtoReg} <= {3{!stall}}&{MemRead, MemWrite, MemtoReg};			
		{o_MemRead, o_MemWrite,	o_MemtoReg} <= {ex_MemRead, ex_MemWrite, ex_MemtoReg}; 
		
		ex_RegWr <= {!stall}&RegWr;
		mem_RegWr <=  (add_sub_addi_r & i_overflow) ? 0 : ex_RegWr;			//(add,sub || addi), if overflow o_RegWr = 0 
		o_RegWr <=mem_RegWr;


		write_ex <= {!stall}&write_d;
		write_mem <= write_ex;
		write_w <= write_mem;
		add_sub_addi_r <= add_sub_addi;
	end
end
////////////////////////////////////////////////////////////////////
//					MAIN CONTROL
////////////////////////////////////////////////////////////////////
always@* begin
	casez(i_opcode)
	//o_RegDst, o_RegWr		o_ExtOp,o_ALUSrc,o_MemRead,o_MemWrite		o_MemtoReg,o_J,o_Beq,o_Bne 		read_A, read_B, write_d;
	6'b000000:	main_control = 13'b11_x0x0_0000_111;//R
	6'b00100?:	main_control = 13'b01_1100_0000_101;//addi,addiu
	6'b0011??:	main_control = 13'b01_0100_0000_101;//andi,ori,xori,lui
	6'b000010:	main_control = 13'bx0_x000_x100_000;//j
	6'b000100:	main_control = 13'bx0_x000_x010_110;//beq
	6'b000101:	main_control = 13'bx0_x000_x001_110;//bne
	6'b100011:	main_control = 13'b01_1110_1000_101;//lw
	6'b101011:	main_control = 13'b00_1101_x000_110;//sw
	default: 	main_control = 13'b00_0000_0000_000;//nop
	endcase
end
assign	{ RegDst, RegWr, ExtOp, ALUSrc, MemRead, MemWrite, MemtoReg, J, Beq, Bne, read_A, read_B, write_d } = main_control;
assign  Jr = (!i_opcode)&(!(6'b001000^i_funct));
////////////////////////////////////////////////////////////////////
//					ALU CONTROL
////////////////////////////////////////////////////////////////////
// [1:0]	i_ALU_sel;	//Shift=00, SLT=01, ARITH=10, Logic=11
// [2:0]	i_sh_op;	//LUI,SLL=000, 	SRL =010, SRA=011, 	ROR=001
//						//SLLV=100, SRLV=110, SRAV=111, RORV=101
// [1:0]	i_log_op;	//AND,ANDI=00, OR,ORI=01, XOR,XORI=10, NOR=11 
// 			i_ar_op;	//ADD,ADDU,ADDI=0, SUB,SUBU,SUBI=1
//			i_slt_op;	//SLT = 0, SLTU = 1;
//i_ALU_sel,	i_sh_op,	i_log_op,	i_ar_op,	i_slt_op
////////////////////////////////////////////////////////////////////
always@* begin
	casez( {i_funct, i_R6_21} )														//R instruction
	8'b1000????: 	alu_funct = { 8'b10_xxx_0_xx,	i_funct[1],		1'bx  		};	//add,addu,sub,subu
	8'b1001????: 	alu_funct = { 6'b11_xxx_0,		i_funct[1:0],	2'bxx 		};	//and,or,xor,nor
	8'b10101???:	alu_funct = { 8'b01_xxx_0_xx_1, i_funct[0]			  		}; 	//slt,sltu
	8'b000100??:	alu_funct = { 2'b00, 			i_funct[2:0],5'b0_xx_x_x	};	//sllv
	8'b000000??:	alu_funct = { 2'b00, 			i_funct[2:0],5'b0_xx_x_x	};	//sll
	8'b000111??:	alu_funct = { 2'b00, 			i_funct[2:0],5'b0_xx_x_x	};	//srav
	8'b000011??:	alu_funct = { 2'b00, 			i_funct[2:0],5'b0_xx_x_x	};	//sra
	
	
	
	8'b001100_00:	alu_funct = { 10'bxx_xxx_0_xx_xx 					 		};  //Jr
	8'b000110_1?:	alu_funct = 10'b00_101_0_xx_x_x;								//rorv instruction [6]  R = 1
	8'b000110_0?:	alu_funct = 10'b00_110_0_xx_x_x;								//srlv instruction [6] 	R = 0
	8'b000010_01:	alu_funct = 10'b00_001_0_xx_x_x;								//ror instruction[21] R = 1
	8'b000010_11:	alu_funct = 10'b00_001_0_xx_x_x;								//ror instruction[21] R = 1
	8'b000010_00:	alu_funct = 10'b00_010_0_xx_x_x;								//srl instruction[21] R = 0
	8'b000010_10:	alu_funct = 10'b00_010_0_xx_x_x;								//srl instruction[21] R = 0
	default: 		alu_funct = 10'b00_0000_0000;									//nop
	endcase

	casez(i_opcode)																//instruction with opcode
	6'b00100?:	alu_opcode = { 8'b10_xxx_0_xx,	i_opcode[1],	1'bx  };		//addi, addiu
	6'b00110?:	alu_opcode = { 6'b11_xxx_0,		i_opcode[1:0],	2'bxx };		//andi, ori
	6'b001110:	alu_opcode = { 6'b11_xxx_0,		i_opcode[1:0],	2'bxx }; 		//xori
	6'b001111:	alu_opcode = { 10'b00_000_1_xx_xx 					  };		//lui
	6'b000010:	alu_opcode = { 10'bxx_xxx_0_xx_xx 					  };		//j
	6'b00010?:	alu_opcode = { 8'b10_xxx_0_xx,	i_opcode[2],	1'bx  };		//beq, bne
	6'b100011:	alu_opcode = { 8'b10_xxx_0_xx,	1'b0,			1'bx  };		//lw,
	6'b101011:	alu_opcode = { 8'b10_xxx_0_xx,	1'b0,			1'bx  };		//sw
	//////	6'b001000	//jr
	default: 	alu_opcode = 10'b00_0000_0000;									//nop
	endcase
end

assign ALUCtrl = i_opcode ? alu_opcode : alu_funct;

////////////////////////////////////////////////////////////////////
//					BYPASS CONTROL & STALL(LW)
////////////////////////////////////////////////////////////////////
always@* begin
	//for rs 
	case(1'b1)
	(!(i_rs^i_rw_ex)) & read_A & write_ex: 		o_ASrc = 2'b01;
	(!(i_rs^i_rw_mem)) & read_A & write_mem:  	o_ASrc = 2'b10;
	(!(i_rs^i_rw_w)) & read_A & write_w: 		o_ASrc = 2'b11;
	default: 									o_ASrc = 2'b00;
	endcase
	//for rt
	case(1'b1)
	(!(i_rt^i_rw_ex)) & read_B & write_ex: 		o_BSrc = 2'b01;
	(!(i_rt^i_rw_mem)) & read_B & write_mem:  	o_BSrc = 2'b10;
	(!(i_rt^i_rw_w)) & read_B & write_w: 		o_BSrc = 2'b11;
	default: 									o_BSrc = 2'b00;
	endcase

end

//stall
always@(posedge i_clk, negedge i_rst_n) begin		//stall register
 if(~i_rst_n)
 	stall_r <=0;
 else
	stall_r<=!(i_opcode^6'b100011);
end

assign stall =	((!(i_rs^i_rw_ex))&stall_r&read_A) | 
				((!(i_rt^i_rw_ex))&stall_r&read_B);
assign o_stall = stall;
 endmodule
