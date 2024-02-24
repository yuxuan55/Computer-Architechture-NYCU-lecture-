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

module Simple_Single_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  //Internal Signals
wire	[31: 0]pc_o, adder_pc, sign_extend, shifter_branch, adder_branch, mux_branch, mux_jump, im_o, mux_write, read_data_1, read_data_2, zero_filled, alu_src2, alu_result, shifter_alusrc2, rddata_src, dm_o, shifter_jump, shifter_zero_filled;
//wire	[27: 0]shifter_jump;
wire	[4: 0]mux_write_reg;
wire	[3: 0]ac_alu_operation;
wire	[2: 0]aluop; 
wire	[1: 0]ac_furslt, regdst, memtoreg;
wire	mux_zero, jump, regwrite, alusrc, branch, branchtype, ac_leftright, alu_zero, alu_overflow, memread, memwrite;

  //modules
  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(mux_jump),
      .pc_out_o(pc_o)
  );

  Adder Adder1 (
      .src1_i(pc_o),
      .src2_i(32'd4),
      .sum_o (adder_pc)
  );

  Shifter Shifter_branch (
      .result(shifter_branch),
      .leftRight(1'b0),
      .shamt(5'b00010),
      .sftSrc(sign_extend)
  );

  Adder Adder2 (
      .src1_i(adder_pc),
      .src2_i(shifter_branch),
      .sum_o (adder_branch)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_branch (
      .data0_i (adder_pc),
      .data1_i (adder_branch),
      .select_i(branch & mux_zero),
      .data_o  (mux_branch)
  );

  Shifter Shifter_Jump (
      .result(shifter_jump),
      .leftRight(1'b0),
      .shamt(5'b00010),
      .sftSrc({6'd0, im_o[25:0]})
  );

  Mux2to1 #(
      .size(32)
  ) Mux_jump (
      .data0_i (mux_branch),
      .data1_i ({adder_pc[31:28], shifter_jump[27:0]}),
      .select_i(jump),
      .data_o  (mux_jump)
  );

  Instr_Memory IM (
      .pc_addr_i(pc_o),
      .instr_o  (im_o)
  );

  Mux3to1 #(
      .size(5)
  ) Mux_Write_Reg (
      .data0_i (im_o[20:16]),
      .data1_i (im_o[15:11]),
      .data2_i (5'd31),
      .select_i(regdst),
      .data_o  (mux_write_reg)
  );


  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(im_o[25:21]),
      .RTaddr_i(im_o[20:16]),
      .RDaddr_i(mux_write_reg),
      .RDdata_i(mux_write),
      .RegWrite_i(regwrite),
      .RSdata_o(read_data_1),
      .RTdata_o(read_data_2)
  );

  Decoder Decoder (
      .instr_op_i(im_o[31:26]),
      .RegWrite_o(regwrite),
      .ALUOp_o(aluop),
      .ALUSrc_o(alusrc),
      .RegDst_o(regdst),
      .Jump_o(jump),
      .Branch_o(branch),
      .BranchType_o(branchtype),
      .MemRead_o(memread),
      .MemWrite_o(memwrite),
      .MemtoReg_o(memtoreg)
  );

  ALU_Ctrl AC (
      .funct_i(im_o[5:0]),
      .ALUOp_i(aluop),
      .ALU_operation_o(ac_alu_operation),
      .FURslt_o(ac_furslt),
      .leftRight_o(ac_leftright)
  );

  Sign_Extend SE (
      .data_i(im_o[15:0]),
      .data_o(sign_extend)
  );

  Zero_Filled ZF (
      .data_i(im_o[15:0]),
      .data_o(zero_filled)
  );

  Shifter Shifter_zero_filled (
      .result(shifter_zero_filled),
      .leftRight(ac_leftright),
      .shamt(im_o[10:6]),
      .sftSrc(zero_filled)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i (read_data_2),
      .data1_i (sign_extend),
      .select_i(alusrc),
      .data_o(alu_src2)
  );

  ALU ALU (
      .aluSrc1(read_data_1),
      .aluSrc2(alu_src2),
      .ALU_operation_i(ac_alu_operation),
      .result(alu_result),
      .zero(alu_zero),
      .overflow(alu_overflow)
  );

  Shifter Shifter_ALUsrc2 (
      .result(shifter_alusrc2),
      .leftRight(ac_leftright),
      .shamt(im_o[10:6]),
      .sftSrc(alu_src2)
  );

Mux2to1 #(
      .size(1)
) Mux_zero (
      .data0_i (alu_zero),
      .data1_i (~alu_zero),
      .select_i(branchtype),
      .data_o  (mux_zero)
  );

  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i (alu_result),
      .data1_i (shifter_alusrc2),
      .data2_i (shifter_zero_filled),
      .select_i(ac_furslt),
      .data_o  (rddata_src)
  );

  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(rddata_src),
      .data_i(read_data_2),
      .MemRead_i(memread),
      .MemWrite_i(memwrite),
      .data_o(dm_o)
  );

  Mux3to1 #(
      .size(32)
  ) Mux_Write (
      .data0_i(rddata_src),
      .data1_i(dm_o),
      .data2_i (adder_pc),
      .select_i(memtoreg),
      .data_o(mux_write)
  );

endmodule



