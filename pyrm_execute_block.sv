//Author: Sloan Liu
//5/19/18 
//RISCV Execute Stage


`include "rv64.vh"

module pyrm_execute_block(
	pc_pyri,
	pc_valid_pyri,
	pc_retry_pyro,

	in1_pyri,
	in1_valid_pyri,
	in1_retry_pyro,

	in2_pyri,
	in2_valid_pyri,
	in2_retry_pyro,

	inst_pyri,
	inst_valid_pyri,
	inst_retry_pyro,
	reset_pyri,

	pc_pyro,
	pc_valid_pyro,
	pc_retry_pyri,

	inst_pyro,
	inst_valid_pyro,
	inst_retry_pyri,

	rdata_pyro,
	rdata_valid_pyro,
	rdata_retry_pyri,

	raddr_pyro,
	raddr_valid_pyro,
	raddr_retry_pyri,

  branch_pc_pyro, // Same as lab3 branch_pc_o_next (not branch_pc_o)
	branch_pc_valid_pyro,
	branch_pc_retry_pyri,

	clk
);

input logic  [64-1:0] pc_pyri; //pc_i
input logic  pc_valid_pyri; //pc_i_valid
output logic  pc_retry_pyro;

input logic  [64-1:0] in1_pyri; //in1_1
input logic  in1_valid_pyri; //in1_i_valid
output logic  in1_retry_pyro;

input logic  [64-1:0] in2_pyri; //in2_i
input logic  in2_valid_pyri; //in2_i_valid
output logic  in2_retry_pyro;

input logic  [32-1:0] inst_pyri; //inst_i
input logic  inst_valid_pyri; //inst_i_valid
output logic  inst_retry_pyro;
input logic   reset_pyri;

output logic [64-1:0] pc_pyro; //pc_o_next
output logic  pc_valid_pyro; //pc_o_valid_next
input logic  pc_retry_pyri;

output logic [32-1:0] inst_pyro; //inst_o_next
output logic  inst_valid_pyro; //inst_o_valid_next
input logic  inst_retry_pyri;

output logic [64-1:0] rdata_pyro; //rdata_o_next
output logic  rdata_valid_pyro; //rdata_o_retry_next
input logic  rdata_retry_pyri;

output logic [64-1:0] raddr_pyro; //raddr_o_next
output logic  raddr_valid_pyro; //raddr_o_valid_next
input logic  raddr_retry_pyri;

output logic [64-1:0] branch_pc_pyro; //branch_pc_o_next
output logic  branch_pc_valid_pyro; //branch_pc_o_valid_next
input logic  branch_pc_retry_pyri;

input logic  clk;
///////////////////////////////////////////////////////////////////
 logic [64-1:0] pc_i;
 logic          pc_i_valid;
 logic [64-1:0] in1_i;
 logic          in1_i_valid;
 logic [64-1:0] in2_i;
 logic          in2_i_valid;
 logic [32-1:0] inst_i;
 logic          inst_i_valid;

 logic [64-1:0] branch_pc_o_next;
 logic          branch_pc_o_valid_next;
 logic [64-1:0] raddr_o_next;
 logic          raddr_o_valid_next;
 logic [64-1:0] rdata_o_next;
 logic          rdata_o_valid_next;
 logic [32-1:0] inst_o_next;
 logic          inst_o_valid_next;
 logic [64-1:0] pc_o_next;
 logic          pc_o_valid_next;
 logic [32-1:0] help;

 //////////////////////////////////////////////////////////////////
 assign pc_i = pc_pyri;
 assign pc_i_valid = pc_valid_pyri;

 assign in1_i = in1_pyri;
 assign in1_i_valid = in1_valid_pyri;

 assign in2_i = in2_pyri;
 assign in2_i_valid = in2_valid_pyri;

 assign inst_i = inst_pyri;
 assign inst_i_valid = inst_valid_pyri;

 assign pc_pyro = pc_o_next;
 assign pc_valid_pyro  = pc_o_valid_next;

 assign inst_pyro = inst_o_next;
 assign inst_valid_pyro = inst_o_valid_next;

 assign rdata_pyro = rdata_o_next;
 assign rdata_valid_pyro = rdata_o_valid_next;

 assign raddr_pyro = raddr_o_next;
 assign raddr_valid_pyro = raddr_o_valid_next;

 assign branch_pc_pyro = branch_pc_o_next;
 assign branch_pc_valid_pyro = branch_pc_o_valid_next;
 //////////////////////////////////////////////////////////////////

 logic all_valid; //all the valids anded together
 //assign all_valid = in1_i_valid & in2_i_valid & pc_i_valid & inst_i_valid;
 assign all_valid = pc_i_valid & inst_i_valid;


 logic all_retry;
 assign all_retry = pc_retry_pyri | inst_retry_pyri | rdata_retry_pyri | raddr_retry_pyri | branch_pc_retry_pyri;

 logic [7-1:0] op; //operations
 logic [3-1:0] f3; //funct3
 logic [7-1:0] f7; //funct7
 logic [11:0] arith_imm; //immediate value for 32-bit ADDI, SLTI, SLTIU, 
                        //ANDI, ORI, XORI, 
                        //and offset for Loads
 logic [4:0] dest_logic; //destination register for operations
 logic [11:0] store_offset; //offset for the store address
 logic [11:0] load_offset; //offset for the load address
 logic [19:0] upper_imm; //used for LUI
 logic [12:0] br_offset; //branch offset
 logic [5:0] shamt; //used for 64 bit SLLI, SRLI, SRAI
 logic [4:0] shamt2; //used for SLLW, SRLW, SRAW, SLL, SRL, SRA (32 bit)
 logic [4:0] shamt3; //used for SLLIW, SRLIW, SRAIW
 logic [20:0] jmp_offset; //used for JAL
 logic [11:0] jmpR_offset; //used for JALR

 assign op = inst_i[6:0];
 assign f3 = inst_i[14:12];
 assign f7 = inst_i[31:25];
 assign arith_imm = inst_i[31:20];
 assign dest_logic = inst_i[11:7];
 assign store_offset = {inst_i[31:25],inst_i[11:7]}; 
 assign load_offset = inst_i[31:20];
 assign upper_imm = inst_i[31:12];
 assign br_offset = {inst_i[31],inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
 assign shamt = inst_i[25:20]; //6-bit shift amount
 assign shamt2 = in2_i[4:0]; //same
 assign shamt3 = inst_i[24:20];
 assign jmp_offset = {inst_i[31],inst_i[19:12],inst_i[20],inst_i[30:21],1'b0};
 assign jmpR_offset = inst_i[31:20];

 always_comb begin
   if(all_retry || reset_pyri) begin
     pc_o_valid_next = 1'b0;
     inst_o_valid_next = 1'b0;
     rdata_o_valid_next = 1'b0;
     raddr_o_valid_next = 1'b0;
     branch_pc_o_valid_next = 1'b0;
   end
 end

 always_comb begin
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    if(op == `OP_ARITH && all_valid) begin 
      if(f3 == `FUNCT3_ARITH_ADD) begin //000
        if(f7 == `FUNCT7_ARITH_ADD) begin                                         //ADD
          rdata_o_next = $signed(in1_i) + $signed(in2_i);
        end else begin                                                            //SUB
          rdata_o_next = $signed(in1_i) - $signed(in2_i);
        end
      end else if(f3 == `FUNCT3_ARITH_SLL) begin //001                            //SLL
        rdata_o_next = in1_i << shamt2;
      end else if(f3 == `FUNCT3_ARITH_SLT) begin //010                            //SLT
        if($signed(in1_i) < $signed(in2_i)) begin
          rdata_o_next = 64'b1;
        end else begin
          rdata_o_next = 64'b0;
        end
      end else if(f3 == `FUNCT3_ARITH_SLTU) begin //011                           //SLTU
        if(in1_i < in2_i) begin//set to less than unsigned
          rdata_o_next = 64'b1;
        end else begin
          rdata_o_next = 64'b0;
        end
      end else if(f3 == `FUNCT3_ARITH_XOR) begin //100                            //XOR
        rdata_o_next = in1_i ^ in2_i; //Bit-wise logical XOR
      end else if(f3 == `FUNCT3_ARITH_SRL || f3 == `FUNCT3_ARITH_SRA) begin //101
        if(f7 == `FUNCT7_ARITH_SRL) begin                                         //SRL
          rdata_o_next = in1_i >> shamt2; //32 bit SRL
        end else begin                                                            //SRA
          rdata_o_next = $signed(in1_i) >>> shamt2;
        end
      end else if(f3 == `FUNCT3_ARITH_OR) begin //110                             //OR
        rdata_o_next = in1_i | in2_i; //Bit-wise logical OR
      end else if(f3 == `FUNCT3_ARITH_AND) begin //111                            //AND
        rdata_o_next = in1_i & in2_i; //Bit-wise logcial AND
      end
      raddr_o_next = {59'b0,dest_logic};
      rdata_o_valid_next = all_valid;
      raddr_o_valid_next = all_valid;
      inst_o_valid_next = inst_i_valid;
      pc_o_valid_next = pc_i_valid;
      pc_o_next = pc_i;
      inst_o_next = inst_i;
      branch_pc_o_valid_next = 0;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    end else if(op == `OP_ARITH_I && all_valid) begin 
      if(f3 == `FUNCT3_ARITH_I_ADDI) begin //000                                  //ADDI
        rdata_o_next = $signed({{52{arith_imm[11]}},arith_imm}) + $signed(in1_i);
      end else if(f3 == `FUNCT3_ARITH_I_SLTI) begin //010                         //SLTI
        if($signed(in1_i) < $signed({{52{arith_imm[11]}},arith_imm})) begin
          rdata_o_next = 64'b1;
        end else begin
          rdata_o_next = 64'b0;
        end
      end else if(f3 == `FUNCT3_ARITH_I_SLTIU) begin //011                        //SLTIU
        if(in1_i < {{52{arith_imm[11]}},arith_imm}) begin//set to less than unsigned immediate
          rdata_o_next = 64'b1;
        end else begin
          rdata_o_next = 64'b0;
        end
      end else if(f3 == `FUNCT3_ARITH_I_XORI) begin //100                         //XORI
        rdata_o_next = {{52{arith_imm[11]}},arith_imm} ^ in1_i;
      end else if(f3 == `FUNCT3_ARITH_I_ORI) begin //110                          //ORI
        rdata_o_next = {{52{arith_imm[11]}},arith_imm} | in1_i;
      end else if(f3 == `FUNCT3_ARITH_I_ANDI) begin //111                         //ANDI
        rdata_o_next = {{52{arith_imm[11]}},arith_imm} & in1_i;
      end else if(f3 == `FUNCT3_ARITH_I_SLLI) begin //001 64 bit                  //SLLI
        rdata_o_next = in1_i << shamt; //shift left logical immediate
      end else if(f3 == `FUNCT3_ARITH_I_SRLI) begin 
        if(f7[5] == 1'b0) begin                                      //SRLI
          rdata_o_next = $signed(in1_i) >> shamt;//shift right logical immediate
        end else if (f7[5] == 1'b1) begin                            //SRAI
          rdata_o_next = $signed(in1_i) >>> shamt;
        end
      end
      raddr_o_next = {59'b0,dest_logic};
      rdata_o_valid_next = all_valid;
      raddr_o_valid_next = all_valid;
      inst_o_valid_next = inst_i_valid;
      pc_o_valid_next = pc_i_valid;
      pc_o_next = pc_i;
      inst_o_next = inst_i;
      branch_pc_o_valid_next = 0;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    end else if(op == `OP_STORE && all_valid) begin 
      if(f3 == `FUNCT3_STORE_SB) begin //Store bottom 8 bits                       //SB
        rdata_o_next = {{56{in2_i[7]}},in2_i[7:0]};
      end else if(f3 == `FUNCT3_STORE_SH) begin //Store bottom 16 bits            //SH
        rdata_o_next = {{48{in2_i[15]}},in2_i[15:0]};
      end else if(f3 == `FUNCT3_STORE_SW) begin //Store bottom 32 bits            //SW
        rdata_o_next = {{32{in2_i[31]}},in2_i[31:0]};
      end else if(f3 == `FUNCT3_STORE_SD) begin //64 bit store                    //SD
        rdata_o_next = in2_i;
      end
      raddr_o_next = in1_i + {{52{store_offset[11]}},store_offset};
      rdata_o_valid_next = all_valid;
      raddr_o_valid_next = all_valid;
      inst_o_valid_next = inst_i_valid;
      pc_o_valid_next = pc_i_valid;
      pc_o_next = pc_i;
      inst_o_next = inst_i;
      branch_pc_o_valid_next = 0;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    end else if(op == `OP_LOAD && all_valid) begin
      if(f3 == `FUNCT3_LOAD_LB || f3 == `FUNCT3_LOAD_LH || f3 == `FUNCT3_LOAD_LW || //LB,LH,LW,LD
         f3 == `FUNCT3_LOAD_LD || f3 == `FUNCT3_LOAD_LBU || f3 == `FUNCT3_LOAD_LHU || //LBU,LHU,LWU
         f3 == `FUNCT3_LOAD_LWU) begin
        rdata_o_next = $signed(in1_i) + $signed({{52{load_offset[11]}},load_offset});
        raddr_o_next = {59'b0, dest_logic};
      end
      rdata_o_valid_next = all_valid;
      raddr_o_valid_next = all_valid;
      inst_o_valid_next = inst_i_valid;
      pc_o_valid_next = pc_i_valid;
      pc_o_next = pc_i;
      inst_o_next = inst_i;
      branch_pc_o_valid_next = 0;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    end else if(op == `OP_BRANCH && all_valid) begin
      if(f3 == `FUNCT3_BRANCH_BEQ) begin                                            //BEQ
        if($signed(in1_i) == $signed(in2_i)) begin //BRANCH equal
          branch_pc_o_next = $signed(pc_i) + $signed({{51{br_offset[12]}},br_offset});
        end else begin
          branch_pc_o_next = $signed(pc_i) + 4;
        end
      end else if(f3 == `FUNCT3_BRANCH_BNE) begin                                   //BNE
        if($signed(in1_i) != $signed(in2_i)) begin //BRANCH not equal
          branch_pc_o_next = $signed(pc_i) + $signed({{51{br_offset[12]}},br_offset});
        end else begin
          branch_pc_o_next = $signed(pc_i) + 4;
        end
      end else if(f3 == `FUNCT3_BRANCH_BLT) begin                                   //BLT
        if($signed(in1_i) < $signed(in2_i)) begin //BRANCH less than
          branch_pc_o_next = $signed(pc_i) + $signed({{51{br_offset[12]}},br_offset});
        end else begin
          branch_pc_o_next = $signed(pc_i) + 4;
        end
      end else if(f3 == `FUNCT3_BRANCH_BGE) begin                                   //BGE
        if($signed(in1_i) >= $signed(in2_i)) begin //BRANCH greater than or equal to
          branch_pc_o_next = $signed(pc_i) + $signed({{51{br_offset[12]}},br_offset});
        end else begin
          branch_pc_o_next = $signed(pc_i) + 4;
        end
      end else if(f3 == `FUNCT3_BRANCH_BLTU) begin                                  //BLTU
        if(in1_i < in2_i) begin //BRANCH less than unsigned
          branch_pc_o_next = $signed(pc_i) + $signed({{51{br_offset[12]}},br_offset});
        end else begin
          branch_pc_o_next = $signed(pc_i) + 4;
        end
      end else if(f3 == `FUNCT3_BRANCH_BGEU) begin                                  //BGEU
        if(in1_i >= in2_i) begin //BRANCH greater than or equal to unsigned
          branch_pc_o_next = $signed(pc_i) + $signed({{51{br_offset[12]}},br_offset});
        end else begin
          branch_pc_o_next = $signed(pc_i) + 4;
        end
      end
      branch_pc_o_valid_next = all_valid;
      inst_o_valid_next = inst_i_valid;
      pc_o_valid_next = pc_i_valid;
      pc_o_next = pc_i;
      inst_o_next = inst_i;
      rdata_o_valid_next = 0;
      raddr_o_valid_next = 0;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    end else if((op == `OP_JALR || op == `OP_JAL) && all_valid) begin 
      if(op == `OP_JALR) begin                                                      //JALR
        branch_pc_o_next = ($signed(in1_i) + {{52{jmpR_offset[11]}},jmpR_offset}) & 64'hfffffffffffffffe;
        branch_pc_o_valid_next = all_valid;
      end else begin                                                                //JAL
        branch_pc_o_next = {{43{jmp_offset[20]}},jmp_offset};
        branch_pc_o_valid_next = 0;
      end
      rdata_o_next = $signed(pc_i) + 4;
      raddr_o_next = {59'b0,dest_logic};
      rdata_o_valid_next = all_valid;
      raddr_o_valid_next = all_valid;
      inst_o_valid_next = inst_i_valid;
      pc_o_valid_next = pc_i_valid;
      pc_o_next = pc_i;
      inst_o_next = inst_i;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    end else if((op == `OP_AUIPC || op == `OP_LUI) && all_valid) begin              //AUIPC
      if(op == `OP_AUIPC) begin
        rdata_o_next = $signed({{32{upper_imm[19]}},upper_imm,12'b0}) + $signed(pc_i);
      end else begin                                                                //LUI
        rdata_o_next = {{32{upper_imm[19]}},upper_imm,12'b0};
      end
      raddr_o_next = {59'b0,dest_logic};
      rdata_o_valid_next = all_valid;
      raddr_o_valid_next = all_valid;
      inst_o_valid_next = inst_i_valid;
      pc_o_valid_next = pc_i_valid;
      pc_o_next = pc_i;
      inst_o_next = inst_i;
      branch_pc_o_valid_next = 0;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    end else if(op == `OP_64ARITH_I && all_valid) begin
      if(f3 == `FUNCT3_64ARITH_I_ADDIW) begin                                                     //ADDIW
        rdata_o_next = $signed({{52{arith_imm[11]}},arith_imm}) + $signed({{32{in1_i[31]}},in1_i[31:0]});
      end else if(f3 == `FUNCT3_64ARITH_I_SLLIW) begin                                            //SLLIW
        help = in1_i[31:0] << shamt3;
        rdata_o_next = {{32{help[31]}}, help};
      end else if(f3 == `FUNCT3_64ARITH_I_SRLIW || f3 == `FUNCT3_64ARITH_I_SRAIW) begin
        if(f7 == `FUNCT7_64ARITH_I_SRLIW) begin                                                   //SRLIW
          help = in1_i[31:0] >> shamt3;
          rdata_o_next = {32'b0, help};
        end else begin                                                                            //SRAIW
          help = $signed(in1_i[31:0]) >>> shamt3;
          rdata_o_next = {{32{help[31]}}, help};
        end
      end
      raddr_o_next = {59'b0,dest_logic};
      rdata_o_valid_next = all_valid;
      raddr_o_valid_next = all_valid;
      inst_o_valid_next = inst_i_valid;
      pc_o_valid_next = pc_i_valid;
      pc_o_next = pc_i;
      inst_o_next = inst_i;
      branch_pc_o_valid_next = 0;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    end else if(op == `OP_64ARITH && all_valid) begin
      if(f3 == `FUNCT3_64ARITH_ADDW || f3 == `FUNCT3_64ARITH_SUBW) begin
        if(f7 == `FUNCT7_64ARITH_ADDW) begin                                                      //ADDW
          help = $signed(in1_i[31:0]) + $signed(in2_i[31:0]);
          rdata_o_next = $signed({{32{help[31]}},help});
        end else begin                                                                            //SUBW
          help = $signed(in1_i[31:0]) - $signed(in2_i[31:0]);
          rdata_o_next = $signed({{32{help[31]}},help});
        end
      end else if(f3 == `FUNCT3_64ARITH_SLLW) begin                                               //SLLW
        help = in1_i[31:0] << shamt2;
        rdata_o_next = {{32{help[31]}},help};
      end else if(f3 == `FUNCT3_64ARITH_SRLW || f3 == `FUNCT3_64ARITH_SRAW) begin
        if(f7 == `FUNCT7_64ARITH_SRLW) begin                                                      //SRLW
          help = in1_i[31:0] >> shamt2;
          rdata_o_next = {32'b0,help};
        end else begin                                                                            //SRAW
          help = $signed(in1_i[31:0]) >>> shamt2;
          rdata_o_next = {{32{help[31]}},help};
        end
      end
      raddr_o_next = {59'b0,dest_logic};
      rdata_o_valid_next = all_valid;
      raddr_o_valid_next = all_valid;
      inst_o_valid_next = inst_i_valid;
      pc_o_valid_next = pc_i_valid;
      pc_o_next = pc_i;
      inst_o_next = inst_i;
      branch_pc_o_valid_next = 0;
    end else begin //++++++++++++++++++++++++++++++++++++++++++++++++++
      rdata_o_valid_next = 0;
      raddr_o_valid_next = 0;
      inst_o_valid_next = 0;
      pc_o_valid_next = 0;
      pc_o_next = pc_i;
      inst_o_next = inst_i;
      branch_pc_o_valid_next = 0;
      rdata_o_next = 0;
      raddr_o_next = 0;
    end
 end




endmodule


