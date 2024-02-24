`include "Program_Counter.v"
`include "Adder.v"
`include "Instr_Memory.v"
`include "Mux2to1.v"
`include "Mux3to1.v"
`include "Reg_File.v"
`include "Decoder.v"
`include "ALU_Ctrl.v"
`include "Sign_Extend.v"
`include "Zero_Filled.v"
`include "ALU.v"
`include "Shifter.v"
`include "Data_Memory.v"
`include "Pipe_Reg.v"

module Pipeline_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  /*your code here*/

// IF stage 
wire [32-1:0] pc, pc_out, instr, pc_out_added, pc_out_added_id, instr_id;

// ID stage
wire [32-1:0] ReadData1, ReadData2, signed_addr, ReadData1_ex, ReadData2_ex, signed_addr_ex, pc_out_added_ex;
wire RegDst, MemtoReg, RegDst_ex, MemtoReg_ex;
wire [2-1:0] ALUOp, ALUOp_ex;
wire RegWrite, ALUSrc, Branch, MemRead, MemWrite, RegWrite_ex, ALUSrc_ex, Branch_ex, MemRead_ex, MemWrite_ex;
wire [21-1:0] instr_ex;

// EX stage
wire [32-1:0] ALUin_2, alu_result, adder_out2, alu_result_mem, adder_out2_mem, ReadData2_mem;
wire [5-1:0] write_Reg_address, write_Reg_address_mem;
wire [4-1:0] ALU_operation;
wire ALU_zero, MemtoReg_mem, RegWrite_mem, Branch_mem, MemRead_mem, MemWrite_mem, ALU_zero_mem;

// MEM stage 
wire [32-1:0] MemRead_data, MemRead_data_wb, alu_result_wb;
wire [5-1:0] write_Reg_address_wb;
wire MemtoReg_wb, RegWrite_wb;

// WB stage 
wire [32-1:0] writeData;

//-------------------------------------------------//

// IF stage
Mux2to1 #(.size(32)) Mux0(
	.data0_i(pc_out_added),
    .data1_i(adder_out2_mem),
    .select_i(Branch_mem & ALU_zero_mem),
    .data_o(pc)
);
Program_Counter PC(
	.clk_i(clk_i),      
	.rst_n(rst_i),     
	.pc_in_i(pc),   
	.pc_out_o(pc_out)
);
Instr_Memory IM(
	.pc_addr_i(pc_out),  
	.instr_o(instr)
);
Adder Add_pc(
	.src1_i(pc_out),     
	.src2_i(32'd4),
	.sum_o(pc_out_added)
);		
Pipe_Reg #(.size(64)) IF_ID(     
	.clk_i(clk_i),
    .rst_n(rst_i),
	.data_i({pc_out_added, instr}),
    .data_o({pc_out_added_id, instr_id})
);

// ID stage
Reg_File RF(
	.clk_i(clk_i),      
	.rst_n(rst_i) ,     
    .RSaddr_i(instr_id[25:21]),  
    .RTaddr_i(instr_id[20:16]),  
    .RDaddr_i(write_Reg_address_wb),  
    .RDdata_i(writeData), 
    .RegWrite_i(RegWrite_wb),
    .RSdata_o(ReadData1),  
    .RTdata_o(ReadData2)
);
Decoder Control(
	.instr_op_i(instr_id[31:26]), 
	.RegWrite_o(RegWrite), 
	.ALUOp_o(ALUOp),   
	.ALUSrc_o(ALUSrc),   
	.RegDst_o(RegDst),
	.Branch_o(Branch),
	.MemRead_o(MemRead), 
	.MemWrite_o(MemWrite), 
	.MemtoReg_o(MemtoReg)
);
Sign_Extend Sign_Extend(
	.data_i(instr_id[15:0]),
    .data_o(signed_addr)
);	
Pipe_Reg #(.size(158)) ID_EX(
	.clk_i(clk_i),
    .rst_n(rst_i),
    .data_i({ReadData1, ReadData2, instr_id[20:0], pc_out_added_id, RegWrite, RegDst, ALUSrc, Branch, MemRead, MemWrite, MemtoReg, ALUOp, signed_addr}),
    .data_o({ReadData1_ex, ReadData2_ex, instr_ex, pc_out_added_ex, RegWrite_ex, RegDst_ex, ALUSrc_ex, Branch_ex, MemRead_ex, MemWrite_ex, MemtoReg_ex, ALUOp_ex, signed_addr_ex})
);

// EX stage	   
ALU ALU(
	.aluSrc1(ReadData1_ex),
	.aluSrc2(ALUin_2),
	.ALU_operation_i(ALU_operation),
	.result(alu_result),
	.zero(ALU_zero)
);		
ALU_Ctrl ALU_Control(
	.funct_i(instr_ex[5:0]),   
    .ALUOp_i(ALUOp_ex),   
    .ALU_operation_o(ALU_operation)
);
Mux2to1 #(.size(32)) Mux1(
	.data0_i(ReadData2_ex),
    .data1_i(signed_addr_ex),
    .select_i(ALUSrc_ex),
    .data_o(ALUin_2)
);	
Mux2to1 #(.size(5)) Mux2(
	.data0_i(instr_ex[20:16]),
    .data1_i(instr_ex[15:11]),
    .select_i(RegDst_ex),
    .data_o(write_Reg_address)
);
Adder Add_pc_branch(
	.src1_i(pc_out_added_ex),     
	.src2_i({signed_addr_ex[29:0], 2'b00}),
	.sum_o(adder_out2)    
);
Pipe_Reg #(.size(107)) EX_MEM(
	.clk_i(clk_i),
    .rst_n(rst_i),
	.data_i({alu_result, adder_out2, write_Reg_address, ReadData2_ex, RegWrite_ex, Branch_ex, MemRead_ex, MemWrite_ex, MemtoReg_ex, ALU_zero}),
    .data_o({alu_result_mem, adder_out2_mem, write_Reg_address_mem, ReadData2_mem, RegWrite_mem, Branch_mem, MemRead_mem, MemWrite_mem, MemtoReg_mem, ALU_zero_mem})
);

// MEM stage
Data_Memory DM(
	.clk_i(clk_i), 
	.addr_i(alu_result_mem), 
	.data_i(ReadData2_mem), 
	.MemRead_i(MemRead_mem), 
	.MemWrite_i(MemWrite_mem), 
	.data_o(MemRead_data)
);
Pipe_Reg #(.size(71)) MEM_WB(
	.clk_i(clk_i),
    .rst_n(rst_i),
	.data_i({MemRead_data, alu_result_mem, write_Reg_address_mem, MemtoReg_mem, RegWrite_mem}),
    .data_o({MemRead_data_wb, alu_result_wb, write_Reg_address_wb, MemtoReg_wb, RegWrite_wb})
);

// WB stage
Mux2to1 #(.size(32)) Mux3(
	.data0_i(alu_result_wb),
    .data1_i(MemRead_data_wb),
    .select_i(MemtoReg_wb),
    .data_o(writeData)
);

endmodule