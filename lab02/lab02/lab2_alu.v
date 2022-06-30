module lab2_alu(
  //clock and control signals
  input clk,
  input rst_n,
  //input
  input [7:0] inputA, inputB,
  input [3:0] instruction,
  //output
  output reg [7:0] alu_out
);

reg [7:0] tmp_A, tmp_B;
reg [3:0] tmp_instruction;
reg [7:0] tmp_alu_out;

always@(posedge clk) begin
  if(~rst_n)
  tmp_A <= 0;
  else
  tmp_A <= inputA;
end

always@(posedge clk) begin
  if(~rst_n)
  tmp_B <= 0;
  else
  tmp_B <= inputB;
end

always@(posedge clk) begin
  if(~rst_n)
  tmp_instruction <= 0;
  else
  tmp_instruction <= instruction;
end

always@(posedge clk) begin
  if(~rst_n)
  alu_out <= 0;
  else
  alu_out <= tmp_alu_out;
end

//ALU
always@* begin
  tmp_alu_out = (tmp_A ^ tmp_B);
  case(tmp_instruction)
    4'b0000: tmp_alu_out = (tmp_A + tmp_B);
    4'b0001: tmp_alu_out = (tmp_A - tmp_B);
    4'b0010: tmp_alu_out = ~tmp_B;
    4'b0011: tmp_alu_out = (tmp_A & tmp_B);
    4'b0100: tmp_alu_out = (tmp_A | tmp_B);
  endcase
end

endmodule
