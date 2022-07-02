`define CYCLE 10
`define DELAY 10
`define MODE 1 // encrypt 0, decrypt 1
module test_enigma_display;
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
  integer plaintext2;
  integer plaintext3;

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
  reg [6-1:0] ciphertext2[0:112-1];
  reg [6-1:0] ciphertext3[0:122836-1];


  initial
  begin
    // rotor_table
    $readmemh("../sim/rotor/rotorA.dat",rotorA_table);
    $readmemh("../sim/rotor/rotorB.dat",rotorB_table);
    $readmemh("../sim/rotor/rotorC.dat",rotorC_table);

    //  ciphertext
    $readmemh("../sim/pat/ciphertext2.dat",ciphertext2);
    $readmemh("../sim/pat/ciphertext3.dat",ciphertext3);


    plaintext2 = $fopen("plaintext2.dat");
    plaintext3 = $fopen("plaintext3.dat");
  end

  //////////////////// for inputdata1 ///////////////////
  integer inputtext_num = 0;
  initial
  begin
    crypt_mode = `MODE;
    srstn = 1;
    load = 0;
    encrypt = 0;
    #(`CYCLE) srstn=0;
    #(`CYCLE) srstn=1;
    load=1;

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
    // start decrypt
    #(`CYCLE*2) load = 0;
    @(negedge clk) encrypt = 1;
    code_in = ciphertext2[0];
    for(j=1; j<112; j=j+1)
    begin
      @(negedge clk) code_in = ciphertext2[j];
    end
  end

  initial
  begin
    load_idx = 8'b00000000;
    #(`CYCLE) ;
    #(`CYCLE) ;
    #(`CYCLE) ;
    for(i=0; i<192; i=i+1)
    begin
      @(negedge clk) load_idx = load_idx + 8'b00000001;
    end
  end
  //////////////////////////////////////////////////////

  //////////////////// for inputdata2 ///////////////////
  initial
  begin
    wait(inputtext_num==1);
    crypt_mode = `MODE;
    srstn = 1;
    load = 0;
    encrypt = 0;
    #(`CYCLE) srstn=0;
    #(`CYCLE) srstn=1;
    load=1;

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
    // start decrypt
    #(`CYCLE*2) load = 0;
    @(negedge clk) encrypt = 1;
    code_in = ciphertext2[0];
    for(j=1; j<122836; j=j+1)
    begin
      @(negedge clk) code_in = ciphertext3[j];
    end
  end

  initial
  begin
    wait(inputtext_num==1);
    load_idx = 8'b00000000;
    #(`CYCLE) ;
    #(`CYCLE) ;
    #(`CYCLE) ;
    for(i=0; i<192; i=i+1)
    begin
      @(negedge clk) load_idx = load_idx + 8'b00000001;
    end
  end
  //////////////////////////////////////////////////////

  /////////////////// check the encrypted result ///////////////////
`include "display_enigma_code.v"

  initial
  begin
    while(inputtext_num<2)
    begin
      wait(encrypt)
          #(`DELAY); // RTL needd to delay a cycle to read out because of the input flip flop
      if(inputtext_num==0)
      begin
        for(k=0; k<112; k=k+1)
        begin
          @(posedge clk);
          #1;
          // save ciphertext as plaintext.dat
          $fdisplay(plaintext2,"%h",code_out);
        end
      end
      else
      begin
        for(k=0; k<122836; k=k+1)
        begin
          @(posedge clk);
          #1;
          // save ciphertext as plaintext.dat
          $fdisplay(plaintext3,"%h",code_out);
        end
      end
      //////////////////// change enigma_code to ascii_code ////////////////////
      if(inputtext_num==0)
      begin
        $fclose(plaintext2);
        display_enigma_code("plaintext2.dat");
      end
      else
      begin
        $fclose(plaintext3);
        display_enigma_code("plaintext3.dat");
      end
      @(negedge clk) inputtext_num = inputtext_num + 1;
    end
    #10 $finish;
  end
  ////////////////////////////////////////////////////////////////////

  /*initial
    begin
      $fsdbDumpfile("display.fsdb");
      $fsdbDumpvars;
    end*/

endmodule
