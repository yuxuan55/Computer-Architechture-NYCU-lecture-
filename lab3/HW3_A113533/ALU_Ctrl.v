module ALU_Ctrl (  //R-type, I-type
    funct_i,
    ALUOp_i,
    ALU_operation_o,
    FURslt_o,
    leftRight_o
);

  //I/O ports
  input [6-1:0] funct_i;
  input [3-1:0] ALUOp_i;

  output [4-1:0] ALU_operation_o;
  output [2-1:0] FURslt_o;
  output leftRight_o;

  //Internal Signals
  //wire [4-1:0] ALU_operation_o;
  //wire [2-1:0] FURslt_o;
  //wire leftRight_o;
  reg [4-1:0] ALU_operation_o;
  reg [2-1:0] FURslt_o;
  reg leftRight_o;

  //Main function
  /*your code here*/
  
always@(*) begin
    case (ALUOp_i)
        3'b000:begin
            case (funct_i)
                6'b100011: ALU_operation_o <= 4'b0010;  // add 
                6'b010011: ALU_operation_o <= 4'b0110;   // sub
                6'b011111: ALU_operation_o <= 4'b0000;  // and 
                6'b101111: ALU_operation_o <= 4'b0001;   // or   
                6'b010000: ALU_operation_o <= 4'b1100;  // nor 
                6'b010100: ALU_operation_o <= 4'b0111; // slt
                6'b010010: begin ALU_operation_o <= 4'b0000; FURslt_o <= 2'b01; leftRight_o <= 1'b0; end   // sll
                6'b100010: begin ALU_operation_o <= 4'b0000; FURslt_o <= 2'b01; leftRight_o <= 1'b1; end  // srl 
                6'b010100: begin ALU_operation_o <= 4'b0000; FURslt_o <= 2'b10; leftRight_o <= 1'b0; end   //sllv
                6'b010100: begin ALU_operation_o <= 4'b0000; FURslt_o <= 2'b10; leftRight_o <= 1'b1; end  //srlv  
            endcase
        end
        3'b001: begin
            ALU_operation_o <= 4'b0010;               // addi(add),lw(add),sw(add)
            FURslt_o <= 2'b00; 
            leftRight_o <= 1'b0;
        end
        3'b010: begin
            ALU_operation_o <= 4'b0110;               // beq,bne(sub)
            FURslt_o <= 2'b00; 
            leftRight_o <= 1'b0;
        end
        default: begin 
            ALU_operation_o <= 4'bxxxx; 
            FURslt_o <= 2'b00; 
            leftRight_o <= 1'b0;
            end
    endcase   
end

endmodule
