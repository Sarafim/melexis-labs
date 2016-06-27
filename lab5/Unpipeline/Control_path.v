//Control path
`timescale 1ns/1ps
 
 module Control_path(	i_opcode,			//instruction [31:26]
 					 	i_funct,			//instruction [5:0]
 				 		i_overflow,			//overflow from ALU	
 				 		i_R6_21,			//instruction [6,21]
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
						o_Bne				//bne
					 	);
input [5:0]	i_opcode;
input [5:0] i_funct;
input 	i_overflow;
input [1:0] i_R6_21;

output	o_RegDst;			
output	o_RegWr;			
output	o_ExtOp;			
output	o_ALUSrc;			
output	[9:0] o_ALUCtrl;			
output	o_MemRead;			
output	o_MemWrite;			
output	o_MemtoReg;			
output	o_J;
output 	o_Jr;				
output	o_Beq;				
output	o_Bne;
////////////////////////////////////////////////////////////////////
//					INITIALIZATION VARIABLES
////////////////////////////////////////////////////////////////////
//Main Control
reg [9:0]	main_control;						//o_RegDst, t_RegWr, o_ExtOp, o_ALUSrc, o_MemRead, o_MemWrite, o_MemtoReg, o_J, o_Beq, o_Bne;
wire		t_RegWr;							//if overflow for add,sub,addi
//ALU Control
reg [9:0]	alu_funct;							//o_ALUCtrl for R instruction
reg [9:0]	alu_opcode;							//o_ALUCtrl for I instruction
////////////////////////////////////////////////////////////////////
//					MAIN CONTROL
////////////////////////////////////////////////////////////////////
always@* begin
	casez(i_opcode)
	//o_RegDst, o_RegWr		o_ExtOp,o_ALUSrc,o_MemRead,o_MemWrite		o_MemtoReg,o_J,o_Beq,o_Bne;
	6'b000000:	main_control = 10'b11_x0x0_0000;//R
	6'b00100?:	main_control = 10'b01_1100_0000;//addi,addiu
	6'b0011??:	main_control = 10'b01_0100_0000;//andi,ori,xori,lui
	6'b000010:	main_control = 10'bx0_x000_x100;//j
	6'b000100:	main_control = 10'bx0_x000_x010;//beq
	6'b000101:	main_control = 10'bx0_x000_x001;//bne
	6'b100011:	main_control = 10'b01_1110_1000;//lw
	6'b101011:	main_control = 10'bx0_1101_x000;//sw
	//6'b000000	//jr
	default: 	main_control = 10'b00_0000_0000;//nop
	endcase
end
assign	{ o_RegDst, t_RegWr, o_ExtOp, o_ALUSrc, o_MemRead, o_MemWrite, o_MemtoReg, o_J, o_Beq, o_Bne } = main_control;

assign	o_RegWr = ( (!({i_funct[5:2], i_funct[0]} ^ 5'b10000) || !( i_opcode^6'b001000 ) ) & i_overflow) ? 0 : t_RegWr;			//(add,sub || addi), if overflow o_RegWr = 0 
assign  o_Jr = (!i_opcode)&(!(6'b001000^i_funct));
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

assign o_ALUCtrl = i_opcode ? alu_opcode : alu_funct;

 endmodule
