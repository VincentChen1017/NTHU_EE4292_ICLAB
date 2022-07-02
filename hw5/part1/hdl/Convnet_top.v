module Convnet_top #(
parameter CH_NUM = 4,
parameter ACT_PER_ADDR = 4,
parameter BW_PER_ACT = 12
)
(
input clk,                          
input rst_n,  // synchronous reset (active low)
input enable, // start sending image from testbanch
output busy,  // control signal for stopping loading input image
output valid, // output valid for testbench to check answers in corresponding SRAM groups
input [BW_PER_ACT-1:0] input_data, // input image data
// read data from SRAM group A
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a3,
// read address from SRAM group A
output [5:0] sram_raddr_a0,
output [5:0] sram_raddr_a1,
output [5:0] sram_raddr_a2,
output [5:0] sram_raddr_a3,       
// write enable for SRAM group A 
output sram_wen_a0,
output sram_wen_a1,
output sram_wen_a2,
output sram_wen_a3,
// wordmask for SRAM group A 
output [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a,
// write addrress to SRAM group A 
output [5:0] sram_waddr_a,
// write data to SRAM group A 
output [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a
);


unshuffle
	unshuffle 
(
	.clk(clk),                          
	.rst_n(rst_n),  // synchronous reset (active low)
	.enable(enable), // start sending image from testbanch
	.busy(busy),  // control signal for stopping loading input image
	.valid(valid), // output valid for testbench to check answers in corresponding SRAM groups
	.input_data(input_data), // input image data
	// write enable for SRAM group A 
	.sram_wen_a0(sram_wen_a0),
	.sram_wen_a1(sram_wen_a1),
	.sram_wen_a2(sram_wen_a2),
	.sram_wen_a3(sram_wen_a3),
	// wordmask for SRAM group A 
	.sram_wordmask_a(sram_wordmask_a),
	// write addrress to SRAM group A 
	.sram_waddr_a(sram_waddr_a),
	// write data to SRAM group A 
	.sram_wdata_a(sram_wdata_a)
);

	
endmodule




