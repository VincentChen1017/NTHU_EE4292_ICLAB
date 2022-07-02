`define IDLE 0
`define DRAM 1
`define SRAM 2
`define DECO 3
module steganography
  #
    (
      parameter DRAM_DATA_WIDTH = 32,
      parameter SRAM_DATA_WIDTH = 4,
      parameter SRAM_ADDR_WIDTH = 7,
      parameter DATA_WIDTH = 8
    )
    (
      input clk,
      input rst_n,
      input enable,
      input [DATA_WIDTH-1:0] width,    // image width
      input [DATA_WIDTH-1:0] height,   // image height
      output reg DRAM_enable,
      input DRAM_data_valid,
      input [DRAM_DATA_WIDTH-1:0] DRAM_data,
      output reg valid,                // valid ASCII out
      output reg [DATA_WIDTH-1:0] out, // decoded ASCII code
      output reg done                  // finish to decode image
    );

  // signals connect to SRAM
  reg SRAM_enable;
  reg SRAM_r_w;
  reg [SRAM_DATA_WIDTH-1:0] SRAM_in;
  reg [SRAM_ADDR_WIDTH-1:0] SRAM_addr;
  reg [SRAM_ADDR_WIDTH-1:0] SRAM_addr_tmp;
  wire [SRAM_DATA_WIDTH-1:0] SRAM_out;

  // signals connect to decoder
  reg decoder_enable;
  wire [SRAM_DATA_WIDTH-1:0] decoder_SRAM_data;
  wire decoder_SRAM_enable;
  wire [SRAM_ADDR_WIDTH-1:0] decoder_SRAM_addr;
  wire decoder_valid;
  wire [DATA_WIDTH-1:0] decoder_out;
  wire decoder_done;

  reg [5:0]times, times_tmp;
  reg [1:0] state, nstate;
  reg SRAM_done;
  reg FSM_SRAM_enable;
  reg [SRAM_ADDR_WIDTH-1:0] FSM_SRAM_addr;
  reg [SRAM_ADDR_WIDTH-1:0] FSM_SRAM_addr_tmp;
  // FSM
  always@*
  begin
    case(state)
      `IDLE:
      begin
        DRAM_enable = 0;
        FSM_SRAM_enable = 0;
        decoder_enable = 0;
        SRAM_r_w = 1;
        if(enable)
        begin
          nstate = `DRAM;
        end
        else
          nstate = `IDLE;
      end
      `DRAM:
      begin
        DRAM_enable = 1;
        FSM_SRAM_enable = 0;
        decoder_enable = 0;
        SRAM_r_w = 1;
        if(DRAM_data_valid)
        begin
          FSM_SRAM_enable = 1; // DRAM_data_valid change to high, next posedge clk SRAM will be write immediately
          SRAM_r_w = 0;
          nstate = `SRAM;
        end
        else
          nstate = `DRAM;
      end
      `SRAM: // read DRAM output to SRAM
      begin
        DRAM_enable = 1;
        FSM_SRAM_enable = 1;
        decoder_enable = 0;
        SRAM_r_w = 0;
        if(SRAM_done)
        begin
          DRAM_enable = 0;
          nstate = `DECO;
        end
        else
          nstate = `SRAM;
      end
      `DECO:
      begin
        DRAM_enable = 0;
        FSM_SRAM_enable = 0;
        decoder_enable = 1;
        SRAM_r_w = 1;
        if(decoder_done)
        begin
          nstate = `DRAM;
        end
        else
          nstate = `DECO;
      end
      default:
      begin
        DRAM_enable = 0;
        FSM_SRAM_enable = 0;
        SRAM_r_w = 1;
        decoder_enable = 0;
        nstate = `IDLE;
      end
    endcase
  end

  always@(posedge clk)
    if(~rst_n)
      state <= `IDLE;
    else
      state <= nstate;

  // SRAM address choose
  always@*
  begin
    if(~SRAM_r_w) //r_w==0:write, r_w==1:read
      SRAM_addr = FSM_SRAM_addr;
    else
      SRAM_addr = decoder_SRAM_addr;
  end


  // SRAM enable choose
  always@*
    if(~SRAM_r_w)
      SRAM_enable = FSM_SRAM_enable;
    else
      SRAM_enable = decoder_SRAM_enable;

  /////SRAM_write/////
  always@*
  begin
    if(FSM_SRAM_enable)
    begin
      if(FSM_SRAM_addr==(width/3)-1)
      begin
        FSM_SRAM_addr_tmp = FSM_SRAM_addr + (40-(width/3)+1);
      end
      else if(FSM_SRAM_addr==(width/3)-1+40)
      begin
        FSM_SRAM_addr_tmp = FSM_SRAM_addr + (40-(width/3)+1);
      end
      else
      begin
        FSM_SRAM_addr_tmp = FSM_SRAM_addr + 1;
      end
    end
    else
      FSM_SRAM_addr_tmp = 0;
  end

  always@(posedge clk)
    if(~rst_n)
      FSM_SRAM_addr <= 0;
    else
      FSM_SRAM_addr <= FSM_SRAM_addr_tmp;

  always@* // SRAM_addr=95 next cycle SRAM be filled up
    if(FSM_SRAM_addr==(width/3)-1+80)
      SRAM_done = 1;
    else
      SRAM_done = 0;

  always@*
  begin
    if(DRAM_data_valid)
    begin
      SRAM_in = {1'b0,DRAM_data[16],DRAM_data[8],DRAM_data[0]};
    end
    else
      SRAM_in = {1'b0,DRAM_data[16],DRAM_data[8],DRAM_data[0]};
  end

  ///// SRAM Write /////
  assign decoder_SRAM_data = (decoder_enable)? SRAM_out:0;

  ///// output /////
  always@(posedge clk)
    if(~rst_n)
    begin
      out <= 0;
      valid <= 0;
    end
    else
    begin
      out <=decoder_out;
      valid <= decoder_valid;
    end
  ///// How much 3ROWS be done
  always@(posedge clk)
    if(~rst_n)
      times <= 0;
    else
      times <= times_tmp;

  always@*
    if(decoder_done && times!=height/3)
      times_tmp = times + 1;
    else
      times_tmp = times;

  always@*
    if(times==height/3)
      done = 1;
    else
      done = 0;



  SRAM
    u_SRAM
    (
      .clk(clk), // ok
      .enable(SRAM_enable), // ok
      .r_w(SRAM_r_w), // ok
      .in(SRAM_in), // ok
      .addr(SRAM_addr), // ok
      .out(SRAM_out) // ok
    );

  decoder
    u_decoder
    (
      .clk(clk), // ok
      .rst_n(rst_n), // ok
      .width(width), // ok
      .enable(decoder_enable), // ok
      .SRAM_data(decoder_SRAM_data), // ok
      .SRAM_enable(decoder_SRAM_enable), // ok
      .SRAM_addr(decoder_SRAM_addr), //ok
      .valid(decoder_valid),// ok
      .out(decoder_out), // ok
      .done(decoder_done)// ok
    );

endmodule
