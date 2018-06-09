//Sloan Liu
//6/8/2018

module write_back_block_dcache(
  input clk,
  input [11-1:0] dcaddr,
  input [64-1:0] dcdata_in1,
  input [64-1:0] dcdata_in2,
  input write,
  output [64-1:0] dcdata_out1,
  output [64-1:0] dcdata_out2
  );

  logic [64-1:0] dcache[2048-1:0] /*verilator public*/; //2048 64 bit numbers -> 11-bit address

  always @(posedge clk) begin
    if(write) begin
      dcache[dcaddr] <= dcdata_in1; //STORE in1
      dcache[dcaddr+1] <= dcdata_in2; //STORE in2
    end
  end

  assign dcdata_out1 = dcache[dcaddr]; //LOAD out1
  assign dcdata_out2 = dcache[dcaddr+1]; //LOAD out2
  
endmodule
