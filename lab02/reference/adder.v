module adder (
	input clk,    // Clock
	input rst_n,  // Synchronous reset active low
	input [15:0] A0, A1,
	output [15:0] Y
);

wire [15:0] A0_reg, A1_reg, Y_;
d_ff #(.BIT_WIDTH(16)) A0_ff (.clk(clk), .rst_n(rst_n), .d(A0), .q(A0_reg));
d_ff #(.BIT_WIDTH(16)) A1_ff (.clk(clk), .rst_n(rst_n), .d(A1), .q(A1_reg));
d_ff #(.BIT_WIDTH(16)) Y_ff (.clk(clk), .rst_n(rst_n), .d(Y_), .q(Y));

combinational_block #(.BIT_WIDTH(16)) ADDR (.A0(A0_reg), .A1(A1_reg), .Y(Y_));
endmodule

