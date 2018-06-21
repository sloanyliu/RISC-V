//Sloan Liu
//Write Back Stage

`include "rv64.vh"

module pyrm_write_back_block(
	pc_pyri,
	pc_valid_pyri,
	pc_retry_pyro,
	branch_pc_pyri,
	branch_pc_valid_pyri,
	branch_pc_retry_pyro,
	raddr_pyri,
	raddr_valid_pyri,
	raddr_retry_pyro,
	rdata_pyri,
	rdata_valid_pyri,
	rdata_retry_pyro,
	inst_pyri,
	inst_valid_pyri,
	inst_retry_pyro,
	reset_pyri,
	pc_pyro,
	pc_valid_pyro,
	pc_retry_pyri,
	branch_pc_pyro,
	branch_pc_valid_pyro,
	branch_pc_retry_pyri,
	decode_reg_addr_pyro,
	decode_reg_addr_valid_pyro,
	decode_reg_addr_retry_pyri,
	debug_reg_addr_pyro,
	debug_reg_addr_valid_pyro,
	debug_reg_addr_retry_pyri,
	decode_reg_data_pyro,
	decode_reg_data_valid_pyro,
	decode_reg_data_retry_pyri,
	debug_reg_data_pyro,
	debug_reg_data_valid_pyro,
	debug_reg_data_retry_pyri,
	clk
);

  input [64-1:0] pc_pyri; //pc in
  input pc_valid_pyri; //CONTROLLING VALID>>>>>
  output pc_retry_pyro; //ASSERT

  input [64-1:0] branch_pc_pyri; //branch pc in
  input branch_pc_valid_pyri; //CONTROLLING VALID>>>>>>
  output branch_pc_retry_pyro; //ASSERT

  input [64-1:0] raddr_pyri; //raddr in
  input raddr_valid_pyri; //CONTROLLING VALID>>>>>
  output raddr_retry_pyro; //ASSERT

  input [64-1:0] rdata_pyri;
  input rdata_valid_pyri; //CONTROLLING VALID>>>>
  output rdata_retry_pyro; //ASEERT
  /* verilator lint_off UNUSED */
  input [32-1:0] inst_pyri /* lint_on */; //no inst_pyro!
  input inst_valid_pyri; //CONTROLLING VALID>>>>
  output inst_retry_pyro; //ASSERT

  input  reset_pyri;

  output[64-1:0] pc_pyro; //pc out
  output pc_valid_pyro; //ASSERT
  input pc_retry_pyri; //?

  output[64-1:0] branch_pc_pyro;
  output branch_pc_valid_pyro; //ASSERT
  input branch_pc_retry_pyri; //?

  output[64-1:0] decode_reg_addr_pyro;
  output decode_reg_addr_valid_pyro; //ASSERT
  input decode_reg_addr_retry_pyri; //?

  output[64-1:0] debug_reg_addr_pyro;
  output debug_reg_addr_valid_pyro; //ASSERT
  input debug_reg_addr_retry_pyri; //?

  output[64-1:0] decode_reg_data_pyro;
  output decode_reg_data_valid_pyro; //ASSERT
  input decode_reg_data_retry_pyri; //?

  output[64-1:0] debug_reg_data_pyro;
  output debug_reg_data_valid_pyro; //ASSERT
  input debug_reg_data_retry_pyri; //?

  input clk;

  logic [7-1:0] op;
  logic [3-1:0] f3;
  logic [11-1:0] dcaddr; //addr that goes into the dcache
  logic [64-1:0] dcdata_out1; //first line LOAD
  logic [64-1:0] dcdata_out2; //second line LOAD
  logic [64-1:0] dcdata_in1; //first line STORE
  logic [64-1:0] dcdata_in2; //second line STORE
  logic we; //write enable
  logic is_arith;

  logic [2:0] addr_diff; //which byte to start on in the 64bits
  logic [64-1:0] comb_msg; //combined msg form msg1 and msg2
  logic [64-1:0] dcread; //segmented out the part we need

  assign op = inst_pyri[6:0];
  assign f3 = inst_pyri[14:12];
  assign dcaddr = (raddr_pyri[13:3] & {11{op == `OP_STORE}}) | (rdata_pyri[13:3] & {11{op == `OP_LOAD}});

  assign pc_pyro = pc_pyri;

  assign pc_valid_pyro = pc_valid_pyri;
  assign branch_pc_valid_pyro = branch_pc_valid_pyri;

  assign pc_retry_pyro = 0;
  assign branch_pc_retry_pyro = 0;
  assign rdata_retry_pyro = 0;
  assign raddr_retry_pyro = 0;

  assign we = ((op == `OP_STORE) && rdata_valid_pyri && raddr_valid_pyri && pc_valid_pyri && inst_valid_pyri); //only wanna be writing when it's a store;

  assign is_arith  = ((op == `OP_ARITH) || (op == `OP_ARITH_I) || (op == `OP_64ARITH) || (op == `OP_64ARITH_I) || (op == `OP_LUI) || (op == `OP_AUIPC) || (op == `OP_JAL));


  write_back_block_dcache write_back_block_dcache_inst(.clk(clk), .dcaddr(dcaddr), .dcdata_in1(dcdata_in1), .dcdata_in2(dcdata_in2), .write(we), .dcdata_out1(dcdata_out1), .dcdata_out2(dcdata_out2));

  always_comb begin
    if(reset_pyri || pc_retry_pyri || branch_pc_retry_pyri || decode_reg_addr_retry_pyri || decode_reg_data_retry_pyri || debug_reg_addr_retry_pyri || debug_reg_data_retry_pyri) begin
      pc_valid_pyro = 0;
      branch_pc_valid_pyro = 0;
      decode_reg_addr_valid_pyro = 0;
      debug_reg_addr_valid_pyro = 0;
      decode_reg_data_valid_pyro = 0;
	    debug_reg_data_valid_pyro = 0;
    end
  end

  always_comb begin
    inst_retry_pyro = 0;
    pc_valid_pyro = 0;
    branch_pc_valid_pyro = 0;
    decode_reg_addr_valid_pyro = 0;
    debug_reg_addr_valid_pyro = 0;
    decode_reg_data_valid_pyro = 0;
	  debug_reg_data_valid_pyro = 0;

    if(op == `OP_BRANCH) begin //BRANCH
      if(branch_pc_valid_pyri) begin
        branch_pc_pyro = branch_pc_pyri;
        branch_pc_valid_pyro = 1;
      end
    end else if(op == `OP_JALR || is_arith) begin //JALR
      decode_reg_addr_pyro = raddr_pyri;
      decode_reg_data_pyro = rdata_pyri;

      debug_reg_addr_pyro = raddr_pyri;
      debug_reg_data_pyro = rdata_pyri;

      if(inst_valid_pyri && pc_valid_pyri) begin
        decode_reg_addr_valid_pyro = 1;
        decode_reg_data_valid_pyro = 1;
        debug_reg_addr_valid_pyro = 1;
        debug_reg_data_valid_pyro = 1;
      end

      if(branch_pc_valid_pyri) begin
        branch_pc_pyro = branch_pc_pyri;
        branch_pc_valid_pyro = 1;
      end

    end else if(op == `OP_LOAD) begin //LOAD
      if(pc_valid_pyri && inst_valid_pyri) begin
        addr_diff = rdata_pyri[2:0];

        case(addr_diff) //how much of each msg to take
          (3'd0): comb_msg = dcdata_out1;
          (3'd1): comb_msg = {dcdata_out2[8-1:0],dcdata_out1[63:8]};
          (3'd2): comb_msg = {dcdata_out2[16-1:0],dcdata_out1[63:16]};
          (3'd3): comb_msg = {dcdata_out2[24-1:0],dcdata_out1[63:24]};
          (3'd4): comb_msg = {dcdata_out2[32-1:0],dcdata_out1[63:32]}; //here
          (3'd5): comb_msg = {dcdata_out2[40-1:0],dcdata_out1[63:40]};
          (3'd6): comb_msg = {dcdata_out2[48-1:0],dcdata_out1[63:48]};
          (3'd7): comb_msg = {dcdata_out2[56-1:0],dcdata_out1[63:56]};
        endcase

        case(f3) //how much of the taken do we actually need
          (`FUNCT3_LOAD_LB):  dcread = {{56{comb_msg[8-1]}},comb_msg[8-1:0]};
          (`FUNCT3_LOAD_LH):  dcread = {{48{comb_msg[16-1]}},comb_msg[16-1:0]};
          (`FUNCT3_LOAD_LW):  dcread = {{32{comb_msg[32-1]}},comb_msg[32-1:0]};
          (`FUNCT3_LOAD_LBU): dcread = {56'b0,comb_msg[8-1:0]}; //then here
          (`FUNCT3_LOAD_LHU): dcread = {48'b0,comb_msg[16-1:0]};
          (`FUNCT3_LOAD_LWU): dcread = {32'b0,comb_msg[32-1:0]};
          (`FUNCT3_LOAD_LD): dcread = comb_msg;
          default: comb_msg = 0;
        endcase

        decode_reg_data_pyro = dcread;
        decode_reg_data_valid_pyro = 1;

        decode_reg_addr_pyro = raddr_pyri;
        decode_reg_addr_valid_pyro = 1;

        debug_reg_addr_pyro = raddr_pyri;
        debug_reg_addr_valid_pyro = 1;

        debug_reg_data_pyro = dcread;
        debug_reg_data_valid_pyro = 1;
      end

    end else if(op == `OP_STORE) begin //STORE
      debug_reg_addr_pyro = raddr_pyri;
      decode_reg_addr_pyro = raddr_pyri;
      if(pc_valid_pyri && inst_valid_pyri) begin
        addr_diff = raddr_pyri[2:0];

        case(addr_diff)
          (3'd0): begin //skip 0 bits
            dcdata_in2 = dcdata_out2;
            if(f3 == `FUNCT3_STORE_SB) begin
              dcdata_in1 = {dcdata_out1[63:8],rdata_pyri[7:0]}; //56 + 8
            end else if(f3 == `FUNCT3_STORE_SH) begin
              dcdata_in1 = {dcdata_out1[63:16],rdata_pyri[15:0]}; //48 + 16
            end else if(f3 == `FUNCT3_STORE_SW) begin
              dcdata_in1 = {dcdata_out1[63:32],rdata_pyri[31:0]}; //32 + 32
            end else if(f3 == `FUNCT3_STORE_SD) begin
              dcdata_in1 = rdata_pyri;
            end
          end
          //<><><><><><><><><><><><><><><><><><><><><><><><><><><>//
          (3'd1): begin //skip [7:0] 8 bits
            if(f3 == `FUNCT3_STORE_SB) begin
              dcdata_in1 = {dcdata_out1[63:16],rdata_pyri[7:0],dcdata_out1[7:0]}; //48 + 8 + 8
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SH) begin
              dcdata_in1 = {dcdata_out1[63:24],rdata_pyri[15:0],dcdata_out1[7:0]}; //40 + 16 + 8
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SW) begin
              dcdata_in1 = {dcdata_out1[63:40],rdata_pyri[31:0],dcdata_out1[7:0]}; //24 + 32 + 8
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SD) begin
              dcdata_in1 = {rdata_pyri[55:0],dcdata_out1[7:0]}; //56 + 8
              dcdata_in2 = {dcdata_out2[63:8],rdata_pyri[63:56]}; //56 + 8
            end
          end
          //<><><><><><><><><><><><><><><><><><><><><><><><><><><>//
          (3'd2): begin //skip [15:0] 16 bits
            if(f3 == `FUNCT3_STORE_SB) begin
              dcdata_in1 = {dcdata_out1[63:24],rdata_pyri[7:0],dcdata_out1[15:0]}; //40 + 8 + 16
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SH) begin
              dcdata_in1 = {dcdata_out1[63:32],rdata_pyri[15:0],dcdata_out1[15:0]}; //32 + 16 + 16
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SW) begin
              dcdata_in1 = {dcdata_out1[63:48],rdata_pyri[31:0],dcdata_out1[15:0]}; //16 + 32 + 16
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SD) begin
              dcdata_in1 = {rdata_pyri[47:0],dcdata_out1[15:0]}; //48 + 16
              dcdata_in2 = {dcdata_out2[63:16],rdata_pyri[63:48]}; //48 + 16
            end
          end
          //<><><><><><><><><><><><><><><><><><><><><><><><><><><>//
          (3'd3): begin //skip [23:0] 24 bits
            if(f3 == `FUNCT3_STORE_SB) begin
              dcdata_in1 = {dcdata_out1[63:32],rdata_pyri[7:0],dcdata_out1[23:0]}; //32 + 8 + 24
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SH) begin
              dcdata_in1 = {dcdata_out1[63:40],rdata_pyri[15:0],dcdata_out1[23:0]}; //24 + 16 + 24
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SW) begin
              dcdata_in1 = {dcdata_out1[63:56],rdata_pyri[31:0],dcdata_out1[23:0]}; //8 + 32 + 24
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SD) begin
              dcdata_in1 = {rdata_pyri[39:0],dcdata_out1[23:0]}; //40 + 24
              dcdata_in2 = {dcdata_out2[63:24],rdata_pyri[63:40]}; //40 + 24
            end
          end
          //<><><><><><><><><><><><><><><><><><><><><><><><><><><>//
          (3'd4): begin //skip [31:0] 32 bits
            if(f3 == `FUNCT3_STORE_SB) begin
              dcdata_in1 = {dcdata_out1[63:40],rdata_pyri[7:0],dcdata_out1[31:0]}; //24 + 8 + 32
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SH) begin
              dcdata_in1 = {dcdata_out1[63:48],rdata_pyri[15:0],dcdata_out1[31:0]}; //16 + 16 + 32
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SW) begin
              dcdata_in1 = {rdata_pyri[31:0],dcdata_out1[31:0]}; //32 + 32
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SD) begin
              dcdata_in1 = {rdata_pyri[31:0],dcdata_out1[31:0]}; //32 + 32
              dcdata_in2 = {dcdata_out2[63:32],rdata_pyri[63:32]}; //32 + 32
            end
          end
          //<><><><><><><><><><><><><><><><><><><><><><><><><><><>//
          (3'd5): begin //skip [39:0] 40 bits
            if(f3 == `FUNCT3_STORE_SB) begin
              dcdata_in1 = {dcdata_out1[63:48],rdata_pyri[7:0],dcdata_out1[39:0]}; //16 + 8 + 40
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SH) begin
              dcdata_in1 = {dcdata_out1[63:56],rdata_pyri[15:0],dcdata_out1[39:0]}; //8 + 16 + 40
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SW) begin
              dcdata_in1 = {rdata_pyri[23:0],dcdata_out1[39:0]}; //24 + 40
              dcdata_in2 = {dcdata_out2[63:8],rdata_pyri[31:24]}; //56 + 8
            end else if(f3 == `FUNCT3_STORE_SD) begin
              dcdata_in1 = {rdata_pyri[23:0],dcdata_out1[39:0]}; //24 + 40
              dcdata_in2 = {dcdata_out2[63:40],rdata_pyri[63:24]}; //24 + 40
            end
          end
          //<><><><><><><><><><><><><><><><><><><><><><><><><><><>//
          (3'd6): begin //skip [47:0] 48 bits
            if(f3 == `FUNCT3_STORE_SB) begin
              dcdata_in1 = {dcdata_out1[63:56],rdata_pyri[7:0],dcdata_out1[47:0]}; //8 + 8 + 48
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SH) begin
              dcdata_in1 = {rdata_pyri[15:0],dcdata_out1[47:0]}; //16 + 48
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SW) begin
              dcdata_in1 = {rdata_pyri[15:0],dcdata_out1[47:0]}; //16 + 48
              dcdata_in2 = {dcdata_out2[63:16],rdata_pyri[31:16]}; //48 + 16
            end else if(f3 == `FUNCT3_STORE_SD) begin
              dcdata_in1 = {rdata_pyri[15:0],dcdata_out1[47:0]}; //16 + 48
              dcdata_in2 = {dcdata_out2[63:48],rdata_pyri[63:16]}; //16 + 48
            end
          end
          //<><><><><><><><><><><><><><><><><><><><><><><><><><><>//
          (3'd7): begin //skip [55:0] 56 bits
            if(f3 == `FUNCT3_STORE_SB) begin
              dcdata_in1 = {rdata_pyri[7:0],dcdata_out1[55:0]}; //8 + 56
              dcdata_in2 = dcdata_out2;
            end else if(f3 == `FUNCT3_STORE_SH) begin
              dcdata_in1 = {rdata_pyri[7:0],dcdata_out1[55:0]}; //8 + 56
              dcdata_in2 = {dcdata_out2[63:8],rdata_pyri[15:8]}; //56 + 8
            end else if(f3 == `FUNCT3_STORE_SW) begin
              dcdata_in1 = {rdata_pyri[7:0],dcdata_out1[55:0]}; //8 + 56
              dcdata_in2 = {dcdata_out2[63:24],rdata_pyri[31:8]}; //40 + 24
            end else if(f3 == `FUNCT3_STORE_SD) begin
              dcdata_in1 = {rdata_pyri[7:0],dcdata_out1[55:0]}; //8 + 56
              dcdata_in2 = {dcdata_out2[63:56],rdata_pyri[63:8]}; //8 + 56
            end
          end
        endcase
      end
    end
  end

endmodule


