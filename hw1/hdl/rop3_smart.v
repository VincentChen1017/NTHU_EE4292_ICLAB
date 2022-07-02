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
  parameter N = 32
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
reg [7:0] temp1[0:N-1];
reg [7:0] temp2[0:N-1];
integer i;

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
	
	for(i=0; i<N; i=i+1)begin
		temp1[i] = 8'h1<<{P_tmp[i], S_tmp[i], D_tmp[i]};
		temp2[i] = temp1[i] & Mode_tmp;
		function_out[i] = |temp2[i];
	end

end



endmodule
