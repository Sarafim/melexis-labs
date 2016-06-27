`timescale 1ns/1ps

module Pipeline_data_path(	i_clk,
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
					i_ASrc,				//bypass for rs
					i_BSrc,				//bypass_mux for rt
					i_stall,			//stall signal
					o_opcode,			//instruction [31:26]
					o_funct,			//instruction [5:0]
					o_overflow,			//overflow from ALU	
					o_zero,				//zero from ALU
					o_R6_21,			//instruction [6,21]
					o_rs,				//rs addr for bypass and stall
					o_rt,				//rt addr for bypass and stall
					o_rw_d,				//RegWr
					o_rw_ex,			//RegWr reg at execute phase
					o_rw_mem,			//RegWr reg	at memory phase
					o_rw_w				//RegWr reg	at write back phase
					);

input			i_clk;
input 			i_rst_n;
input			i_RegDst;			
input			i_RegWr;			
input			i_ExtOp;			
input			i_ALUSrc;			
input	[9:0] 	i_ALUCtrl;			
input			i_MemRead;			
input			i_MemWrite;			
input			i_MemtoReg;			
input			i_J;	
input   		i_Jr;			
input			i_Beq;				
input			i_Bne;
input 	[1:0] 	i_ASrc;
input 	[1:0]	i_BSrc;
input 			i_stall;

output 	[5:0]	o_opcode;
output	[5:0] 	o_funct;
output			o_overflow;
output			o_zero;
output  [1:0] 	o_R6_21;
output  [4:0] 	o_rs;
output  [4:0] 	o_rt;
output  [4:0] 	o_rw_d;
output  [4:0] 	o_rw_ex;
output  [4:0] 	o_rw_mem;
output  [4:0] 	o_rw_w;

////////////////////////////////////////////////////////////////////
//					INITIALIZATION VARIABLES
////////////////////////////////////////////////////////////////////
//fetch phase
wire [31:0] instruction; 	//instruction code in fetch phase
//decode & register phase
reg [31:0] d_instruction;	//instruction code in decode phase

wire [4:0] 	rw_i;			//third input of the register(address for writing)
wire [31:0] busA;			//first output of the register(address rs)
wire [31:0] busB;			//second output of the register(address rt)
wire [31:0] extender_o;		//output of the extender for Imm16
wire [31:0] alu_B;			//second input for ALU

reg [31:0] bypass_A;		//bypass_mux output
reg [31:0] bypass_B;		//bypass_mux output

//execute phase
reg [4:0] 	ex_rw_i;		//third input of the register(address for writing)
reg [31:0] 	ex_busA;		//first output of the register(address rs)
reg [31:0] 	ex_busB;		//second output of the register(address rt)
reg [31:0] 	ex_alu_B;		//second input for ALU
reg [4:0]  	ex_instruction;	//instruction[10:6] for shift operations

wire [31:0] alu_result;		//alu result
wire		alu_zero;		//zero flag
wire		alu_overflow;	//overflow flag

wire [29:0] pc_new; 		//pc+1
wire [29:0] pc_bj_i;		//if j,bne,beq
wire 		PCSrc;			//control for PC(j, bne, beq, +1)
wire 		branch_zero;	//zero for bne and beq
//memory phase
reg [4:0] 	mem_rw_i;		//third input of the register(address for writing)
reg [31:0] 	mem_alu_result;	//alu result
reg [31:0] 	mem_busB;		//second output of the register(address rt)

wire [31:0] data_mem; 		//data from memory
wire [31:0] regW_i; 		//data for BusW(write in the register)
//writeback phase
reg [4:0] 	w_rw_i;			//third input of the register(address for writing)
wire [29:0] pc_i;			//input of the PC 
wire [29:0] pc_o;			//output of the PC 

reg [31:0] w_regW_i; 		//data for BusW(write in the register)
////////////////////////////////////////////////////////////////////
//					FETCH PHASE 
////////////////////////////////////////////////////////////////////
Instruction_rom Instruction_rom_inst1	(	.i_address({pc_o,2'b00}), 		//instruction address
											.o_instruction(instruction) 	//new instruction
										);

//pipeline reg
always@(posedge i_clk, negedge i_rst_n) begin
	if(~i_rst_n) 
		d_instruction 	<= 32'h00000000;
	else if(!i_stall)
		d_instruction 	<= instruction;
end
////////////////////////////////////////////////////////////////////
//					DECODE & REGISTER FETCH PHASE
////////////////////////////////////////////////////////////////////

assign rw_i=i_RegDst?d_instruction[15:11]:d_instruction[20:16];	//R or I type of instruction

Registers Registers_inst1(	.i_clk(i_clk),
							.i_regWr(i_RegWr),					//write in the register
							.i_ra(d_instruction[25:21]),		//rs
							.i_rb(d_instruction[20:16]),		//rt
							.i_rw(w_rw_i),						//rt or rd
							.i_busW(w_regW_i),					//write, adress .i_rw(rw_i)
							.o_busA(busA),						//busA
							.o_busB(busB)						//busB
						);
Extender Extender_inst1	(	.i_data(d_instruction[15:0]), 		//Imm16
							.i_ExtOp(i_ExtOp),					//1=signed Extend, 0 = unsigned Extend
							.o_data(extender_o)
						);


//bypassing
always@* begin
	case(i_ASrc)
	2'b00:	bypass_A = busA;					//without
	2'b01:	bypass_A = alu_result;				//execute
	2'b10:	bypass_A = regW_i;					//memory
	2'b11:	bypass_A = w_regW_i;				//writeback
	default:bypass_A = 32'h00000000;			//nothing
	endcase
	
	case(i_BSrc)
	2'b00: 	bypass_B = busB;					//without
	2'b01:	bypass_B = alu_result;				//execute
	2'b10:	bypass_B = regW_i;					//memory
	2'b11:	bypass_B = w_regW_i;				//writeback
	default:bypass_B = 32'h00000000;			//nothing
	endcase
end


assign alu_B = i_ALUSrc ? extender_o : bypass_B;		//R or I instruction

//new instruction address
assign pc_new = pc_o + 1'b1;							//compute new instruction address
assign branch_zero = !(bypass_A ^ bypass_B);			//decode zero flag for bne and beq

Next_PC Next_PC_inst1( 	.i_PC(pc_o),					//next instraction address(pc+1)
						.i_Imm(d_instruction[25:0]),	//J instruction
						.adr_JR(bypass_A),				//rs
						.i_zero(branch_zero),			//zero flag from ALU
						.i_J(i_J),						//J flag
						.i_Jr(i_Jr),					//JR flag
						.i_beq(i_Beq),					//beq flag
						.i_bne(i_Bne),					//bne flag
						.o_PC(pc_bj_i),					//new pc if j|bne|beq
						.o_PCSrc(PCSrc)					//control for new PC
						);

//pipeline reg
always@(posedge i_clk, negedge i_rst_n) begin
	if(~i_rst_n) begin
		ex_rw_i			<= 5'b00000;
		ex_busA			<= 32'h00000000;
		ex_alu_B 		<= 32'h00000000;
		ex_busB 		<= 32'h00000000;
		ex_instruction 	<= 5'b00000;
	end
	else begin
		ex_rw_i			<= rw_i;
		ex_busA			<= bypass_A;
		ex_alu_B 		<= alu_B;
		ex_busB 		<= bypass_B;
		ex_instruction 	<= d_instruction[10:6];
	end
end
////////////////////////////////////////////////////////////////////
//					EXECUTE PHASE
////////////////////////////////////////////////////////////////////
ALU ALU_inst1(	.i_data_A(ex_busA), 				//first input
				.i_data_B(ex_alu_B), 				//second input
				.i_ALU_Ctrl(i_ALUCtrl),				//control wire
				.i_sh_amount(ex_instruction),		//size for shift
				.o_data(alu_result), 				//output result
				.o_zero(alu_zero), 					//zero flag
				.o_overflow(alu_overflow)			//overflow flag
				);

//pipeline reg
always@(posedge i_clk, negedge i_rst_n) begin
	if(~i_rst_n) begin
		mem_rw_i		<= 5'b00000;
		mem_alu_result 	<= 32'h00000000;
		mem_busB 		<= 32'h00000000;
	end
	else begin
		mem_rw_i		<= ex_rw_i;
		mem_alu_result 	<= alu_result;
		mem_busB		<= ex_busB;
	end
end
////////////////////////////////////////////////////////////////////
//					MEMORY PHASE
////////////////////////////////////////////////////////////////////

Data_mem Data_mem_inst1(	.i_clk(i_clk),				
							.i_MemWrite(i_MemWrite),		//contrlo write
							.i_MemRead(i_MemRead),			//control read 
							.i_address(mem_alu_result),		//address 	
							.i_data(mem_busB),				//data for write
							.o_data(data_mem)				//output data
							);

assign regW_i=i_MemtoReg ? data_mem : mem_alu_result; 		//instruction or sw, lw 

//pipeline reg
always @(posedge i_clk, negedge i_rst_n) begin
	if(!i_rst_n)begin
		w_regW_i <= 32'h00000000;
		w_rw_i	<= 5'b00000;
	end	
	else begin
		w_rw_i	<= mem_rw_i;
		w_regW_i <= regW_i;
	end
end
////////////////////////////////////////////////////////////////////
//					WRITEBACK PHASE
////////////////////////////////////////////////////////////////////
assign pc_i = PCSrc ? pc_bj_i : pc_new ;						//new pc 

PC PC_inst1(	.i_clk(i_clk),
				.i_rst_n(i_rst_n),
				.i_we(i_stall),
				.i_data(pc_i),
				.o_data(pc_o)
		 	);
////////////////////////////////////////////////////////////////////
//					OUTPUT
////////////////////////////////////////////////////////////////////
assign	o_opcode	= d_instruction[31:26];
assign 	o_funct 	= d_instruction[5:0];
assign 	o_overflow 	= alu_overflow;
assign	o_zero	 	= alu_zero;
assign 	o_R6_21 	= {d_instruction[6],d_instruction[21]};
assign 	o_rs 		= d_instruction[25:21];
assign	o_rt		= d_instruction[20:16];

assign  o_rw_d	 	= rw_i;
assign  o_rw_ex 	= ex_rw_i;
assign  o_rw_mem 	= mem_rw_i;
assign  o_rw_w 		= w_rw_i;
endmodule