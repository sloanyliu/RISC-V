//Author: Sloan Liu
//Date: 6/4/2018
//RISC V decode iCache

module decode_block_data(
  input clk,
  input write,
  input [64-1:0] reg_addr,
  input [64-1:0] reg_data,
  input [4:0] reg1,
  input [4:0] reg2,
  output [64-1:0] data1,
  output [64-1:0] data2);

  //32 registers, each 32 bits
  logic [64-1:0] data[32-1:0] /*verilator public*/;

  //get ra1 ra2 and pass them out

  //this decides whether or not to write to data
  //if write, then regData goes into addr specified by regAddr, otherwise, whtever was their before, goes back into there.
  always_comb begin
    if(write) begin
      data[reg_addr[4:0]] = reg_data;
    end
  end



  //assign data1 = reg1 != 0 ? data[reg1] : 64'd0;
  assign data1 = data[reg1];
  assign data2 = data[reg2];

endmodule
