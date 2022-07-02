`define  CYCLE 10

module test_rop3_smart;

parameter N = 8; // data_width


// declare input
reg [N-1:0] P_in, S_in, D_in;
reg [7:0] Mode_in;
reg clk;

// declare output
wire [N-1:0] Result_RTL_lut16;
wire [N-1:0] Result_RTL_smart;


//instantiate RTL module
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

rop3_lut16
#(
  .N(N)
)
lut16
(
  .clk(clk),
  .P(P_in),
  .S(S_in),
  .D(D_in),
  .Mode(Mode_in),
  .Result(Result_RTL_lut16)
);

// create clk
initial clk = 0;
always #(`CYCLE/2) clk = ~clk;
  
// input feeding
integer i, j, k; // for generate all the combination of P, S, D

initial begin

	for(i=0; i<(2**N); i=i+1) begin
		for(j=0; j<(2**N); j=j+1) begin
			for(k=0; k<(2**N); k=k+1) begin
				@(negedge clk) Mode_in = 8'h00; P_in = i; S_in = j; D_in =k;
				@(negedge clk) Mode_in = 8'h11; P_in = i; S_in = j; D_in =k;
				@(negedge clk) Mode_in = 8'h33; P_in = i; S_in = j; D_in =k;
				@(negedge clk) Mode_in = 8'h44; P_in = i; S_in = j; D_in =k;
				@(negedge clk) Mode_in = 8'h55; P_in = i; S_in = j; D_in =k;
				@(negedge clk) Mode_in = 8'h5A; P_in = i; S_in = j; D_in =k;
				@(negedge clk) Mode_in = 8'h66; P_in = i; S_in = j; D_in =k;
				@(negedge clk) Mode_in = 8'h88; P_in = i; S_in = j; D_in =k;
				@(negedge clk) Mode_in = 8'hBB; P_in = i; S_in = j; D_in =k;
				@(negedge clk) Mode_in = 8'hC0; P_in = i; S_in = j; D_in =k;
				@(negedge clk) Mode_in = 8'hCC; P_in = i; S_in = j; D_in =k;
				@(negedge clk) Mode_in = 8'hEE; P_in = i; S_in = j; D_in =k;
				@(negedge clk) Mode_in = 8'hF0; P_in = i; S_in = j; D_in =k;
				@(negedge clk) Mode_in = 8'hFB; P_in = i; S_in = j; D_in =k;
				@(negedge clk) Mode_in = 8'hFF; P_in = i; S_in = j; D_in =k;
	end
		end
			end
end 



// computation result comparasion
integer pattern_i;
integer pattern_num;
initial begin
	pattern_i = 0;
  pattern_num = (2**N)*(2**N)*(2**N)*15;
	@(negedge clk);
	@(negedge clk);
	while(pattern_i < pattern_num) begin
    @(posedge clk);
    #1;
    if (Result_RTL_lut16 !== Result_RTL_smart) begin
			$display("************* PATTERN %d ERROR QQQ *************",pattern_i);
      $display("smart Result = %h, lut16 result = %h", Result_RTL_smart, Result_RTL_lut16);
      $finish;
		end
		pattern_i = pattern_i + 1;
	end
  $display("************** Test by total %d input pattern **************",pattern_i);
  $display("************* The Function and Result of smart and lut16 are the same !!! *************");
  $finish;
end

/*initial begin
   $fsdbDumpfile("rop3_smart.fsdb");
   $fsdbDumpvars;
end*/


endmodule
