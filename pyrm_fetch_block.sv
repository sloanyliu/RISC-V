//Author: Sloan Liu
//RISC V Fetch Block
//6/1/2018

`include "rv64.vh"

module pyrm_fetch_block(
	reset_pyri,
	branch_pc_pyri,
	branch_pc_valid_pyri,
	branch_pc_retry_pyro,
	pc_pyro,
	pc_valid_pyro,
	pc_retry_pyri,
	inst_pyro,
	inst_valid_pyro,
	inst_retry_pyri,
	clk
);

  input logic   reset_pyri;

  input logic  [64-1:0] branch_pc_pyri;
  input logic  branch_pc_valid_pyri;
  output logic  branch_pc_retry_pyro;

  output logic [64-1:0] pc_pyro;
  output logic  pc_valid_pyro;
  input logic  pc_retry_pyri;

  output logic [32-1:0] inst_pyro;
  output logic  inst_valid_pyro;
  input logic  inst_retry_pyri;

  input logic  clk;

  logic [63:0] internal_pc;
  logic [63:0] internal_pc_next;

  logic [1:0] state;
  logic [1:0] state_next;

  logic [31:0] inst_out;

  logic [6:0] op;

  logic all_retry;

  assign all_retry = inst_retry_pyri | pc_retry_pyri;
  assign pc_pyro = (internal_pc & {64{~branch_pc_valid_pyri}}) | (branch_pc_pyri & {64{branch_pc_valid_pyri}});
  assign branch_pc_retry_pyro = 0;

  fetch_block_icache fetch_block_icache_inst(.clk(clk), .internal_pc(pc_pyro[13:2]), .inst_out(inst_out));

  always_comb begin
    if(state == 2'b01) begin //RUNNING/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
      pc_valid_pyro = !pc_retry_pyri; //pc_valid logic
      inst_valid_pyro = !inst_retry_pyri; //pc_valid logic
      inst_pyro = inst_out; //inst is saved
      op = inst_out[6:0];

      if(op == `OP_BRANCH || op == `OP_JALR) begin //If op is BRANCH or JALR
        internal_pc_next = internal_pc; //pc stagnant-> wait for state switch

        if(all_retry) begin //If inst_retry is high -> stops state machine
          state_next = 2'b01; //state stay at RUNNING
        end else begin   //If no retry, time for BRANCH -> cause inside op BRANCH/JALR
          state_next = 2'b10; //*******STATE TRANSITION*********
        end

      end else if(op == `OP_JAL) begin //If op is JAL

        if(all_retry) begin //If inst_retry is high -> pc goes nowhere
          internal_pc_next = internal_pc; //internal_pc stagnant
        end else begin //otherwise, gotta JUMP -> add JAL immediate on
          internal_pc_next = $signed(internal_pc) + {{43{inst_out[31]}}, {inst_out[31],inst_out[19:12],inst_out[20],inst_out[30:21],1'b0}};
        end
        state_next = 2'b01; //Go to RUNNING, no need for BRANCH

      end else begin //If op is not JAL/JALR/BRANCH

        if(all_retry) begin //If inst_retry is high ->pc goes nowhere
          internal_pc_next = internal_pc; //internal_pc is stagnant
        end else begin                //otherwsie, our inst is not JAL/JALR/BRANCH
          internal_pc_next = internal_pc + 4; //If so, we move on
        end
        state_next = 2'b01; //would be in RUNNING after this regardless

      end

    end else if(state == 2'b10) begin //BRANCH--<>--<>--<>--<>--<>--<>--<>--<>--<>--<>--<>--<>--<>--<>--<>
      pc_valid_pyro = branch_pc_valid_pyri; //only branch_pc_valid matters here
      inst_valid_pyro = branch_pc_valid_pyri; //so valids = branch_pc_valid

      if(branch_pc_valid_pyri) begin //Branch_pc ready
        inst_pyro = inst_out; //inst_out is pushed
        state_next = 2'b01; //go to RUNNING...unless......********STATE TRANSITION********
      end else begin //Branch_pc not ready and in BRANCH
        internal_pc_next = internal_pc; //internal_pc goes nowhere
        state_next = 2'b10; //stay at BRANCH
      end

      op = inst_out[6:0];

      if(op == `OP_BRANCH || op == `OP_JALR) begin //If = JALR/BRANCH

        if(branch_pc_valid_pyri) begin //Branch_pc is ready with op = JALR/BRANCH
          internal_pc_next = branch_pc_pyri; //Branch_pc is saved to internal_pc (pretend)
          state_next = 2'b10; //Not done branching, stay at BRANCH --> will override top one!!!!!!
        end

      end else if(op == `OP_JAL) begin //If op = JAL, and we're in BRANCH, JAL with branch_pc, casue branch_pc is our "internal_pc" but not yet
        internal_pc_next = $signed(branch_pc_pyri) + {{43{inst_out[31]}}, {inst_out[31],inst_out[19:12],inst_out[20],inst_out[30:21],1'b0}};
      end else begin
        internal_pc_next = branch_pc_pyri + 4; //otherwise "interal_pc" (branch_pc) move on
      end

    end else begin //if not in any STATE
      internal_pc_next = internal_pc; //internal_pc stagnant
    end
  end

  always @(posedge clk) begin
    if(reset_pyri) begin
      state <= 2'b01;
      internal_pc <= 64'h80000000;
    end else begin
      state <= state_next;
      internal_pc <= internal_pc_next;
    end
  end


endmodule


