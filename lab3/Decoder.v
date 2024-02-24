module Decoder ( //main control
    instr_op_i,
    RegWrite_o,
    ALUOp_o,
    ALUSrc_o,
    RegDst_o,
    Jump_o,
    Branch_o,
    BranchType_o,
    MemRead_o,
    MemWrite_o,
    MemtoReg_o
);

  //I/O ports
  input [6-1:0] instr_op_i;

  output RegWrite_o;
  output [3-1:0] ALUOp_o;
  output ALUSrc_o;
  output [2-1:0]RegDst_o;
  output Jump_o;
  output Branch_o;
  output BranchType_o;
  output MemRead_o;
  output MemWrite_o;
  output [2-1:0]MemtoReg_o;

  //Internal Signals

  //wire RegWrite_o;
  //wire [3-1:0] ALUOp_o;
  //wire ALUSrc_o;
  //wire RegDst_o;
  //wire Jump_o;
  //wire Branch_o;
  //wire BranchType_o;
  //wire MemRead_o;
  //wire MemWrite_o;
  //wire MemtoReg_o;
  
  reg RegWrite_o;
  reg [3-1:0] ALUOp_o;
  reg ALUSrc_o;
  reg [2-1:0]RegDst_o;
  reg Jump_o;
  reg Branch_o;
  reg BranchType_o;
  reg MemRead_o;
  reg MemWrite_o;
  reg [2-1:0]MemtoReg_o;

  parameter OP_R_TYPE = 6'b000000;
  parameter OP_ADDI = 6'b010011;
  parameter OP_BEQ = 6'b011001;
  parameter OP_LW = 6'b011000;
  parameter OP_SW = 6'b101000;
  parameter OP_BNE = 6'b011010;
  parameter OP_JUMP = 6'b001100;
  parameter OP_JAL = 6'b001111;
  parameter OP_BLT = 6'b011100;
  parameter OP_BNEZ = 6'b011101;
  parameter OP_BGEZ = 6'b011110;

  //Main function
  /*your code here*/
  
always @(instr_op_i) begin
  case (instr_op_i)  
    OP_R_TYPE: begin 
      RegWrite_o <= 1'b1; 
      ALUOp_o <= 3'b000;
      ALUSrc_o <= 1'b0;
      RegDst_o <= 2'b01;//1'b1;
      Jump_o <= 1'b0;
      Branch_o <= 1'b0;
      BranchType_o <= 1'b0;
      MemRead_o <= 1'b0;
      MemWrite_o <= 1'b0;
      MemtoReg_o <= 2'b00;//1'b0;
      end
    OP_ADDI: begin 
      RegWrite_o <= 1'b1;
      ALUOp_o <= 3'b001;
      ALUSrc_o <= 1'b1;
      RegDst_o <= 2'b00;//1'b0;
      Jump_o <= 1'b0;
      Branch_o <= 1'b0;
      BranchType_o <= 1'b0;
      MemRead_o <= 1'b0;
      MemWrite_o <= 1'b0;
      MemtoReg_o <= 2'b00;//1'b0;
      end
    OP_LW: begin
      RegWrite_o <= 1'b1;
      ALUOp_o <= 3'b001;
      ALUSrc_o <= 1'b1;
      RegDst_o <= 2'b00;//1'b0;
      Jump_o <= 1'b0;
      Branch_o <= 1'b0;
      BranchType_o <= 1'b0;
      MemRead_o <= 1'b1;
      MemWrite_o <= 1'b0;
      MemtoReg_o <= 2'b01;//1'b1;
      end
    OP_SW: begin 
      RegWrite_o <= 1'b0;
      ALUOp_o <= 3'b001;
      ALUSrc_o <= 1'b1;
      RegDst_o <= 2'b00;//1'b0;
      Jump_o <= 1'b0;
      Branch_o <= 1'b0;
      BranchType_o <= 1'b0;
      MemRead_o <= 1'b0;
      MemWrite_o <= 1'b1;
      MemtoReg_o <= 2'b00;//1'b0;
      end
    OP_BEQ: begin 
      RegWrite_o <= 1'b0;
      ALUOp_o <= 3'b010;
      ALUSrc_o <= 1'b0;
      RegDst_o <= 2'b00;//1'b0;
      Jump_o <= 1'b0;
      Branch_o <= 1'b1;
      BranchType_o <= 1'b0;
      MemRead_o <= 1'b0;
      MemWrite_o <= 1'b0;
      MemtoReg_o <= 2'b00;//1'b0;
      end   
    OP_BNE: begin 
      RegWrite_o <= 1'b0;
      ALUOp_o <= 3'b010;
      ALUSrc_o <= 1'b0;
      RegDst_o <= 2'b00;//1'b0;
      Jump_o <= 1'b0;
      Branch_o <= 1'b1;
      BranchType_o <= 1'b1;
      MemRead_o <= 1'b0;
      MemWrite_o <= 1'b0;
      MemtoReg_o <= 2'b00;//1'b0;
      end
    OP_JUMP: begin
      RegWrite_o <= 1'b0;
      ALUOp_o <= 3'b000;
      ALUSrc_o <= 1'b0;
      RegDst_o <= 2'b00;
      Jump_o <= 1'b1;
      Branch_o <= 1'b0;
      BranchType_o <= 1'b0;
      MemRead_o <= 1'b0;
      MemWrite_o <= 1'b0;
      MemtoReg_o <= 2'b00;//1'b0;
      end
    OP_JAL: begin
      RegWrite_o <= 1'b1;
      ALUOp_o <= 3'b000;
      ALUSrc_o <= 1'b0;
      RegDst_o <= 2'b10;
      Jump_o <= 1'b1;
      Branch_o <= 1'b0;
      BranchType_o <= 1'b0;
      MemRead_o <= 1'b0;
      MemWrite_o <= 1'b0;
      MemtoReg_o <= 2'b10;
    end
    //OP_BLT: begin
    //end
    //OP_BNEZ: begin
    //end
    //OP_BGEZ: begin
    //end
    default: begin
      RegWrite_o <= 1'b0;
      ALUOp_o <= 3'b000;
      ALUSrc_o <= 1'b0;
      RegDst_o <= 2'b00;
      Jump_o <= 1'b0;
      Branch_o <= 1'b0;
      BranchType_o <= 1'b0;
      MemRead_o <= 1'b0;
      MemWrite_o <= 1'b0;
      MemtoReg_o <= 2'b00;//1'b0;
    end
  endcase
end


endmodule
