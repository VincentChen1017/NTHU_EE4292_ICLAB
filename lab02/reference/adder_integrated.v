module 	adder_integrated (
	input clk,    // Clock
	input rst_n,  // Synchronous reset active low
	input [15:0] A0, A1,
	output reg [15:0] Y
);

reg [15:0] A0_reg, A1_reg;
reg [15:0] Y_;

always@(posedge clk)begin
	if(~rst_n)begin
		A0_reg <= 0;
		A1_reg <= 0;
	end
	else begin
		A0_reg <= A0;
		A1_reg <= A1;
	end
end

always@(*)begin
	Y_ = A0_reg - A1_reg;
end
always@(posedge	clk)begin
	if(~rst_n)begin
		Y <= 0;
	end
	else begin
		Y <= Y_;
	end
end

endmodule