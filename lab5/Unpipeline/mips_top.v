//MIPS TOP
`timescale 1ns/1ps

module mips_top(i_clk, i_rst_n);

input i_clk;
input i_rst_n;
////////////////////////////////////////////////////////////////////
//					INITIALIZATION VARIABLES
////////////////////////////////////////////////////////////////////
wire	RegDst;					
wire	RegWr;					
wire	ExtOp;					
wire	ALUSrc;					
wire	[9:0]	 ALUCtrl;		
wire	MemRead;				
wire	MemWrite;				
wire	MemtoReg;				
wire	J;
wire 	Jr;						
wire	Beq;					
wire	Bne;					
wire	[5:0]	opcode;
wire	[5:0]	funct;
wire	overflow;
wire	zero;
wire	[1:0]	r6_21;
////////////////////////////////////////////////////////////////////
//					DATA PATH & CONTROL PATH
////////////////////////////////////////////////////////////////////
data_path data_path_inst1(	.i_clk(i_clk),
							.i_rst_n(i_rst_n),
							.i_RegDst(RegDst),				//Rt = 1 or Rd = 0 at RW
							.i_RegWr(RegWr),				//write in Registers = 1
							.i_ExtOp(ExtOp),				//signed = 1 or unsigned = 0 extend of Imm16 befor ALU
							.i_ALUSrc(ALUSrc),				//R  = 0 or I = 1  instruction goes to ALU
							.i_ALUCtrl(ALUCtrl),			//ALU Control
							.i_MemRead(MemRead),			//read from Data memory = 1
							.i_MemWrite(MemWrite),			//write to Data Memory = 0
							.i_MemtoReg(MemtoReg),			//write to Registers from Data memory = 1 ot from ALU = 0
							.i_J(J),						//Jump
							.i_Jr(Jr),						//Jump to address in register
							.i_Beq(Beq),					//beq
							.i_Bne(Bne),					//bne
							.o_opcode(opcode),				//instruction [31:26]
							.o_funct(funct),				//instruction [5:0]
							.o_overflow(overflow),			//overflow from ALU	
							.o_zero(zero),					//zero from ALU
							.o_R6_21(r6_21)					//instruction [6,21]
							);

Control_path Control_path_inst1(	.i_opcode(opcode),			//instruction [31:26]
			 					 	.i_funct(funct),			//instruction [5:0]
			 				 		.i_overflow(overflow),		//overflow from ALU	
			 				 		.i_R6_21(r6_21),			//instruction [6,21]
			 					 	.o_RegDst(RegDst),			//Rt = 1 or Rd = 0 at RW
									.o_RegWr(RegWr),			//write in Registers = 1
									.o_ExtOp(ExtOp),			//signed = 1 or unsigned = 0 extend of Imm16 befor ALU
									.o_ALUSrc(ALUSrc),			//R  = 0 or I = 1  instruction goes to ALU
									.o_ALUCtrl(ALUCtrl),		//ALU Control
									.o_MemRead(MemRead),		//read from Data memory = 1
									.o_MemWrite(MemWrite),		//write to Data Memory = 0
									.o_MemtoReg(MemtoReg),		//write to Registers from Data memory = 1 ot from ALU = 0
									.o_J(J),					//Jump
									.o_Jr(Jr),					//Jump to address in register
									.o_Beq(Beq),				//beq
									.o_Bne(Bne)					//bne
								 	);

endmodule