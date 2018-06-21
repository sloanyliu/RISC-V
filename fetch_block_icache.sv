
//Author Sloan Liu

module fetch_block_icache(
  /* verilator lint_off UNUSED */
  input clk/* lint_on */,
  input [11:0] internal_pc,
  output [32-1:0] inst_out
);

  logic [32-1:0] icache[4096-1:0] /*verilator public*/;

  assign inst_out = icache[internal_pc];

endmodule