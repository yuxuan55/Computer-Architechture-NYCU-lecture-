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
  //Internal Signles
  wire [32-1:0] pc_in;
  wire [32-1:0] pc_out;
  wire [32-1:0] pc_add;
  wire [32-1:0] pc_branch;
  wire [32-1:0] pc_no_jump;
  wire [32-1:0] pc_temp;
  wire [32-1:0] instr;
  wire RegWrite;
  wire [2-1:0] ALUOp;
  wire ALUSrc;
  wire RegDst;
  wire Jump;
  wire Branch;
  wire BranchType;
  wire JRsrc;
  wire MemRead;
  wire MemWrite;
  wire MemtoReg;
  wire [5-1:0] RegAddrTemp;
  wire [5-1:0] RegAddr;
  wire [32-1:0] WriteData;
  wire [32-1:0] RSdata;
  wire [32-1:0] RTdata;
  wire [4-1:0] ALU_operation;
  wire [2-1:0] FURslt;
  wire sftVariable;
  wire leftRight;
  wire [32-1:0] extendData;
  wire [32-1:0] zeroData;
  wire [32-1:0] ALUsrcData;
  wire [32-1:0] ALUresult;
  wire zero;
  wire overflow;
  wire [5-1:0] shamt;
  wire [32-1:0] sftResult;
  wire [32-1:0] RegData;
  wire [32-1:0] MemData;
  wire [32-1:0] DataNoJal;

  wire [64-1:0] PR1_o;
  wire [190-1:0] PR2_o;
  wire [139-1:0] PR3_o;
  wire [71-1:0] PR4_o;
  wire [32-1:0] WData;

  //modules
  Mux2to1 #(
      .size(32)
  ) Mux_branch (
      .data0_i (PR3_o[32:1]),//PC+4
      .data1_i (PR3_o[128:97]),//branch address
      .select_i(PR3_o[136] & PR3_o[0]),// branch & zero
      .data_o  (pc_no_jump)
  );

  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(pc_no_jump),
      .pc_out_o(pc_out)
  );

  Adder Adder1 (
      .src1_i(pc_out),
      .src2_i(32'd4),
      .sum_o (pc_add)
  );

  Instr_Memory IM (
      .pc_addr_i(pc_out),
      .instr_o  (instr)
  );



//////////////////////////////////////////////
  Pipe_Reg #(
      .size(64)
  ) PR1 (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i ({pc_add, instr}),
      .data_o (PR1_o)
  );
//////////////////////////////////////////////




  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(PR1_o[25:21]),
      .RTaddr_i(PR1_o[20:16]),
      .RDaddr_i(PR4_o[4:0]),
      .RDdata_i(WData),
      .RegWrite_i(PR4_o[70]),
      .RSdata_o(RSdata),
      .RTdata_o(RTdata)
  );

  Decoder Decoder (
      .instr_op_i(PR1_o[31:26]),
      .RegWrite_o(RegWrite),        //WB
      .ALUOp_o(ALUOp),              //EX
      .ALUSrc_o(ALUSrc),            //EX
      .RegDst_o(RegDst),            //EX
      .Jump_o(Jump),                
      .Branch_o(Branch),            //MEM
      .BranchType_o(BranchType),    
      .MemRead_o(MemRead),          //MEM
      .MemWrite_o(MemWrite),        //MEM
      .MemtoReg_o(MemtoReg)         //WB
  );

  Sign_Extend SE (
      .data_i(PR1_o[15:0]),
      .data_o(extendData)
  );

  Zero_Filled ZF (
      .data_i(PR1_o[15:0]),
      .data_o(zeroData)
  );







//////////////////////////////////////////////
  Pipe_Reg #(
      .size(190)
  ) PR2 (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i ({RegWrite, MemtoReg, //1,1 W
      Branch, MemRead, MemWrite, //1,1,1 M
      RegDst, ALUOp, ALUSrc, //1,2,1 EX
      PR1_o[63:32], //32 PC+4
      RSdata, RTdata, extendData, zeroData, //32*4
      PR1_o[20:0] //instr[20:0]
      }),
      .data_o (PR2_o)
  );
//////////////////////////////////////////////






  Mux2to1 #(
      .size(5)
  ) Mux_RS_RT (
      .data0_i (PR2_o[20:16]),
      .data1_i (PR2_o[15:11]),
      .select_i(PR2_o[184]),
      .data_o  (RegAddrTemp)
  );

  Adder Adder2 (
      .src1_i(PR2_o[180:149]),
      .src2_i({PR2_o[84-2:53], 2'b00}),
      .sum_o (pc_branch)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i (PR2_o[116:85]),
      .data1_i (PR2_o[84:53]),
      .select_i(PR2_o[181]),
      .data_o  (ALUsrcData)
  );

  ALU_Ctrl AC (
      .funct_i(PR2_o[5:0]),
      .ALUOp_i(PR2_o[183:182]),
      .ALU_operation_o(ALU_operation),
      .FURslt_o(FURslt),
      .sftVariable_o(sftVariable),
      .leftRight_o(leftRight),
      .JRsrc_o(JRsrc)
  );


  ALU ALU (
      .aluSrc1(PR2_o[148:117]),
      .aluSrc2(ALUsrcData),
      .ALU_operation_i(ALU_operation),
      .result(ALUresult),
      .zero(zero),
      .overflow(overflow)
  );

  Mux2to1 #(
      .size(5)
  ) Shamt_Src (
      .data0_i (PR2_o[10:6]),
      .data1_i (PR2_o[117+4:117]),
      .select_i(sftVariable),
      .data_o  (shamt)
  );

  Shifter shifter (
      .leftRight(leftRight),
      .shamt(shamt),
      .sftSrc(ALUsrcData),
      .result(sftResult)
  );


  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i (ALUresult),
      .data1_i (sftResult),
      .data2_i (PR2_o[52:21]),
      .select_i(FURslt),
      .data_o  (RegData)
  );






//////////////////////////////////////////////
  Pipe_Reg #(
      .size(139)
  ) PR3 (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i ({PR2_o[189], PR2_o[188], // WB
      PR2_o[187], PR2_o[186], PR2_o[185],// M
      RegAddrTemp, //5
      pc_branch, //32
      RegData,//32
      PR2_o[116:85],//32
      PR2_o[180:149],//32
      zero//1
      }),
      .data_o (PR3_o)
  );
//////////////////////////////////////////////







  //MEM
  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(PR3_o[96:65]),//RegData
      .data_i(PR3_o[64:33]),//RTdata
      .MemRead_i(PR3_o[135]),
      .MemWrite_i(PR3_o[134]),
      .data_o(MemData)
  );






//////////////////////////////////////////////
  Pipe_Reg #(
      .size(71)
  ) PR4 (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i ({PR3_o[138], PR3_o[137], // WB
      MemData,//32
      PR3_o[96:65],//32 RegData
      PR3_o[133:129]//5 RegAddrTemp
      }),
      .data_o (PR4_o)
  );
//////////////////////////////////////////////






  //WB
  Mux2to1 #(
      .size(32)
  ) Mux_Read_Mem (
      .data0_i (PR4_o[68:37]),
      .data1_i (PR4_o[36:5]),
      .select_i(PR4_o[69]),
      .data_o  (WData)
  );

endmodule



