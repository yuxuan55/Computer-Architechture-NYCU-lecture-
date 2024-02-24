`include "Full_adder.v"
module ALU_1bit (
    a,
    b,
    invertA,
    invertB,
    operation,
    carryIn,
    less,
    result,
    carryOut
);

  //I/O ports
  input a;
  input b;
  input invertA;
  input invertB;
  input [2-1:0] operation;
  input carryIn;
  input less;

  output reg result;
  output reg carryOut;

  //Internal Signals
  //wire result;
  //wire carryOut;
  
  wire src1;
  wire src2;
  
wire sum;
wire cout;

//wire ls;

  //Main function
  /*your code here*/

assign src1 = a ^ invertA; //if(A_invert) src1 = ~a;    else src1 = a;
assign src2 = b ^ invertB; //if(B_invert) src2 = ~b;    else src2 = b;
//assign ls = less;

Full_adder fa0 (.carryIn(carryIn), .input1(src1), .input2(src2), .sum(sum), .carryOut(cout));

always @* begin
  case(operation)
    2'b00: // or
      begin
        result = src1 | src2;
        carryOut = 1'b0;
      end

    2'b01: // and
      begin
        result = src1 & src2;
        carryOut = 1'b0;
      end

    2'b10: // add
      begin
        if(sum) result = sum; else result = 0;
        //result = sum;
        carryOut = cout;
      end

    2'b11: // less
      begin
        //if(less) result = less; else result = 0;
        result = less;
        carryOut = cout;
      end
  endcase
end

endmodule
