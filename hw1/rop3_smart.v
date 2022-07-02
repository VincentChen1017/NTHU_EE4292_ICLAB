/*
* Module      : rop3_smart
* Description : Implement this module using the bit-hack technique mentioned in the assignment handout.
*               This module should support all the possible modes of ROP3.
* Notes       : Please remember to
*               (1) make the bit-length of {P, S, D, Result} parameterizable
*               (2) make the input/output to be a register
*/

module rop3_smart
#(
  parameter N = 8
)
(
  input clk,
  input [N-1:0] P,
  input [N-1:0] S,
  input [N-1:0] D,
  input [7:0] Mode,
  output reg [N-1:0] Result
);

reg [N-1:0] P_tmp;
reg [N-1:0] S_tmp;
reg [N-1:0] D_tmp;
reg [7:0] Mode_tmp;
reg [N-1:0] function_out;
reg [7:0] temp1_0, temp1_1, temp1_2, temp1_3, temp1_4, temp1_5, temp1_6, temp1_7;
reg [7:0] temp2_0, temp2_1, temp2_2, temp2_3, temp2_4, temp2_5, temp2_6, temp2_7;
// input register
always@(posedge clk) begin
	P_tmp <= P;
	S_tmp <= S;
	D_tmp <= D;
	Mode_tmp <= Mode;
end

// output register
always@(posedge clk) begin
	Result <= function_out;
end

// magical formulation : ROP3 works on each bit position i independently
always@* begin // temp1_i, temp2_i is used to do bit i's operation
	//Bit0
	temp1_0 = 8'h1<<{P_tmp[0], S_tmp[0], D_tmp[0]};
	temp2_0 = temp1_0 & Mode_tmp;
	function_out[0] = |temp2_0;
	//Bit1
	temp1_1 = 8'h1<<{P_tmp[1], S_tmp[1], D_tmp[1]};
	temp2_1 = temp1_1 & Mode_tmp;
	function_out[1] = |temp2_1;
	//Bit2
	temp1_2 = 8'h1<<{P_tmp[2], S_tmp[2], D_tmp[2]};
	temp2_2 = temp1_2 & Mode_tmp;
	function_out[2] = |temp2_2;
	//Bit3
	temp1_3 = 8'h1<<{P_tmp[3], S_tmp[3], D_tmp[3]};
	temp2_3 = temp1_3 & Mode_tmp;
	function_out[3] = |temp2_3;
	//Bit4
	temp1_4 = 8'h1<<{P_tmp[4], S_tmp[4], D_tmp[4]};
	temp2_4 = temp1_4 & Mode_tmp;
	function_out[4] = |temp2_4;
	//Bit5
	temp1_5 = 8'h1<<{P_tmp[5], S_tmp[5], D_tmp[5]};
	temp2_5 = temp1_5 & Mode_tmp;
	function_out[5] = |temp2_5;
	//Bit6
	temp1_6 = 8'h1<<{P_tmp[6], S_tmp[6], D_tmp[6]};
	temp2_6 = temp1_6 & Mode_tmp;
	function_out[6] = |temp2_6;
	//Bit7
	temp1_7 = 8'h1<<{P_tmp[7], S_tmp[7], D_tmp[7]};
	temp2_7 = temp1_7 & Mode_tmp;
	function_out[7] = |temp2_7;
end





endmodule
