module ALU (
    aluSrc1,
    aluSrc2,
    ALU_operation_i,
    result,
    zero,
    overflow
);

  //I/O ports
  input [32-1:0] aluSrc1;
  input [32-1:0] aluSrc2;
  input [4-1:0] ALU_operation_i;

  output [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  //wire [32-1:0] result;
  reg [32-1:0] result;
  wire zero;
  //reg zero;
  //wire overflow;
  reg overflow;

  //Main function
  /*your code here*/

  always @(aluSrc1, aluSrc2, ALU_operation_i) begin
   case(ALU_operation_i)
	  4'b0010: begin result <= aluSrc1 + aluSrc2; overflow <= (aluSrc1[31] == aluSrc1[31] == ~result[31]); end       //add
		4'b0110: begin result <= aluSrc1 - aluSrc2; overflow <= (aluSrc1[31] == ~aluSrc1[31] == ~result[31]); end      //sub
		4'b0000: begin result <= aluSrc1 & aluSrc2; overflow <=1'b0; end      //and
		4'b0001: begin result <= aluSrc1 | aluSrc2; overflow <=1'b0; end      //or
		4'b1100: begin result <= ~(aluSrc1|aluSrc2);overflow <=1'b0; end       //nor
		4'b0111: begin result <= ($signed(aluSrc1) < $signed(aluSrc2)) ? (32'd1) : (32'd0); overflow <=1'b0; end //slt
    //4'b1000: result <= aluSrc1 < aluSrc2 ? 1:0; //sllv
    //4'b1111: result <= aluSrc1 < aluSrc2 ? 1:0; //srl
		//9: result_o <= ($signed(src2_i) >>> shamt);//SRA
		//11:result_o <= ($signed(src2_i) >>> $signed(src1_i));//SRA V 
		//12: result_o <= ~(src1_i | src2_i);
		//13: result_o <= {16'd0,src1_i[15:0]} < {16'd0,src2_i[15:0]} ?1:0;
		//14: result_o <= (src2_i << 16);//lui
		default: begin result <= 32'd0; overflow <=1'b0; end
	endcase
  end
  assign zero = ~|result;
  //assign overflow = (~aluSrc1[31] == ~aluSrc1[31] == result[31]);

endmodule
