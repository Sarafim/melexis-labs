//MIPS TOP
`timescale 1ns/1ps

module Pipeline_mips_top(i_clk, i_rst_n);

input i_clk;
input i_rst_n;
////////////////////////////////////////////////////////////////////
//					INITIALIZATION VARIABLES
////////////////////////////////////////////////////////////////////
wire			RegDst;					//Rt = 1 or Rd = 0 at RW
wire			RegWr;					//write in Registers = 1
wire			ExtOp;					//signed = 1 or unsigned = 0 extend of Imm16 befor ALU
wire			ALUSrc;					//R  = 0 or I = 1  instruction goes to ALU
wire	[9:0]	ALUCtrl;				//ALU Control
wire			MemRead;				//read from Data memory = 1
wire			MemWrite;				//write to Data Memory = 0
wire			MemtoReg;				//write to Registers from Data memory = 1 ot from ALU = 0
wire			J;						//Jump
wire 			Jr;						//Jump to address in register
wire			Beq;					//beq
wire			Bne;					//bne
wire 	[1:0] 	ASrc;					//bypass_mux for rs
wire 	[1:0] 	BSrc;					//bypass_mux for rt
wire	[5:0]	opcode;					//instruction[31:26]
wire	[5:0]	funct;					//instruction[5:0]
wire			overflow;				//overflow from ALU
wire			zero;					//zero from ALU
wire	[1:0]	r6_21;					//instruction[6], instruction[21] for rorv, ror

wire 	[4:0] 	rs;						//rs addr for bypass and stall
wire 	[4:0] 	rt;						//rt addr for bypass and stall
wire 	[4:0] 	rw_d;					//RegWr 
wire 	[4:0] 	rw_ex;					//RegWr reg at execute phase
wire 	[4:0] 	rw_mem;					//RegWr reg	at memory phase
wire 	[4:0] 	rw_w;					//RegWr reg	at write back phase
wire			stall;					//stall signal
////////////////////////////////////////////////////////////////////
//					DATA PATH & CONTROL PATH
////////////////////////////////////////////////////////////////////
Pipeline_data_path data_path_inst1(	.i_clk(i_clk),
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
									.i_ASrc(ASrc),					//bypass_mux for rs
									.i_BSrc(BSrc),					//bypass_mux for rt
									.i_stall(stall),				//stall signal									
									.o_opcode(opcode),				//instruction [31:26]
									.o_funct(funct),				//instruction [5:0]
									.o_overflow(overflow),			//overflow from ALU	
									.o_zero(zero),					//zero from ALU
									.o_R6_21(r6_21),				//instruction [6,21]
									.o_rs(rs),						//rs addr for bypass and stall
		 				 			.o_rt(rt),						//rt addr for bypass and stall
		 				 			.o_rw_d(rw_d),					//RegWr
									.o_rw_ex(rw_ex),				//RegWr reg at execute phase
									.o_rw_mem(rw_mem),				//RegWr reg	at memory phase
									.o_rw_w(rw_w)					//RegWr reg	at write back phase
									);

Pipeline_control_path Control_path_inst1(	.i_clk(i_clk),
											.i_rst_n(i_rst_n),
											.i_opcode(opcode),			//instruction [31:26]
					 					 	.i_funct(funct),			//instruction [5:0]
					 				 		.i_overflow(overflow),		//overflow from ALU	
					 				 		.i_R6_21(r6_21),			//instruction [6,21]
					 				 		.i_rs(rs),					//rs addr for bypass and stall
		 				 					.i_rt(rt),					//rt addr for bypass and stall
		 				 					.i_rw_d(rw_d),				//RegWr
											.i_rw_ex(rw_ex),			//RegWr reg at execute phase
											.i_rw_mem(rw_mem),			//RegWr reg	at memory phase
											.i_rw_w(rw_w),				//RegWr reg	at write back phase
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
											.o_Bne(Bne),				//bne
											.o_ASrc(ASrc),				//bypass_mux for rs
											.o_BSrc(BSrc),				//bypass_mux for rt
											.o_stall(stall)				//stall signal
										 	);

endmodule