`include "ALU_1bit.v"
module ALU (
    aluSrc1,    //32 bits
    aluSrc2,    //32 bits
    invertA,    //1 bit
    invertB,    //1 bit
    operation,  //2 bits
    result,     //32 bits
    zero,       //1 bit
    overflow    //1 bit
);

  //I/O ports
  input [32-1:0] aluSrc1;
  input [32-1:0] aluSrc2;
  input invertA;
  input invertB;
  input [2-1:0] operation;

  output reg [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  wire [32-1:0] res;
  //wire zero;
  //wire overflow;
  
  wire cin;
  wire [32-1:0] cout;
  wire set;

  //Main function
  /*your code here*/

assign cin = (invertA + invertB);

ALU_1bit alu_1bit_0(.a(aluSrc1[0]), .b(aluSrc2[0]), .invertA(invertA), .invertB(invertB), .operation(operation), .carryIn(cin), .less(set), .result(res[0]), .carryOut(cout[0]));

genvar i;
generate
  for (i = 1; i < 32; i = i + 1) begin
    ALU_1bit alu_1bit(
      .a(aluSrc1[i]), .b(aluSrc2[i]), .invertA(invertA), .invertB(invertB), .operation(operation), .carryIn(cout[i-1]), .less(1'b0), .result(res[i]), .carryOut(cout[i]));
  end
endgenerate

assign zero = (result == 0) ^ (operation == 10);
assign set = (aluSrc1[31] ^ (~aluSrc2[31]) ^ cout[30]) & (operation == 11);
//assign overflow = (cout[30] ^ cout[31]) & (operation == 10);
//assign overflow = ((cout[30]|0) ^ (cout[31]|0)) & (operation == 10);
//assign overflow = ((aluSrc1[31] & aluSrc2[31]) & (~cout[31])) | ((~(aluSrc1[31]) & (~aluSrc2[31])) & cout[31]);
assign overflow = ((aluSrc1[31] ^ invertA) & (aluSrc2[31] ^ invertB) & (~res[31])) | ((~(aluSrc1[31] ^ invertA)) & (~(aluSrc2[31] ^ invertB)) & res[31]);

always @* begin
    result <= res;
end



endmodule
