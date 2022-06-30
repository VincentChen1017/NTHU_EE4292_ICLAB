module d_ff #(parameter BIT_WIDTH = 8)
(
	input clk,    // Clock
	input rst_n,  // Synchronous reset active low
	input [BIT_WIDTH-1:0] d,
	output reg [BIT_WIDTH-1:0] q
);
always @(posedge clk) begin : proc_q
	if(~rst_n) begin
		q <= 0;
	end 
	else begin
		q <= d;
	end
end
endmodule


module combinational_block #(parameter BIT_WIDTH = 8)(
	input [BIT_WIDTH-1:0] A0, A1,
	output reg [BIT_WIDTH-1:0] Y
);
//assign Y = A0 + A1;
always @(*) begin : proc_Y
	Y = A0 + A1;
end
endmodule
