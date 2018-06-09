Verilog Implementation of the RISC-V core processor.

Includes 4 Main Stages:
1) Fetch Stage
  -> Fetch iCache: toy memory cache for storing test instructions
2) Decode Stage
  -> Decode regCache: holds register values (32 in total)
3) Execute Stage
4) Write Back Stage
  -> Write Back dCache: toy memory to imitate real memory
