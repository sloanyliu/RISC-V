//Author: Sloan Liu
//Date: 6/4/2018
//RISC V Decode Stage

`include "rv64.vh"

module pyrm_decode_block(
	reg_addr_pyri,
	reg_addr_valid_pyri,
	reg_addr_retry_pyro,
	reg_data_pyri,
	reg_data_valid_pyri,
	reg_data_retry_pyro,
	inst_pyri,
	inst_valid_pyri,
	inst_retry_pyro,
	pc_pyri,
	pc_valid_pyri,
	pc_retry_pyro,
	reset_pyri,
	inst_pyro,
	inst_valid_pyro,
	inst_retry_pyri,
	pc_pyro,
	pc_valid_pyro,
	pc_retry_pyri,
	src1_pyro,
	src1_valid_pyro,
	src1_retry_pyri,
	src2_pyro,
	src2_valid_pyro,
	src2_retry_pyri,
	clk
);

  /* verilator lint_off UNUSED */
  input  logic  [64-1:0] reg_addr_pyri/* lint_on */; //go into decode_block
  input  logic  reg_addr_valid_pyri;
  output logic  reg_addr_retry_pyro;

  input  logic  [64-1:0] reg_data_pyri; //go into decode_block
  input  logic  reg_data_valid_pyri;
  output logic  reg_data_retry_pyro;

  input  logic  [32-1:0] inst_pyri;
  input  logic  inst_valid_pyri;
  output logic  inst_retry_pyro; //keep $inst -> set high

  input  logic  [64-1:0] pc_pyri;
  input  logic  pc_valid_pyri;
  output logic  pc_retry_pyro; //keep $inst -> set high

  input  logic  reset_pyri;

  output logic  [32-1:0] inst_pyro;
  output logic  inst_valid_pyro; //same as pc_valid_pyro ->where we see $inst = $inst, set high
  input  logic  inst_retry_pyri;

  output logic  [64-1:0] pc_pyro;
  output logic  pc_valid_pyro; //same as inst_valid_pyro -> where we see $pc = $pc, set high
  input  logic  pc_retry_pyri;

  output logic  [64-1:0] src1_pyro;
  output logic  src1_valid_pyro;
  input  logic  src1_retry_pyri;

  output logic  [64-1:0] src2_pyro;
  output logic  src2_valid_pyro;
  input  logic  src2_retry_pyri;

  input  logic   clk;

  logic [31:0] raw; //Read After Write -> 32 bits repping 32 registers (0 -> free, 1 -> in use)
  logic [31:0] raw_next;

  logic [4:0] r1;
  logic [4:0] r2;

  logic [63:0] d1;
  logic [63:0] d2;

  logic wee;
  logic [6:0] op;
  logic [4:0] dest_reg;
  logic [11:0] arith_imm;
  logic [19:0] laui_imm;

  assign wee = (reg_addr_valid_pyri) && (reg_data_valid_pyri) && (reg_addr_pyri[4:0] != 0); //writable check
  assign op = inst_pyri[6:0];
  assign r1 = inst_pyri[19:15]; //ra1
  assign r2 = inst_pyri[24:20]; //ra2
  assign dest_reg = inst_pyri[11:7]; //rd
  assign arith_imm = inst_pyri[31:20]; //arith immediate
  assign laui_imm = inst_pyri[31:12]; //AUIPC and LUI immediate
  assign inst_pyro = inst_pyri;
  assign pc_pyro = pc_pyri;

  decode_block_data decode_block_data_inst(.clk(clk), .write(wee), .reg_addr(reg_addr_pyri[4:0]), .reg_data(reg_data_pyri), .reg1(r1), .reg2(r2), .data1(d1), .data2(d2));

  always_comb begin
    if(inst_retry_pyri || pc_retry_pyri || src1_retry_pyri || src2_retry_pyri) begin
      inst_valid_pyro = 0;
      pc_valid_pyro = 0;
      src1_valid_pyro = 0;
      src2_valid_pyro = 0;
    end
  end

  always_comb begin
    raw_next[0] = 0; //reg 0 should always be 0
    raw_next = raw;
    reg_data_retry_pyro = 0; //all the valids are 0 when logic starts
    reg_addr_retry_pyro = 0;
    inst_retry_pyro = 0;
    pc_retry_pyro = 0;
    inst_valid_pyro = 0;
    pc_valid_pyro = 0;
    src1_valid_pyro = 0;
    src2_valid_pyro = 0;
    src1_pyro = d1;
    src2_pyro = 0;

    if(reg_addr_valid_pyri && reg_data_valid_pyri) begin
      if(reg_addr_pyri[4:0] != 0) begin //raddr is not reg0
        raw_next[reg_addr_pyri[4:0]] = 0;
      end
    end

    if(inst_valid_pyri || pc_valid_pyri) begin //Start
      if(op == `OP_ARITH || op == `OP_64ARITH || op == `OP_BRANCH || op == `OP_STORE) begin //ARITH, ARITH_W, BRANCH, STORE -> needs r1 and r2

        if(raw_next[r1] == 1 || raw_next[r2] == 1) begin //checking for "in use" registers
          inst_retry_pyro = 1;
          pc_retry_pyro = 1;

        end else if(op == `OP_BRANCH && raw_next[dest_reg] == 1) begin //BRANCH
          inst_retry_pyro = 1;
          pc_retry_pyro = 1;
        end else begin //everything is ready
          inst_valid_pyro = 1;
          pc_valid_pyro = 1;

          if(reg_addr_valid_pyri && r1 != 0 && reg_addr_pyri[4:0] == r1) begin //filling src1
            src1_pyro = reg_data_pyri;
            src1_valid_pyro = 1;
          end else begin
            src1_pyro = d1;
            src1_valid_pyro = 1;
          end

          if(reg_addr_valid_pyri && r2 != 0 && reg_addr_pyri[4:0] == r2) begin //filling src2
            src2_pyro = reg_data_pyri;
            src2_valid_pyro = 1;
          end else begin
            src2_pyro = d2;
            src2_valid_pyro = 1;
          end

          if(op == `OP_ARITH || op == `OP_64ARITH) begin //ARITH, ARITH_W
            raw_next[dest_reg] = 1;
          end
        end
      end else if(op == `OP_ARITH_I || op == `OP_64ARITH_I || op == `OP_LOAD) begin //ARITH_I, ARITH_W_I, LOAD
        if(raw_next[r1] == 1 || raw_next[dest_reg] == 1) begin //only need to check for r1's "in use"
          inst_retry_pyro = 1;
          pc_retry_pyro = 1;
        end else begin
          inst_valid_pyro = 1;
          pc_valid_pyro = 1;

          if(reg_addr_valid_pyri && r1 != 0 && reg_addr_pyri[4:0] == r1) begin //filling src1
            src1_pyro = reg_data_pyri;
            src1_valid_pyro = 1;
          end else begin
            src1_pyro = d1;
            src1_valid_pyro = 1;
          end

          src2_pyro = {{52{arith_imm[11]}}, arith_imm}; //src2 is filled regardless for this op
          src2_valid_pyro = 1;
          raw_next[dest_reg] = 1;
        end
      end else if(op == `OP_JALR) begin //JALR
        if(raw_next[r1] == 1 || raw_next[dest_reg] == 1) begin //only need to check for r1's "in use"
          inst_retry_pyro = 1;
          pc_retry_pyro = 1;
        end else begin
          inst_valid_pyro = 1;
          pc_valid_pyro = 1;

          if(reg_addr_valid_pyri && r1 != 0 && reg_addr_pyri[4:0] == r1) begin //filling in src1, dont need src2
            src1_pyro = reg_data_pyri;
            src1_valid_pyro = 1;
          end else begin
            src1_pyro = d1;
            src1_valid_pyro = 1;
          end
        end
      end else if(op == `OP_JAL) begin //JAL
        if(raw_next[dest_reg] == 1) begin
          inst_retry_pyro = 1;
          pc_retry_pyro = 1;
        end else begin
          inst_valid_pyro = 1;
          pc_valid_pyro = 1;
        end
      end else if(op == `OP_LUI || op == `OP_AUIPC) begin //LUI, AUIPC
        if(raw_next[dest_reg] == 1) begin 
          inst_retry_pyro = 1; //it's wrong here
          pc_retry_pyro = 1;
        end else begin
          inst_valid_pyro = 1;
          pc_valid_pyro = 1;
          src1_pyro = {{44{laui_imm[19]}}, laui_imm};
          src1_valid_pyro = 1;
          raw_next[dest_reg] = 1;
        end
      end else if(op == 7'b1110011) begin //SCALL -> dont worry about this
        inst_valid_pyro = 1;
        pc_valid_pyro = 1;
      end
    end else begin
      inst_valid_pyro = 0;
      pc_valid_pyro = 0;
    end
  end

  always @(posedge clk) begin
    if(reset_pyri) begin
      raw <= 0;
    end else begin
      raw <= raw_next; // asn raw, raw_pyro
    end
  end

endmodule

