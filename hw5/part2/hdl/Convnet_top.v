module Convnet_top #(
parameter CH_NUM = 4,
parameter ACT_PER_ADDR = 4,
parameter BW_PER_ACT = 12,
parameter WEIGHT_PER_ADDR = 9, 
parameter BIAS_PER_ADDR = 1,
parameter BW_PER_PARAM = 8
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
// read data from SRAM group B
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b3,
// read data from parameter SRAM
input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_weight,  
input [BIAS_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_bias,     
// read address to SRAM group A
output  [5:0] sram_raddr_a0,
output  [5:0] sram_raddr_a1,
output  [5:0] sram_raddr_a2,
output  [5:0] sram_raddr_a3,
// read address to SRAM group B
output [5:0] sram_raddr_b0,
output [5:0] sram_raddr_b1,
output [5:0] sram_raddr_b2,
output [5:0] sram_raddr_b3,
// read address to parameter SRAM
output [9:0] sram_raddr_weight,       
output [5:0] sram_raddr_bias,         
// write enable for SRAM groups A & B
output reg sram_wen_a0,
output reg sram_wen_a1,
output reg sram_wen_a2,
output reg sram_wen_a3,
output sram_wen_b0,
output sram_wen_b1,
output sram_wen_b2,
output sram_wen_b3,
// word mask for SRAM groups A & B
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a,
output [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b,
// write addrress to SRAM groups A & B
output reg [5:0] sram_waddr_a,
output [5:0] sram_waddr_b,
// write data to SRAM groups A & B
output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a,
output [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b
);

localparam IDLE = 0,
					 UNSFL	= 1,
					 CONV1 = 2;

wire unsfl_done;
reg conv1_enable;
reg [1:0] state, nstate;

always@* begin
	conv1_enable = 0;
	nstate = IDLE;
	case(state)
		IDLE: begin
			if(enable)
				nstate = UNSFL;
			else
				nstate = IDLE;
		end

		UNSFL: begin
			if(unsfl_done)
				nstate = CONV1;
			else
				nstate = UNSFL; 
		end
		
		CONV1: begin
			conv1_enable = 1;
			nstate = CONV1;
		end
	endcase
end

always@(posedge clk)
	if(~rst_n)
		state <= IDLE;
	else
		state <= nstate;



wire sram_wen_a0_unsfl;
wire sram_wen_a1_unsfl;
wire sram_wen_a2_unsfl;
wire sram_wen_a3_unsfl;
wire [CH_NUM*ACT_PER_ADDR-1:0]sram_wordmask_a_unsfl;
wire [5:0]sram_waddr_a_unsfl;
wire signed[CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0]sram_wdata_a_unsfl;
unshuffle
	unshuffle 
(
	.clk(clk),                          
	.rst_n(rst_n),  // synchronous reset (active low)
	.enable(enable), // start sending image from testbanch
	.busy(busy),  // control signal for stopping loading input image
	.done(unsfl_done), // after unshuffle, conv1's enable
	.input_data(input_data), // input image data
	// write enable for SRAM group A 
	.sram_wen_a0(sram_wen_a0_unsfl),
	.sram_wen_a1(sram_wen_a1_unsfl),
	.sram_wen_a2(sram_wen_a2_unsfl),
	.sram_wen_a3(sram_wen_a3_unsfl),
	// wordmask for SRAM group A 
	.sram_wordmask_a(sram_wordmask_a_unsfl),
	// write addrress to SRAM group A 
	.sram_waddr_a(sram_waddr_a_unsfl),
	// write data to SRAM group A 
	.sram_wdata_a(sram_wdata_a_unsfl)
);

conv1
	conv1 
(
	.clk(clk),                          
	.rst_n(rst_n),  // synchronous reset (active low)
	.enable(conv1_enable), // start doing convolution layer1
	.valid(valid), // output valid for testbench to check answers in corresponding SRAM groups
// read data from SRAM group A
	.sram_rdata_a0(sram_rdata_a0),
	.sram_rdata_a1(sram_rdata_a1),
	.sram_rdata_a2(sram_rdata_a2),
	.sram_rdata_a3(sram_rdata_a3),
// read data from parameter SRAM
	.sram_rdata_weight(sram_rdata_weight),  
	.sram_rdata_bias(sram_rdata_bias),     
// read address to SRAM group A
	.sram_raddr_a0(sram_raddr_a0),
	.sram_raddr_a1(sram_raddr_a1),
	.sram_raddr_a2(sram_raddr_a2),
	.sram_raddr_a3(sram_raddr_a3),
// read address to parameter SRAM
	.sram_raddr_weight(sram_raddr_weight),       
	.sram_raddr_bias(sram_raddr_bias),         
// write enable for SRAM groups A & B
	.sram_wen_b0(sram_wen_b0),
	.sram_wen_b1(sram_wen_b1),
	.sram_wen_b2(sram_wen_b2),
	.sram_wen_b3(sram_wen_b3),
// word mask for SRAM groups A & B
	.sram_wordmask_b(sram_wordmask_b),
// write addrress to SRAM groups A & B
	.sram_waddr_b(sram_waddr_b),
// write data to SRAM groups A & B
	.sram_wdata_b(sram_wdata_b)
);
	
always@*
	case(state)
		UNSFL: begin
			sram_wen_a0 = sram_wen_a0_unsfl;
			sram_wen_a1 = sram_wen_a1_unsfl;
			sram_wen_a2 = sram_wen_a2_unsfl;
			sram_wen_a3 = sram_wen_a3_unsfl;
			sram_wordmask_a = sram_wordmask_a_unsfl;
			sram_waddr_a = sram_waddr_a_unsfl;
			sram_wdata_a = sram_wdata_a_unsfl;
		end
		default: begin
			sram_wen_a0 = 1;
			sram_wen_a1 = 1;
			sram_wen_a2 = 1;
			sram_wen_a3 = 1;
			sram_wordmask_a = 16'b1111111111111111;
			sram_waddr_a = 0;
			sram_wdata_a = 0;
		end
	endcase









endmodule
