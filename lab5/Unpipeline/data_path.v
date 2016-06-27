`timescale 1ns/1ps

module data_path(	i_clk,
					i_rst_n,
					i_RegDst,			//Rt = 1 or Rd = 0 at RW
					i_RegWr,			//write in Registers = 1
					i_ExtOp,			//signed = 1 or unsigned = 0 extend of Imm16 befor ALU
					i_ALUSrc,			//R  = 0 or I = 1  instruction goes to ALU
					i_ALUCtrl,			//ALU Control
					i_MemRead,			//read from Data memory = 1
					i_MemWrite,			//write to Data Memory = 0
					i_MemtoReg,			//write to Registers from Data memory = 1 ot from ALU = 0
					i_J,				//Jump
					i_Jr,				//Jump to address in register
					i_Beq,				//beq
					i_Bne,				//bne
					o_opcode,
					o_funct,
					o_overflow,
					o_zero,
					o_R6_21
					);
input	i_clk;
input 	i_rst_n;
input	i_RegDst;			
input	i_RegWr;			
input	i_ExtOp;			
input	i_ALUSrc;			
input	[9:0] i_ALUCtrl;			
input	i_MemRead;			
input	i_MemWrite;			
input	i_MemtoReg;			
input	i_J;	
input   i_Jr;			
input	i_Beq;				
input	i_Bne;

output 	[5:0]	o_opcode;
output	[5:0] 	o_funct;
output	o_overflow;
output	o_zero;
output	[1:0]	o_R6_21;
////////////////////////////////////////////////////////////////////
//					INITIALIZATION VARIABLES
////////////////////////////////////////////////////////////////////
//fetch phase
wire [31:0] instruction; //instruction code
//decode & register phase
wire [4:0] 	rw_i;		//third input of the register(address for writing)
wire [31:0] busA;		//first output of the register(address rs)
wire [31:0] busB;		//second output of the register(address rt)
wire [31:0] ex_o;		//output of the extender for Imm16
wire [31:0] alu_B;		//second input for ALU
//execute phase
wire [31:0] alu_result;	//alu result
wire alu_zero;			//zero flag
wire alu_overflow;		//overflow flag

wire [29:0] pc_new; 	//pc+1
wire [29:0] pc_bj_i;	//if j,bne,beq
wire PCSrc;				//control for PC(j, bne, beq, +1)
//memory phase
wire [31:0] data_mem; 	//data from memory
//writeback phase
wire [29:0] pc_i;		//input of the PC 
wire [29:0] pc_o;		//output of the PC 
wire [31:0] regW_i; 	 	//data for BusW(write in the register)
////////////////////////////////////////////////////////////////////
//					FETCH PHASE 
////////////////////////////////////////////////////////////////////
Instruction_rom Instruction_rom_inst1	(	.i_address({pc_o,2'b00}), 
											.o_instruction(instruction) 
										);
////////////////////////////////////////////////////////////////////
//					DECODE & REGISTER FETCH PHASE
////////////////////////////////////////////////////////////////////

assign rw_i=i_RegDst?instruction[15:11]:instruction[20:16];	//R or I type of instruction

Registers Registers_inst1(	.i_clk(i_clk),
							.i_regWr(i_RegWr),				//write in the register
							.i_ra(instruction[25:21]),		//rs
							.i_rb(instruction[20:16]),		//rt
							.i_rw(rw_i),					//rt or rd
							.i_busW(regW_i),				//write, adress .i_rw(rw_i)
							.o_busA(busA),					//busA
							.o_busB(busB)					//busB
						);
Extender Extender_inst1	(	.i_data(instruction[15:0]), 	//Imm16
							.i_ExtOp(i_ExtOp),				//1=signed Extend, 0 = unsigned Extend
							.o_data(ex_o)
						);

assign alu_B = i_ALUSrc ? ex_o : busB;
////////////////////////////////////////////////////////////////////
//					EXECUTE PHASE
////////////////////////////////////////////////////////////////////
ALU ALU_inst1(	.i_data_A(busA), 				//first input
				.i_data_B(alu_B), 				//second input
				.i_ALU_Ctrl(i_ALUCtrl),			//control wire
				.i_sh_amount(instruction[10:6]),//size for shift
				.o_data(alu_result), 			//output result
				.o_zero(alu_zero), 				//zero flag
				.o_overflow(alu_overflow)		//overflow flag
				);
//new instruction address
assign pc_new = pc_o + 1'b1;

Next_PC Next_PC_inst1( 	.i_PC(pc_new),					//next instraction address(pc+1)
						.i_Imm(instruction[25:0]),		//J instruction
						.adr_JR(busA),					//rs
						.i_zero(alu_zero),				//zero flag from ALU
						.i_J(i_J),						//J flag
						.i_Jr(i_Jr),					//JR flag
						.i_beq(i_Beq),					//beq flag
						.i_bne(i_Bne),					//bne flag
						.o_PC(pc_bj_i),					//new pc if j|bne|beq
						.o_PCSrc(PCSrc)					//control for new PC
						);

////////////////////////////////////////////////////////////////////
//					MEMORY PHASE
////////////////////////////////////////////////////////////////////

Data_mem Data_mem_inst1(	.i_clk(i_clk),				
							.i_MemWrite(i_MemWrite),		//contrlo write
							.i_MemRead(i_MemRead),		//control read 
							.i_address(alu_result),			//address 	
							.i_data(busB),					//data for write
							.o_data(data_mem)				//output data
							);

assign regW_i=i_MemtoReg ? data_mem : alu_result; 			//instruction or sw, lw 
////////////////////////////////////////////////////////////////////
//					WRITEBACK PHASE
////////////////////////////////////////////////////////////////////
assign pc_i = PCSrc ? pc_bj_i : pc_new ;						//new pc 
PC PC_inst1(	.i_clk(i_clk),
				.i_rst_n(i_rst_n),
				.i_data(pc_i),
				.o_data(pc_o)
		 	);
////////////////////////////////////////////////////////////////////
//					OUTPUT
////////////////////////////////////////////////////////////////////
assign	o_opcode	= instruction[31:26];
assign 	o_funct 	= instruction[5:0];
assign 	o_overflow 	= alu_overflow;
assign	o_zero	 	= alu_zero;
assign 	o_R6_21 	= {instruction[6],instruction[21]};
endmodule