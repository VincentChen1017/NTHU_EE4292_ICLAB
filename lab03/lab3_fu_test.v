// `timescale 1ns/1ps // set the timescale for the simulation
module lab3_fu_test;  // module of testbench

parameter CYCLE = 10; // use CYCLE to describe the clock period
parameter DATA_WIDTH = 16; // data width
parameter INS_WIDTH = 5; // instruction width
parameter PATTERN_NUM = 320;
///// declare input(reg) and output(wire) /////
// use reg to declare inputs of the circuit //
// ex: reg [4:0] gray_in; or reg [SIZE-1:0] gray_in
reg clk;
reg rst_n;
reg signed [DATA_WIDTH-1:0] A;
reg signed [DATA_WIDTH-1:0] B;
reg [INS_WIDTH-1:0] instruction;
// use wire to declare outputs of the circuit //
// ex: wire [4:0] bin_out;
wire signed [DATA_WIDTH-1:0] F_o;

integer i,j,k;


///// instantiate  module /////
// instantiate the module you finished in following format //
// module_name #(.parameter1(5),.parameter2(3)) unit_name (.port1(...), .port2(...), ...); //
// ex: gray2bin #(.SIZE(7)) U0 (.bin(x),.gray(y),.clk(z));
lab3_fu 
#(
  .DATA_WIDTH(DATA_WIDTH),
  .INS_WIDTH(INS_WIDTH)
)
FU(
  .clk(clk),
  .rst_n(rst_n),
  .A(A),
  .B(B),
  .instruction(instruction),
  .F_o(F_o)
);


// use the following commands to dump the waveform of the simulation //

initial begin

  $fsdbDumpfile("lab3_fu.fsdb"); // "gray.fsdb" can be replaced into any name you want
  $fsdbDumpvars;                 // but make sure in .fsdb format
end
//


// the following command generates the behavior of the clock signal and system control
// #(x1) means delay x1 time, the time unit is declared at `timescale

always #(CYCLE/2) clk = ~clk; //clk toggles every half cycle

// System block set only clock, reset signal and the timeout finish. 
initial begin
  // 1. set the initial state of the clk and reset, ex: clk=0;
  // 2. set your reset behavior
  // 3. call finish function when the simulation runs time out.
  //    Proper constrain simulation time at beginning helps you reduce the debugging period.
  //    $finish <- this command indicates that the simulation is over
  //    Ex. #(CYCLE*LARGE_NUMBER) $finish;
  clk = 0;
  rst_n = 1;
  #(CYCLE) rst_n = 0;
  #(CYCLE) rst_n = 1;
  #(CYCLE*5000) $finish;
end


// pattern feeding block, control when and what pattern to feed to the circuit.
// this block can be considered as a behavior model of a verification module or other modules interfacing your circuit.
initial begin
  // 1. set the initial state of the testing signal
  // 2. finish your testbench here, you should verify all functions in ALU with different combination of input signals
  // 3. you can use wait or @(negedge clk), to control when to feed your pattern
  // ex: wait(rst_n==1) do something.../ @(negedge clk) do something...
  //    You can check the testbench in lab2 for full demenstration.
  // 4. you can use for or while loop to generate all possible inputs to verify your answer
  // ex: for(i=0;i<50;i=i+1)begin   // no i++ in verilog
  // 5. Besides generating patterns in testbench, you can also read patterns from external file.
  //    You can check the testbench in lab2 for full demenstration.
  // ex: reg [bitwidth-1:0] pattern_ary [0:pat_num-1];
  //     $readmemh("pattern.dat",pattern_ary);
  // It's suggested to use the method in 5, since we can generate patterns and results from other software(your algorithm),
  // and verify your circuit with reference algorithm. A reference pattern "golden.dat" is provided for (A=100,B=-201) requirement.
  // You can check the testbench in lab2 for full demenstration.
  A = 0;
  B = 0;
  instruction = 0;
  wait(rst_n==0);
  wait(rst_n==1);
  
  @(negedge clk)A = 16'h9f76 ; B = 16'hbde5 ; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end
  
  @(negedge clk)A = 16'hcb91 ; B = 16'hf144; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end
  
  @(negedge clk)A = 16'hbd69 ; B = 16'hec1d; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end
  
  @(negedge clk)A = 16'h076c ; B = 16'h7733; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end  
  
  @(negedge clk)A = 16'hf17f ; B = 16'ha623; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end
  
  @(negedge clk)A = 16'he6a1 ; B = 16'h1cfb; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end
  
  @(negedge clk)A = 16'h7814 ; B = 16'h3f1f; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end
  
  @(negedge clk)A = 16'h8b33 ; B = 16'h92ed; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end
  
  @(negedge clk)A = 16'h035b ; B = 16'h377b; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end
  
  @(negedge clk)A = 16'h478c ; B = 16'hea95; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end
  
  @(negedge clk)A = 16'hc406 ; B = 16'h28db; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end
 
  @(negedge clk)A = 16'hcc11 ; B = 16'h2386; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end
  
  @(negedge clk)A = 16'h9e11 ; B = 16'h206f; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end
 
  @(negedge clk)A = 16'h0074 ; B = 16'hdf14; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end
  
  @(negedge clk)A = 16'h359e ; B = 16'h3729; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end  

  @(negedge clk)A = 16'hfb7f ; B = 16'hdf56; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end 

  @(negedge clk)A = 16'h4a0f ; B = 16'hf623; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end  

  @(negedge clk)A = 16'h8a0a ; B = 16'had86; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end  

  @(negedge clk)A = 16'h346c ; B = 16'hf0e3; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end  
   
  @(negedge clk)A = 16'hb0cd ; B = 16'hf770; instruction = 0;
  for(i=1; i<12; i=i+1)begin
  @(negedge clk)instruction = i ;
  end
  for(i=16; i<20; i=i+1)begin
  @(negedge clk) instruction = i ;
  end
    
end

reg [55:0] golden [0:PATTERN_NUM-1];
integer fp_w;
// output result checking block, control when to sample and verify the result.
// this block can be considered as a behavior model of a verification module or other modules interfacing your circuit.
initial begin
  // 0. Use the same control technique to control when to sample output result.
  // 1. use $display command to show the state of signal
  // ex: $display("x = %b", x); %b means to display x in binary, you can try %d, %h or others.
  // 2. you can also write the result to a text file and verify the result with other program
  // ex: integer  fp_w;
  //     fp_w = $fopen("data_in.txt");
  //     $fwrite(fp_w, "%d %d %d\n", a, b, c); 不會自動換行
  //     $fdisplay(fp_w, "xxxxxxxxxxx %d", a); 會自動換行
  // 3. when displaying result, timing stamp is an important infomation, you can get time stamp with $time
  // ex: $display("%t happens xxx", $time);
  // As the suggestion in pattern feeding block, you can read the results generated from other software,
  // rather than write the same operations in testbench and circuit. It's useless to verify difference between a+b and a+b.
  $readmemh("golden2.dat",golden);
  fp_w = $fopen("output.txt");
  wait(rst_n==0);
  wait(rst_n==1);
  #(CYCLE*2);
  for(j=0; j<PATTERN_NUM; j=j+1) begin
    @(negedge clk);
    if(F_o!==golden[j][15:0])begin
      $display("************* Pattern No.%d is wrong ************", j);
      $display("A = %b, B = %b, instruction = %b",golden[j][55:40],golden[j][39:24],golden[j][23:16]);  
      $display("golden = %b, but your answer is %b QQ Orz ",golden[j][15:0], F_o);  
      $finish;
    end
    else begin
      $display("A = %d, B= %d, instruction = %d, F_o = %d", A, B, instruction, F_o);
      $fdisplay(fp_w, "A = %d, B= %d, instruction = %d, F_o= %d", A, B, instruction, F_o);
    end
  end
  $display("Congratulations!! The functionality of your FU is correct!!");  
  $fdisplay(fp_w, "// A_B_instruction_F_o");
  #(CYCLE) $finish;
  
end



// Besides fixed pattern, you can use $random to generate random integer
// ex: a={$random} % 32   //return 0~31
// ex: a= min+{$random}%(max-min+1); // return min~ max

endmodule