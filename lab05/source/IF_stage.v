module IF_stage(
	input clk,
	input rst_n,
	input boot_up,
	input [7:0] boot_addr,
	input [31:0] boot_datai,
	input boot_web,
	input [15:0] Branch_in,
	input PCSrc,
	output [31:0] instn,
	output PC_run,
	output [15:0] PC_add
);

wire [9:0] PC_out;
wire [7:0] ins_addr;
assign ins_addr = PC_add[9:2];

PC PC(
	.clk(clk),
	.rst_n(rst_n),
  .boot_up(boot_up),
	.PCSrc(PCSrc),
	.PC_out(PC_add),
  .PC_run(PC_run),
	.Branch_in(Branch_in)
);

wire icache_en_wr = PC_run ? 1'b1 : boot_web;
wire [7:0] icache_addr = PC_run ? ins_addr : boot_addr;



/* instantiate SRAM256x32s as icache here
 * The I port of icache should take boot_datai as input
 * The O port of icache should drive instn for CPU as instruction
 * The read/write control signal is controlled by icache_en_wr
 */
SRAM256x32s icache(
  .CE(clk),
  .WEB(icache_en_wr),
  .OEB(0),
  .CSB(0),
  .A(icache_addr),
  .I(boot_datai),
  .O(instn)
);
 

endmodule
