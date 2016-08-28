//Control path
`timescale 1ns/1ps
 
 module Control_path(	i_instruction,				//instruction [31:26]
 					 	i_overflow,				//overflow from ALU	
 				 		o_RegDst,				//Rt = 1 or Rd = 0 at RW
						o_RegWr,				//write in Registers = 1
						o_ExtOp,				//signed = 1 or unsigned = 0 extend of Imm16 befor ALU
						o_ALUSrc,				//R  = 0 or I = 1  instruction goes to ALU
						o_ALUCtrl,				//ALU Control
						o_MemRead,				//read from Data memory = 1
						o_MemWrite,				//write to Data Memory = 0
						o_MemtoReg,				//write to Registers from Data memory = 1 ot from ALU = 0
						o_J,					//Jump
						o_Jr,					//Jump to address in register
						o_Beq,					//beq
						o_Bne,					//bne																			//bne
						o_mc0,					//move coproc0
						o_coproc0_invalid_instr,//	invalid instruction interrupt
						o_eret,					//	eret control flag
						o_coproc0_we			// 	write enable for coproc0
					);
input	[31:0] 	i_instruction;
input 			i_overflow;

output	o_RegDst;			
output	o_RegWr;			
output	o_ExtOp;			
output	o_ALUSrc;			
output	[10:0] o_ALUCtrl;			
output	o_MemRead;			
output	o_MemWrite;			
output	o_MemtoReg;			
output	o_J;
output 	o_Jr;				
output	o_Beq;				
output	o_Bne;
output	o_mc0;
output	o_coproc0_invalid_instr;
output	o_eret;
output	o_coproc0_we;
////////////////////////////////////////////////////////////////////
//					INITIALIZATION VARIABLES
////////////////////////////////////////////////////////////////////
wire [5:0]	opcode;
wire [5:0]	funct;
wire [1:0] 	R6_21;
//Main Control
reg [13:0]	main_control;						//o_RegDst, t_RegWr, o_ExtOp, o_ALUSrc, o_MemRead, o_MemWrite, o_MemtoReg, o_J, o_Beq, o_Bne;
wire		t_RegWr;							//if overflow for add,sub,addi
//ALU Control
reg [10:0]	alu_funct;							//o_ALUCtrl for R instruction
reg [10:0]	alu_opcode;							//o_ALUCtrl for I instruction

assign opcode = i_instruction[31:26];
assign funct = i_instruction[5:0];
assign R6_21 = {i_instruction[6],i_instruction[21]};
////////////////////////////////////////////////////////////////////
//					MAIN CONTROL
////////////////////////////////////////////////////////////////////
always@* begin
	casez(opcode)
	//o_RegDst, o_RegWr		o_ExtOp,o_ALUSrc,o_MemRead,o_MemWrite		o_MemtoReg,o_J,o_Beq,o_Bne		o_mc0,o_coproc0_invalid_instr,o_eret,o_coproc0_we;
	6'b000000:	main_control = 14'b11_x0x0_0000_0000;//R
	6'b00100?:	main_control = 14'b01_1100_0000_0000;//addi,addiu
	6'b0011??:	main_control = 14'b01_0100_0000_0000;//andi,ori,xori,lui
	6'b000010:	main_control = 14'bx0_x000_x100_0000;//j
	6'b000100:	main_control = 14'bx0_x000_x010_0000;//beq
	6'b000101:	main_control = 14'bx0_x000_x001_0000;//bne
	6'b100011:	main_control = 14'b01_1110_1000_0000;//lw
	6'b101011:	main_control = 14'bx0_1101_x000_0000;//sw
	6'b010000:	begin
					if(i_instruction[25]&(!i_instruction[24:6])&(i_instruction[5:0] == 6'b011000))	begin	//eret if(instruction[25:0] == 26'b1_000000000000000000_011000)	
						main_control = 14'b00_0000_0000_0010;
					end 
					else if(!i_instruction[25:21]&!i_instruction[10:3])									//mfc0 if(instruction[25:3] == 23'b00000_xxxxxxxxxx_00000000)	
						main_control = 14'b01_0000_1000_1000;
					else if(i_instruction[23]&!i_instruction[25:24]&!i_instruction[22:21]&!i_instruction[10:3])	//mtc0   if(instruction[25:3] == 23'b00100_xxxxxxxxxx_00000000)
						main_control = 14'b00_0000_0000_0001;
					else 
						main_control = 14'b00_0000_0000_0100;//nop
				end
	default: 	main_control = 14'b00_0000_0000_0100;//nop
	endcase
end


assign	{ o_RegDst, t_RegWr, o_ExtOp, o_ALUSrc, o_MemRead, o_MemWrite, o_MemtoReg, o_J, o_Beq, o_Bne,o_mc0, o_coproc0_invalid_instr, o_eret,o_coproc0_we } = main_control;

assign	o_RegWr = ( (!({funct[5:2], funct[0]} ^ 5'b10000) || !( opcode^6'b001000 ) ) & i_overflow) ? 0 : t_RegWr;			//(add,sub || addi), if overflow o_RegWr = 0 
assign  o_Jr = (!opcode)&(!(6'b001000^funct));
////////////////////////////////////////////////////////////////////
//					ALU CONTROL
////////////////////////////////////////////////////////////////////
// [1:0]	i_ALU_sel;	//Shift=00, SLT=01, ARITH=10, Logic=11
// [2:0]	i_sh_op;	//LUI,SLL=000, 	SRL =010, SRA=011, 	ROR=001
//						//SLLV=100, SRLV=110, SRAV=111, RORV=101
//			i_lui
// [1:0]	i_log_op;	//AND,ANDI=00, OR,ORI=01, XOR,XORI=10, NOR=11 
//			i_ar_op_en	// enable for overflow
// 			i_ar_op;	//ADD,ADDU,ADDI=0, SUB,SUBU,SUBI=1
//			i_slt_op;	//SLT = 0, SLTU = 1;
//i_ALU_sel,	i_sh_op,	i_lui,	i_log_op,	i_ar_op_en, i_ar_op,	i_slt_op
////////////////////////////////////////////////////////////////////
always@* begin
	casez( {funct, R6_21} )														//R instruction
	8'b1000????: 	alu_funct = { 9'b10_xxx_0_xx_1,	funct[1],		1'bx  		};	//add,addu,sub,subu
	8'b1001????: 	alu_funct = { 6'b11_xxx_0,		funct[1:0],	3'b0xx 		};	//and,or,xor,nor
	8'b10101???:	alu_funct = { 10'b01_xxx_0_xx_01, funct[0]			  		}; 	//slt,sltu
	8'b000100??:	alu_funct = { 2'b00, 			funct[2:0],6'b0_xx_0_x_x	};	//sllv
	8'b000000??:	alu_funct = { 2'b00, 			funct[2:0],6'b0_xx_0_x_x	};	//sll
	8'b000111??:	alu_funct = { 2'b00, 			funct[2:0],6'b0_xx_0_x_x	};	//srav
	8'b000011??:	alu_funct = { 2'b00, 			funct[2:0],6'b0_xx_0_x_x	};	//sra
	
	
	
	8'b001100_00:	alu_funct = { 11'bxx_xxx_0_xx_0xx 					 		};  //Jr
	8'b000110_1?:	alu_funct = 11'b00_101_0_xx_0x_x;								//rorv instruction [6]  R = 1
	8'b000110_0?:	alu_funct = 11'b00_110_0_xx_0x_x;								//srlv instruction [6] 	R = 0
	8'b000010_01:	alu_funct = 11'b00_001_0_xx_0x_x;								//ror instruction[21] R = 1
	8'b000010_11:	alu_funct = 11'b00_001_0_xx_0x_x;								//ror instruction[21] R = 1
	8'b000010_00:	alu_funct = 11'b00_010_0_xx_0x_x;								//srl instruction[21] R = 0
	8'b000010_10:	alu_funct = 11'b00_010_0_xx_0x_x;								//srl instruction[21] R = 0
	default: 		alu_funct = 11'b00_0000_00000;									//nop
	endcase

	casez(opcode)																//instruction with opcode
	6'b00100?:	alu_opcode = { 9'b10_xxx_0_xx1,	opcode[1],	1'bx  };		//addi, addiu
	6'b00110?:	alu_opcode = { 6'b11_xxx_0,		opcode[1:0],	3'b0xx };		//andi, ori
	6'b001110:	alu_opcode = { 6'b11_xxx_0,		opcode[1:0],	3'b0xx }; 		//xori
	6'b001111:	alu_opcode = { 11'b00_000_1_xx_0xx 					  };		//lui
	6'b000010:	alu_opcode = { 11'bxx_xxx_0_xx_0xx 					  };		//j
	6'b00010?:	alu_opcode = { 9'b10_xxx_0_xx_0,	opcode[2],	1'bx  };		//beq, bne
	6'b100011:	alu_opcode = { 8'b10_xxx_0_xx,	2'b00,			1'bx  };		//lw,
	6'b101011:	alu_opcode = { 8'b10_xxx_0_xx,	2'b00,			1'bx  };		//sw
	//////	6'b001000	//jr
	default: 	alu_opcode = 11'b00_0000_0000;									//nop
	endcase
end


assign o_ALUCtrl = opcode ? alu_opcode : alu_funct;

 endmodule
