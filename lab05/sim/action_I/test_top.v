`include "../../source/CPU_define.v"
module test_top;

parameter PERIOD = 20;
parameter WORD = 255;
//input
reg clk;
reg rst_n;
reg [31:0] instruction [255:0];

//wire [15:0]PC_out;
wire EXE_alu_overflow;

reg boot_up;
reg [7:0] boot_addr;
reg [31:0] boot_datai;
reg boot_web;

wire  peri_web;
wire [15:0] peri_addr;
wire [15:0] peri_datao;

top top_U0(
.clk(clk),
.rst_n(rst_n),
.boot_up(boot_up),
.boot_addr(boot_addr),
.boot_datai(boot_datai),
.boot_web(boot_web),

.peri_web(peri_web),
.peri_addr(peri_addr),
.peri_datao(peri_datao)

);



initial begin
	$fsdbDumpfile("lab5.fsdb");
	$fsdbDumpvars("+mda");
end

parameter BOOT_CODE_SIZE = 32;

reg [31:0] mem [0:BOOT_CODE_SIZE-1];

integer i;
//read instuction from instruction.txt to Icache
initial begin
	$readmemb("instruction.txt",mem, 0 , BOOT_CODE_SIZE-1);
end

always #(PERIOD/2) clk = ~clk;

integer j;

initial begin
clk = 1;
rst_n = 1;
boot_up = 0;
boot_addr = 0;
boot_datai = 0;
boot_web = 1;
@(negedge clk);
#(PERIOD) rst_n = 0;
#(PERIOD) rst_n = 1; boot_up =1;
for (j=0 ; j<BOOT_CODE_SIZE;j=j+1)begin
#(PERIOD) boot_web = 1'b0;
          boot_addr = j[7:0];
          boot_datai = mem[j];
end

#(PERIOD) boot_up =0; boot_web = 1'b1; boot_addr = 0; boot_datai = 0;

end




//check result
integer r1,r2,r3,r4,r5,r6,r7,r8,r9,r10;
integer d2,d4,d6,d8;

initial begin
  #(PERIOD);
  @(negedge boot_up);
  r1  = 0; 
  r2  = 0; 
  r3  = 0; 
  r4  = 0; 
  r5  = 0; 
  r6  = 0; 
  r7  = 0; 
  r8  = 0; 
  r9  = 0; 
  r10 = 0; 
  d2  = 0; 
  d4  = 0; 
  d6  = 0; 
  d8  = 0; 
  r1  = 15      ;                                          
  r3  = 20      ;                                          
  r4  = r3 + r1 ;                                          
  r5  = r4 + r1 ;                                          
  d2  = r5      ;                                          
  r6  = d2      ;                                          
  r7  = r6 + 10 ;                                          
  r8  = r6 + 20 ;                                          
  r9  = r7<<2   ;                                          
  r10 = r8>>1   ;                                          
  d2  = r7      ;                                          
  d4  = r8      ;                                          
  d6  = r9      ;                                          
  d8  = r10     ;                                          
  r1  = d2      ;                                          
  r2  = d4      ;                                          
  r3  = d6      ;                                          
  r4  = d8      ;                                          
  r5  = r9 - r10;                                          
  r6  = r9 & r10; //change this to mul(*) for comparison   
  r7  = r9 | r10;                                          
  r8  = r9 | r10;                                          
  r5  = r8 - r10;                                          
  r7  = r8 - r10;                                          
  r4  = r3 + r1 ;                                          
  r5  = r8 - r10;                                          
  #(PERIOD*35);
  show_register_value;

#(PERIOD) $finish;
end



integer f_register;
integer std_out = 1;
integer write_to;
task show_register_value;
begin
  f_register = $fopen("register_reg.txt"); 
  write_to   = f_register|std_out        ; 
  $fdisplay(write_to, "r1  = %d, the answer is %d\n", top_U0.ID_stage.regfile.gpr[1], r1)  ; 
  $fdisplay(write_to, "r2  = %d, the answer is %d\n", top_U0.ID_stage.regfile.gpr[2], r2)  ; 
  $fdisplay(write_to, "r3  = %d, the answer is %d\n", top_U0.ID_stage.regfile.gpr[3], r3)  ; 
  $fdisplay(write_to, "r4  = %d, the answer is %d\n", top_U0.ID_stage.regfile.gpr[4], r4)  ; 
  $fdisplay(write_to, "r5  = %d, the answer is %d\n", top_U0.ID_stage.regfile.gpr[5], r5)  ; 
  $fdisplay(write_to, "r6  = %d, the answer is %d\n", top_U0.ID_stage.regfile.gpr[6], r6)  ; 
  $fdisplay(write_to, "r7  = %d, the answer is %d\n", top_U0.ID_stage.regfile.gpr[7], r7)  ; 
  $fdisplay(write_to, "r8  = %d, the answer is %d\n", top_U0.ID_stage.regfile.gpr[8], r8)  ; 
  $fdisplay(write_to, "r9  = %d, the answer is %d\n", top_U0.ID_stage.regfile.gpr[9], r9)  ; 
  $fdisplay(write_to, "r10 = %d, the answer is %d\n", top_U0.ID_stage.regfile.gpr[10], r10); 
  $fdisplay(write_to, "d2  = %d, the answer is %d\n", top_U0.ID_stage.dcache.memory[2], d2); 
  $fdisplay(write_to, "d4  = %d, the answer is %d\n", top_U0.ID_stage.dcache.memory[4], d4); 
  $fdisplay(write_to, "d6  = %d, the answer is %d\n", top_U0.ID_stage.dcache.memory[6], d6); 
  $fdisplay(write_to, "d8  = %d, the answer is %d\n", top_U0.ID_stage.dcache.memory[8], d8); 
  $fclose(f_register);
end
endtask









endmodule
