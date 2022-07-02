`define CYCLE 10
`define MODE_L 0
`define MODE_U 255

module test_rop3;

parameter N = 8;

// 1. variable declaration and clock connection
// -----------------------------


// declare variables and connect clock here

// declare input
reg [N-1:0] P_in, S_in, D_in;
reg [7:0] Mode_in;
reg clk;

// declare output
wire [N-1:0] Result_RTL_smart;
wire [N-1:0] Result_RTL_lut256;

// create clk
initial clk = 0;
always #(`CYCLE/2) clk = ~clk;

// -----------------------------



// 2. connect RTL module 
// -----------------------------

// add your module here

rop3_smart
#(
  .N(N)
)
smart
(
  .clk(clk),
  .P(P_in),
  .S(S_in),
  .D(D_in),
  .Mode(Mode_in),
  .Result(Result_RTL_smart)
);

rop3_lut256
#(
  .N(N)
)
lut256
(
  .clk(clk),
  .P(P_in),
  .S(S_in),
  .D(D_in),
  .Mode(Mode_in),
  .Result(Result_RTL_lut256)
);

// -----------------------------



// Don't modify this two blocks
// -----------------------------
// input preparation
initial begin
    input_preparation;
end
// output comparision
initial begin
    output_comparison;
end
// -----------------------------


// 3. implement the above two functions in the task file
reg [N-1:0] P_last, S_last, D_last, Mode_last;
reg [N-1:0] P_lastlast, S_lastlast, D_lastlast, Mode_lastlast;
`include "./rop3.task"

endmodule
