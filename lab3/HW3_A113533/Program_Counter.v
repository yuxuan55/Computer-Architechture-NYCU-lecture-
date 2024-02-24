module Program_Counter (
    clk_i,
    rst_n,
    pc_in_i,
    pc_out_o
);

  //I/O ports
  input clk_i;
  input rst_n;
  input [32-1:0] pc_in_i;
  output [32-1:0] pc_out_o;

  //Internal Signals
  reg [32-1:0] pc_out_o; //store the current value of PC

  //Main function
  always @(posedge clk_i) begin //execute on the rising edge of the clock clk_i
    if (~rst_n) pc_out_o <= 0; // if the reset signal is low, the PC is reset to zero
    //else pc_out_o <= pc_in_i;
    else pc_out_o <= pc_in_i;
  end

endmodule
