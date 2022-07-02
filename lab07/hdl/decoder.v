`define IDLE 0
`define DECODE 1

module decoder
  #
    (
      parameter SRAM_DATA_WIDTH = 4,
      parameter SRAM_ADDR_WIDTH = 7,
      parameter DATA_WIDTH = 8
    )
    (
      input clk,
      input rst_n,
      input [DATA_WIDTH-1:0] width,               // image width
      input enable, // for decode enable
      input [SRAM_DATA_WIDTH-1:0] SRAM_data,
      output reg SRAM_enable,
      output reg [SRAM_ADDR_WIDTH-1:0] SRAM_addr,
      output reg valid,                           // valid ASCII code
      output reg [DATA_WIDTH-1:0] out,            // decoded ASCII code
      output reg done                             // finish decoding 3-row of image
    );

  // read 3 rows to start to decode
  // e.g.
  // access address 0, 40, 80 and store the data in buffer -> decode ->
  // access address 1, 41, 81 -> decode ... -> done
  // remember to calculate where is the end of the row to output done
  reg [SRAM_ADDR_WIDTH-1:0] SRAM_addr_tmp;
  reg [SRAM_ADDR_WIDTH-1:0] n_SRAM_addr;
  reg [1:0] cnt, cnt_n; // for addr
  reg [2:0] cnt_decode, cnt_decode_n; // for decode
  reg [SRAM_DATA_WIDTH-1:0] data_tmp[0:2];
  reg [5:0] cnt_3ROW_tmp, cnt_3ROW;
  reg [1:0] state, nstate;

  /*always@*
    if(enable)
      SRAM_enable = 1;
    else
      SRAM_enable = 0;*/

  ///// FSM /////
  always@(posedge clk)
  begin
    if(~rst_n)
      state <= `IDLE;
    else
      state <= nstate;
  end

  always@*
  case(state)
    `IDLE:
    begin
      SRAM_enable = 0;
      if(enable)
      begin
        SRAM_enable = 1;
        nstate = `DECODE;
      end
      else
        nstate = `IDLE;
    end
    `DECODE:
    begin
      SRAM_enable = 1;
      if(done)
        nstate = `IDLE;
      else
        nstate = `DECODE;
    end
    default:
    begin
      SRAM_enable = 0;
      nstate = `IDLE;
    end
  endcase

  /////access address/////
  always@(posedge clk)
  begin
    if(~rst_n)
      cnt <= 0;
    else
      cnt <= cnt_n;
  end

  always@*
  begin
    if(enable && cnt!=2)
      cnt_n = cnt + 1;
    else
      cnt_n = 0;
  end

  always@(posedge clk)
  begin
    if(~rst_n)
    begin
      n_SRAM_addr <= 0 ;
    end
    else
    begin
      n_SRAM_addr <= SRAM_addr_tmp;
    end
  end

  always@*
    if(done)
      SRAM_addr_tmp = 0;
    else if(enable && cnt==2)
      SRAM_addr_tmp = n_SRAM_addr + 1;
    else
      SRAM_addr_tmp = n_SRAM_addr;

  always@*
  begin
    case(cnt)
      0:
        SRAM_addr = n_SRAM_addr;
      1:
        SRAM_addr = n_SRAM_addr + 40;
      2:
        SRAM_addr = n_SRAM_addr + 80;
      default:
        SRAM_addr = n_SRAM_addr;
    endcase
  end
  ///////////////////////////////////////

  /////Decode/////
  integer i;
  always@(posedge clk)
    if(~rst_n)
      for(i=0; i<3; i=i+1)
        data_tmp[i] <= 0;
    else
    begin
      data_tmp[2] <= SRAM_data;
      data_tmp[1] <= data_tmp[2];
      data_tmp[0] <= data_tmp [1];
    end

  always@(posedge clk)
  begin
    if(~rst_n)
      cnt_decode <= 0;
    else
      cnt_decode <= cnt_decode_n;
  end

  always@*
  begin
    if(SRAM_addr>0 && cnt_decode!=3)
      cnt_decode_n = cnt_decode + 1;
    else if(cnt_decode==3)
      cnt_decode_n = 1;
    else
      cnt_decode_n = 0;
  end

  always@*
  begin
    if(cnt_decode==3)
    begin
      if(data_tmp[0][0]==0)
        out = {data_tmp[0][1],data_tmp[0][2],data_tmp[1][0],data_tmp[1][1],data_tmp[1][2],data_tmp[2][0],data_tmp[2][1],data_tmp[2][2]};
      else
        out = {data_tmp[1][0],data_tmp[2][0],data_tmp[0][1],data_tmp[1][1],data_tmp[2][1],data_tmp[0][2],data_tmp[1][2],data_tmp[2][2]};
      valid = 1;
    end
    else
    begin
      out = 0;
      valid = 0;
    end
  end

  //******************************check*******************************************
  always@(posedge clk)
    if(~rst_n)
      cnt_3ROW <= 0;
    else
      cnt_3ROW <= cnt_3ROW_tmp;

  always@*
    if(valid)
      cnt_3ROW_tmp = cnt_3ROW + 1;
    else if(cnt_3ROW==width/3)
      cnt_3ROW_tmp = 0;
    else
      cnt_3ROW_tmp = cnt_3ROW;

  always@*
    if(cnt_3ROW == (width/3))
      done = 1;
    else
      done = 0;  //*******要改看幾個CYCLE後才會吐出值




endmodule
