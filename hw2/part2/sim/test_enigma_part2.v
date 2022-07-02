`define CYCLE 10
`define DELAY 10
`define MODE 0 // encrypt 0, decrypt 1
module test_enigma_part2;
  parameter IDLE = 0, LOAD = 1, READY = 2;
  parameter MODE0 = 0, MODE1 = 1, MODE2 = 2, MODE3 = 3;

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

  // instantiate RTL module;
  enigma_part2
    #(
      .IDLE(IDLE),
      .LOAD(LOAD),
      .READY(READY),
      .MODE0(MODE0),
      .MODE1(MODE1),
      .MODE2(MODE2),
      .MODE3(MODE3)
    )
    part2
    (
      .clk(clk),
      .srstn(srstn),
      .load(load),
      .encrypt(encrypt),
      .crypt_mode(crypt_mode),
      .load_idx(load_idx),
      .code_in(code_in),
      .code_out(code_out),
      .code_valid(code_valid)
    );

  // create clock
  initial
    clk = 0;
  always #(`CYCLE/2) clk = ~clk;

  // input feeding
  integer i,j,k,a,b,c;
  reg [6-1:0] rotorA_table[0:64-1];
  reg [6-1:0] rotorB_table[0:64-1];
  reg [6-1:0] rotorC_table[0:64-1];
  reg [6-1:0] plaintext1[0:24-1];
  reg [6-1:0] ciphertext1[0:24-1];

  initial
  begin
    // rotor_table
    $readmemh("../sim/rotor/rotorA.dat",rotorA_table);
    $readmemh("../sim/rotor/rotorB.dat",rotorB_table);
    $readmemh("../sim/rotor/rotorC.dat",rotorC_table);
    //  plaintext
    $readmemh("../sim/pat/plaintext1.dat",plaintext1);

    //  ciphertext
    $readmemh("../sim/pat/ciphertext1.dat",ciphertext1);

    crypt_mode = `MODE;
    srstn = 1;
    load = 0;
    encrypt = 0;
    #(`CYCLE) srstn=0;
    #(`CYCLE) srstn=1;
    load=1;
		@(negedge clk);
    for(a=0; a<64; a=a+1)
    begin
      @(negedge clk) code_in = rotorA_table[a];
    end
    for(b=0; b<64; b=b+1)
    begin
      @(negedge clk) code_in = rotorB_table[b];
    end
    for(c=0; c<64; c=c+1)
    begin
      @(negedge clk) code_in = rotorC_table[c];
    end

    // start encrypt
    #(`CYCLE*2) load = 0;
    @(negedge clk);
		@(negedge clk);
		encrypt = 1;
    if(`MODE==0)
      code_in = plaintext1[0];
    else
      code_in = ciphertext1[0];
    for(j=1; j<24; j=j+1)
    begin
      if(`MODE==0)
        @(negedge clk) code_in = plaintext1[j];
      else
        @(negedge clk) code_in = ciphertext1[j];
    end
  end

  initial
  begin
		load_idx = 0;
    #(`CYCLE) ;
    #(`CYCLE) ;
    #(`CYCLE) ;
    for(i=0; i<192; i=i+1)
    begin
      @(negedge clk) load_idx = i;
    end

  end

  // check the encrypted result
  integer error=0;
  initial
  begin
    wait(encrypt)
        #(`DELAY); // RTL needd to delay a cycle to read out because of the input flip flop
    for(k=0; k<24; k=k+1)
    begin
      @(posedge clk);
      #1;
      if(`MODE==0)
      begin
        $display(" #%d The plaintext is %h // The Golden ciphertext is %h // My ciphertext is %h",k, plaintext1[k], ciphertext1[k], code_out);
        if(code_out!=ciphertext1[k])
        begin
          error = error + 1;
          $display("symbol #%d is wrong",k);
        end
      end
      else
      begin
        $display(" #%d The ciphertext is %h // The Golden plaintext is %h // My plaintext is %h",k, ciphertext1[k], plaintext1[k], code_out);
        if(code_out!=plaintext1[k])
        begin
          error = error + 1;
          $display("*************symbol #%d is wrong*************",k);
        end
      end
    end
    $display("The Enigma result error is %d",error);
    $finish;
  end

  initial
  begin
    $fsdbDumpfile("part2.fsdb");
    $fsdbDumpvars;
  end

endmodule
