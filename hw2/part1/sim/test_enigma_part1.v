`define CYCLE 10
`define DELAY 10
module test_enigma_part1;
parameter IDLE = 0, LOAD = 1, READY = 2;

// declare input
reg clk;
reg srstn;
reg load;
reg encrypt;
reg crypt_mode;
reg [8-1:0] load_idx;
reg [6-1:0] code_in;

// declare output
wire [6-1:0] code_out;
wire code_valid;
wire [6-1:0] out_RTL;
wire [6-1:0] out_beh;

// instantiate behavior module;
behavior_model
#(
  .IDLE(IDLE),
  .LOAD(LOAD),
  .READY(READY)
)
behavior
(
  .clk(clk),
  .srstn(srstn),
  .load(load),
  .encrypt(encrypt),
  .crypt_mode(crypt_mode),
  .load_idx(load_idx),
  .code_in(code_in),
  .code_out(out_beh),
  .code_valid(code_valid)
);

enigma_part1
#(
  .IDLE(IDLE),
  .LOAD(LOAD),
  .READY(READY)
)
part1
(
  .clk(clk),
  .srstn(srstn),
  .load(load),
  .encrypt(encrypt),
  .crypt_mode(crypt_mode),
  .load_idx(load_idx),
  .code_in(code_in),
  .code_out(out_RTL),
  .code_valid(code_valid)
);
// decide which output is used
assign code_out = (`DELAY==10)? out_RTL:out_beh;



// create clock
initial clk = 0;
always #(`CYCLE/2) clk = ~clk;

// input feeding
integer i,j,k;
reg [6-1:0] rotorA_table[0:64-1];
reg [6-1:0] plaintext1[0:23-1];
reg [6-1:0] ciphertext1[0:23-1];
initial begin

// rotor_table
$readmemh("../sim/rotor/rotorA.dat",rotorA_table);

//  plaintext 
$readmemh("../sim/pat/plaintext1.dat",plaintext1);

//  ciphertext
$readmemh("../sim/pat/ciphertext1.dat",ciphertext1);

  srstn = 1;
  load = 0;
  encrypt = 0;
  #(`CYCLE) srstn=0;
  #(`CYCLE) srstn=1; load=1;
  for(i=0; i<64; i=i+1) begin
      @(negedge clk) code_in = rotorA_table[i];
    end 
  // start encrypt
  #(`CYCLE*2) load = 0;
  @(negedge clk) encrypt = 1; code_in = plaintext1[0];
  for(j=1; j<23; j=j+1) begin
      @(negedge clk) code_in = plaintext1[j];
    end
end

// check the encrypted result
initial begin
  wait(encrypt)
	#(`DELAY); // RTL needd to delay a cycle to read out because of the input flip flop
  for(k=0; k<23; k=k+1) begin
		@(posedge clk);
		#1;
    $display(" #%d The plaintext is %h // The golden ciphertext is %h // My ciphertext is %h",k, plaintext1[k], ciphertext1[k], code_out);
  end
  $finish;
end

/*initial begin
   $fsdbDumpfile("behavior.fsdb");
   $fsdbDumpvars;
end*/

endmodule


