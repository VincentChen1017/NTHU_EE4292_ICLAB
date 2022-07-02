/*
* Module      : rop3_lut16
* Description : Implement this module using the look-up table (LUT) 
*               This module should support all the 15-modes listed in table-1
*               For modes not in the table-1, set the Result to 0
* Notes       : Please remember to
*               (1) make the bit-length of {P, S, D, Result} parameterizable
*               (2) make the input/output to be a register 
*/

module rop3_lut16
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

// input register
always@(posedge clk)begin
	P_tmp <= P;
	S_tmp <= S;
	D_tmp <= D;
	Mode_tmp <= Mode;
end

// output register
always@(posedge clk)begin
	Result <= function_out;
end

// look up table
always@*
	case(Mode_tmp)
		8'h00: function_out = 8'h00;
		8'h11: function_out = ~(D_tmp | S_tmp);
		8'h33: function_out = ~S_tmp;
		8'h44: function_out = (S_tmp & ~D_tmp);
		8'h55: function_out = ~D_tmp;
		8'h5A: function_out = (D_tmp ^ P_tmp);
		8'h66: function_out = (D_tmp ^ S_tmp);
		8'h88: function_out = (D_tmp & S_tmp);
		8'hBB: function_out = (D_tmp | ~S_tmp);
		8'hC0: function_out = (P_tmp & S_tmp);
		8'hCC: function_out = S_tmp;
		8'hEE: function_out = (D_tmp | S_tmp);
		8'hF0: function_out = P_tmp;
		8'hFB: function_out = (D_tmp | P_tmp | ~S_tmp);
		8'hFF: function_out = 8'hFF;
		default: function_out = 0;
	endcase

endmodule



