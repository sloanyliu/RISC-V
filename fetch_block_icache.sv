//Author Sloan Liu

module fetch_block_icache(
    input clk,
    //input [64-1:0] __tid2175__2770,
    input [64-1:0] internal_pc,
    //input logic [64-1:0] br_pc,
    //output [32-1:0] __tid2177__2772,
    output [32-1:0] inst_out
    //output logic [32-1:0] inst_br
  );

  logic [32-1:0] icache[4096-1:0] /*verilator public*/;
  //logic [32-1:0] inst_out_next;

  //logic [11:0] temp;
  //logic [11:0] temp2;

  //assign temp = internal_pc[11:0]; //this is holding the right thing but just not bit_masked
  //assign temp2 = br_pc[11:0];

  //assign __tid2177__2772 = icache[__tid2175__2770[11:0]];

  //always_comb begin
  //  inst_out_next = icache[internal_pc[11:0]];
  //end

  assign inst_out = icache[internal_pc[13:2]];
  //assign inst_br = icache[br_pc[11:0]];

endmodule
