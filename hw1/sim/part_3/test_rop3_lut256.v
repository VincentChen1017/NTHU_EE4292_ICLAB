`define CYCLE 10

module test_rop3_lut256;

parameter N = 8;


// declare input
reg [N-1:0] P_in, S_in, D_in;
reg [7:0] Mode_in;
reg clk;

// declare output
wire [N-1:0] Result_RTL_smart;
wire [N-1:0] Result_RTL_lut256;

// instantiate RTL module
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

// create clk
initial clk = 0;
always #(`CYCLE/2) clk = ~clk;

// input feeding
integer i, j ,k ,m; // for generate all combinations of P, S, D and Mode
reg [N-1:0] P_last, S_last, D_last, Mode_last;
reg [N-1:0] P_lastlast, S_lastlast, D_lastlast, Mode_lastlast;

initial begin
  P_in = 8'hzz;
  S_in = 8'hzz;
  D_in = 8'hzz;
  Mode_in = 8'hzz;
  
  for(m=0; m<(2**8); m=m+1)begin // change to next mode when all the combinations of P, S, D are feeded in.
    $display("********** Current Mode = %d **********", m);
    for(i=0; i<(2**N); i=i+1)begin
      for(j=0; j<(2**N); j=j+1)begin
        for(k=0; k<(2**N); k=k+1)begin
          @(negedge clk) Mode_in = m; P_in = i; S_in = j; D_in = k; // negedge feed input
          @(posedge clk) // trans last_data to next_stage
          Mode_lastlast = Mode_last; P_lastlast = P_last; S_lastlast = S_last; D_lastlast = D_last;
          Mode_last = Mode_in; P_last = P_in; S_last = S_in; D_last = D_in;
        end 
      end 
    end     
  end        
end

// computation result comparasion
time pattern_i;
time pattern_num;


initial begin
	pattern_i = 0;
  pattern_num = (2**N)*(2**N)*(2**N)*(2**8); // Total # pattern = 2^N * 2^N * 2^N * 2^8  
  
  // pipeline stages delay
	@(negedge clk);
	@(negedge clk); 
	while(pattern_i < pattern_num  ) begin 
    @(posedge clk);
    #1; // wave form clearly to understand why #1, ensure the Result and the pattern is match
  	if(Result_RTL_lut256 !== Result_RTL_smart) begin
			$display("************* PATTERN %d ERROR QQQ *************",pattern_i);
      $display("************* P = %b, S = %b, D = %b, Mode = %d *************", P_lastlast, S_lastlast, D_lastlast, Mode_lastlast);
      $display("smart Result = %b, lut256 result = %b", Result_RTL_smart, Result_RTL_lut256);
      $finish;
		end
		pattern_i = pattern_i + 1;
	end
  $display("************** Test by total %d input pattern **************",pattern_i);
  $display("************* The Function and Result of smart and lut256 are the same !!! *************");
  $finish;
end

/*initial begin
   $fsdbDumpfile("rop3_lut256.fsdb");
   $fsdbDumpvars;
end*/

endmodule
