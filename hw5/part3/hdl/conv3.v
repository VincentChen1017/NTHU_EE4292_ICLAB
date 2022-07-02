// timing 3.74  area 77,694
// timing 3.65  area 77,794
// timing 3.55  area 79,284
// timing 3.4   area 79,241
// timing 3.38  area 79,507
// timing 3.35  area 79,863
// timing 3.33  area 79,802
module conv #(
    parameter CH_NUM = 4,
    parameter ACT_PER_ADDR = 4,
    parameter BW_PER_ACT = 12,
    parameter WEIGHT_PER_ADDR = 9,
    parameter BW_PER_PARAM = 8,
    parameter BIAS_PER_ADDR = 1
  )
  (
    input clk,
    input rst_n,  // synchronous reset (active low)
    input enable, // start doing convolution layer1
    output reg valid, // output valid for testbench to check answers in corresponding SRAM groups
    // read data from SRAM group A
    input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a0,
    input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a1,
    input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a2,
    input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a3,
    // read data from SRAM group B
    input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b0,
    input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b1,
    input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b2,
    input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b3,
    // read data from parameter SRAM
    input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_weight,
    input [BIAS_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_bias,
    // read address to SRAM group A
    output reg [5:0] sram_raddr_a0,
    output reg [5:0] sram_raddr_a1,
    output reg [5:0] sram_raddr_a2,
    output reg [5:0] sram_raddr_a3,
    // read address to SRAM group B
    output reg [5:0] sram_raddr_b0,
    output reg [5:0] sram_raddr_b1,
    output reg [5:0] sram_raddr_b2,
    output reg [5:0] sram_raddr_b3,
    // read address to parameter SRAM
    output reg [9:0] sram_raddr_weight,
    output reg [5:0] sram_raddr_bias,
    // write enable for SRAM groups A & B
    output reg sram_wen_a0,
    output reg sram_wen_a1,
    output reg sram_wen_a2,
    output reg sram_wen_a3,
    output reg sram_wen_b0,
    output reg sram_wen_b1,
    output reg sram_wen_b2,
    output reg sram_wen_b3,
    // word mask for SRAM groups A & B
    output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a,
    output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b,
    // write addrress to SRAM groups A & B
    output reg [5:0] sram_waddr_a,
    output reg [5:0] sram_waddr_b,
    // write data to SRAM groups A & B
    output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a,
    output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b
  );

  localparam IDLE = 0,
             CONV	= 1,
             DONE = 2,
             CONV2 = 3,
             DONE2 = 4,
             CONV3 = 5,
             DONE3 = 6;
  integer i;
  reg [2:0]state, nstate;
  reg conv_enable;
  reg conv_done, nconv_done, nnconv_done, done, done2;

  // ===== FSM ===== //
  always@*
  begin
    conv_enable = 0;
    valid = 0;
    done = 0;
    done2 = 0;
    nstate = IDLE;
    case(state)
      IDLE:
      begin
        if(enable)
        begin
          nstate = CONV;
        end
        else
        begin
          nstate = IDLE;
        end
      end

      CONV:
      begin
        conv_enable = 1;
        if(conv_done)
        begin
          nstate = DONE;
        end
        else
          nstate = CONV;
      end

      DONE:
      begin
        //valid = 1; //test CONV1
        done = 1;
        nstate = CONV2;
      end

      CONV2:
      begin
        conv_enable = 1;
        if(conv_done)
        begin
          nstate = DONE2;
        end
        else
          nstate = CONV2;
      end

      DONE2:
      begin
        //valid = 1; //test CONV2
        done2 = 1;
        nstate = CONV3;
      end

      CONV3:
      begin
        conv_enable = 1;
        if(conv_done)
        begin
          nstate = DONE3;
        end
        else
          nstate = CONV3;
      end

      DONE3:
      begin
        valid = 1;
        nstate = DONE3;
      end
    endcase
  end

  always@(posedge clk)
    if(~rst_n)
      state <= IDLE;
    else
      state <= nstate;

  // ===== input data DFF ===== //
  reg signed[CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] nsram_rdata_a0;
  reg signed[CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] nsram_rdata_a1;
  reg signed[CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] nsram_rdata_a2;
  reg signed[CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] nsram_rdata_a3;
  reg signed[CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] nsram_rdata_b0;
  reg signed[CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] nsram_rdata_b1;
  reg signed[CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] nsram_rdata_b2;
  reg signed[CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] nsram_rdata_b3;
  reg signed[WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] nsram_rdata_weight;
  reg signed[BIAS_PER_ADDR*BW_PER_PARAM-1:0] nsram_rdata_bias;

  always@(posedge clk)
  begin
    nsram_rdata_a0 <= sram_rdata_a0;
    nsram_rdata_a1 <= sram_rdata_a1;
    nsram_rdata_a2 <= sram_rdata_a2;
    nsram_rdata_a3 <= sram_rdata_a3;
    nsram_rdata_b0 <= sram_rdata_b0;
    nsram_rdata_b1 <= sram_rdata_b1;
    nsram_rdata_b2 <= sram_rdata_b2;
    nsram_rdata_b3 <= sram_rdata_b3;
    nsram_rdata_weight <= sram_rdata_weight;
    nsram_rdata_bias <= sram_rdata_bias;
  end

  // ===== weight and bias addr ===== //
  always@(posedge clk)
  begin
    if(~rst_n)
      sram_raddr_weight <= 0;
    else if(done)
      sram_raddr_weight <= 16;
    else if(done2)
      sram_raddr_weight <= 64;
    else
    case(state)
      CONV:
        if(sram_raddr_weight==15)
          sram_raddr_weight <= 0;
        else
          sram_raddr_weight <= sram_raddr_weight + 1;
      CONV2:
        if(sram_raddr_weight==63)
          sram_raddr_weight <= 16;
        else
          sram_raddr_weight <= sram_raddr_weight + 1;
      CONV3:
        if(sram_raddr_weight==639)
          sram_raddr_weight <= 64;
        else
          sram_raddr_weight <= sram_raddr_weight + 1;
    endcase
  end

  always@(posedge clk)
  case(sram_raddr_weight)
    // CONV1
    2:
      sram_raddr_bias <= 0;
    6:
      sram_raddr_bias <= 1;
    10:
      sram_raddr_bias <= 2;
    14:
      sram_raddr_bias <= 3;
    // CONV2
    18:
      sram_raddr_bias <= 4;
    22:
      sram_raddr_bias <= 5;
    26:
      sram_raddr_bias <= 6;
    30:
      sram_raddr_bias <= 7;
    34:
      sram_raddr_bias <= 8;
    38:
      sram_raddr_bias <= 9;
    42:
      sram_raddr_bias <= 10;
    46:
      sram_raddr_bias <= 11;
    50:
      sram_raddr_bias <= 12;
    54:
      sram_raddr_bias <= 13;
    58:
      sram_raddr_bias <= 14;
    62:
      sram_raddr_bias <= 15;
    // CONV3
    74:
      sram_raddr_bias <= 16;
    74+12*1:
      sram_raddr_bias <= 17;
    74+12*2:
      sram_raddr_bias <= 18;
    74+12*3:
      sram_raddr_bias <= 19;
    74+12*4:
      sram_raddr_bias <= 20;
    74+12*5:
      sram_raddr_bias <= 21;
    74+12*6:
      sram_raddr_bias <= 22;
    74+12*7:
      sram_raddr_bias <= 23;
    74+12*8:
      sram_raddr_bias <= 24;
    74+12*9:
      sram_raddr_bias <= 25;
    74+12*10:
      sram_raddr_bias <= 26;
    74+12*11:
      sram_raddr_bias <= 27;
    74+12*12:
      sram_raddr_bias <= 28;
    74+12*13:
      sram_raddr_bias <= 29;
    74+12*14:
      sram_raddr_bias <= 30;
    74+12*15:
      sram_raddr_bias <= 31;
    74+12*16:
      sram_raddr_bias <= 32;
    74+12*17:
      sram_raddr_bias <= 33;
    74+12*18:
      sram_raddr_bias <= 34;
    74+12*19:
      sram_raddr_bias <= 35;
    74+12*20:
      sram_raddr_bias <= 36;
    74+12*21:
      sram_raddr_bias <= 37;
    74+12*22:
      sram_raddr_bias <= 38;
    74+12*23:
      sram_raddr_bias <= 39;
    74+12*24:
      sram_raddr_bias <= 40;
    74+12*25:
      sram_raddr_bias <= 41;
    74+12*26:
      sram_raddr_bias <= 42;
    74+12*27:
      sram_raddr_bias <= 43;
    74+12*28:
      sram_raddr_bias <= 44;
    74+12*29:
      sram_raddr_bias <= 45;
    74+12*30:
      sram_raddr_bias <= 46;
    74+12*31:
      sram_raddr_bias <= 47;
    74+12*32:
      sram_raddr_bias <= 48;
    74+12*33:
      sram_raddr_bias <= 49;
    74+12*34:
      sram_raddr_bias <= 50;
    74+12*35:
      sram_raddr_bias <= 51;
    74+12*36:
      sram_raddr_bias <= 52;
    74+12*37:
      sram_raddr_bias <= 53;
    74+12*38:
      sram_raddr_bias <= 54;
    74+12*39:
      sram_raddr_bias <= 55;
    74+12*40:
      sram_raddr_bias <= 56;
    74+12*41:
      sram_raddr_bias <= 57;
    74+12*42:
      sram_raddr_bias <= 58;
    74+12*43:
      sram_raddr_bias <= 59;
    74+12*44:
      sram_raddr_bias <= 60;
    74+12*45:
      sram_raddr_bias <= 61;
    74+12*46:
      sram_raddr_bias <= 62;
    74+12*47:
      sram_raddr_bias <= 63;
  endcase


  reg load_enable, nload_enable;
  always@(posedge clk)
    if(conv_enable)
      nload_enable <= 1;
    else
      nload_enable <= 0;
  always@(posedge clk)
    if(done || done2)
      load_enable <= 0;
    else
      load_enable <= nload_enable; // because of the input dff delay, weight_cnt must be delay two cycle to start to count.

  reg [9:0] weight_cnt;
  always@(posedge clk)
    if(~rst_n)
      weight_cnt <= 0;
    else if(done)
      weight_cnt <= 16;
    else if(done2)
      weight_cnt <= 64;
    else if(load_enable)
    begin
      case(state)
        CONV:
          if(weight_cnt==15)
            weight_cnt <= 0;
          else
            weight_cnt <= weight_cnt + 1;
        CONV2:
          if(weight_cnt==63)
            weight_cnt <= 16;
          else
            weight_cnt <= weight_cnt + 1;
        CONV3:
          if(weight_cnt==639)
            weight_cnt <= 64;
          else
            weight_cnt <= weight_cnt + 1;
      endcase
    end

  reg [3:0] conv3_ch_cnt;
  always@(posedge clk)
    if(~rst_n || conv3_ch_cnt==11)
      conv3_ch_cnt <= 0;
    else if(state==CONV3 && load_enable)
      conv3_ch_cnt <= conv3_ch_cnt + 1;

  // ===== feature_map position ===== //
  reg [2:0] height, nheight, width, nwidth, nnheight, nnwidth;
  always@(posedge clk)
    if(~rst_n || done || done2)
    begin
      height <= 0;
      width <= 0;
      nheight <= 0;
      nwidth <= 0;
    end
    else
    begin
      nheight <= nnheight;
      nwidth <= nnwidth;
      height <= nheight;
      width <= nwidth;
    end

  always@*
  begin
    nnheight = nheight;
    nnwidth = nwidth;
    nnconv_done = 0;
    case(state)
      CONV:
      begin
        if(weight_cnt==14)
        begin
          if(width==5)
          begin
            nnheight = nheight + 1;
            nnwidth = 0;
          end
          else
          begin
            nnheight = nheight;
            nnwidth = nwidth + 1;
          end
        end
        else
        begin
          nnheight = nheight;
          nnwidth = nwidth;
        end
        if(height==5 && width==5 && weight_cnt==15)
          nnconv_done = 1;
      end

      CONV2:
      begin
        if(weight_cnt==62)
        begin
          if(width==4)
          begin
            nnheight = nheight + 1;
            nnwidth = 0;
          end
          else
          begin
            nnheight = nheight;
            nnwidth = nwidth + 1;
          end
        end
        else
        begin
          nnheight = nheight;
          nnwidth = nwidth;
        end
        if(height==4 && width==4 && weight_cnt==63)
          nnconv_done = 1;
      end

      CONV3:
      begin
        if(weight_cnt==638)
        begin
          if(width==3)
          begin
            nnheight = nheight + 1;
            nnwidth = 0;
          end
          else
          begin
            nnheight = nheight;
            nnwidth = nwidth + 1;
          end
        end
        else
        begin
          nnheight = nheight;
          nnwidth = nwidth;
        end
        if(height==3 && width==3 && weight_cnt==639)
          nnconv_done = 1;
      end
    endcase
  end


  // ===== SRAM_B waddr ===== //
  reg [5:0] nsram_waddr_b;
  always@(posedge clk)
    if(~rst_n || done2)
      sram_waddr_b <= 0;
    else
      sram_waddr_b <= nsram_waddr_b;

  always@*
  begin
    nsram_waddr_b = sram_waddr_b;
    // For CONV1 write to SRAM_B
    if(state==CONV)
    case(height)
      0:
      begin
        if((width==2||width==4) && weight_cnt==1)
          nsram_waddr_b = sram_waddr_b + 1;
      end
      1,3,5:
      begin
        if((width==2||width==4) && weight_cnt==1)
          nsram_waddr_b = sram_waddr_b + 1;
        else if(width==0 && weight_cnt==1)
          nsram_waddr_b = sram_waddr_b - 2;
      end
      2,4:
      begin
        if((width==2||width==4) && weight_cnt==1)
          nsram_waddr_b = sram_waddr_b + 1;
        else if(width==0 && weight_cnt==1)
          nsram_waddr_b = sram_waddr_b + 4;
      end
    endcase
    // For CONV3 write to SRAM_B
    else // state== CONV3
    begin
      if(weight_cnt>112)
      begin
        if((weight_cnt-113)%48==0)
        begin
          nsram_waddr_b = sram_waddr_b + 1;
        end
      end
      else if(weight_cnt==65)
      begin
        if(width==0 && height==0)
        begin
          nsram_waddr_b = sram_waddr_b;
        end
        else
        begin
          nsram_waddr_b = 0;
        end
      end
    end
  end

  // ===== SRAM_A waddr ===== //
  reg [5:0] nsram_waddr_a;
  always@(posedge clk)
    if(~rst_n)
      sram_waddr_a <= 0;
    else
      sram_waddr_a <= nsram_waddr_a;

  always@*
  begin
    nsram_waddr_a = sram_waddr_a;
    case(height)
      0:
      case(weight_cnt)
        33:
          nsram_waddr_a = sram_waddr_a + 3;
        49:
          nsram_waddr_a = sram_waddr_a + 15;
        17:
          if(width==2||width==4)
            nsram_waddr_a = sram_waddr_a - 18 + 1;
          else if(width>0)
            nsram_waddr_a = sram_waddr_a - 18;
      endcase

      1,3:
      case(weight_cnt)
        33:
          nsram_waddr_a = sram_waddr_a + 3;
        49:
          nsram_waddr_a = sram_waddr_a + 15;
        17:
          if((width==2||width==4))
            nsram_waddr_a = sram_waddr_a -18 + 1;
          else if(width==0)
            nsram_waddr_a = sram_waddr_a -18 - 2;
          else
            nsram_waddr_a = sram_waddr_a -18;
      endcase

      2,4:
      case(weight_cnt)
        33:
          nsram_waddr_a = sram_waddr_a + 3;
        49:
          nsram_waddr_a = sram_waddr_a + 15;
        17:
          if((width==2||width==4))
            nsram_waddr_a = sram_waddr_a -18 + 1;
          else if(width==0)
            nsram_waddr_a = sram_waddr_a -18 + 4;
          else
            nsram_waddr_a = sram_waddr_a -18;
      endcase
    endcase
  end

  // ===== SRAM_A en & SRAM_B en ===== //
  reg height_mod, width_mod; // To decide which the bank the input should store into.
  reg nsram_wen_0, nsram_wen_1, nsram_wen_2, nsram_wen_3;
  reg nnsram_wen_0, nnsram_wen_1, nnsram_wen_2, nnsram_wen_3;
  always@*
  begin
    height_mod = height[0];
    width_mod = width[0];
    {nnsram_wen_0, nnsram_wen_1, nnsram_wen_2, nnsram_wen_3} = 4'b1111;
    case(state)
      CONV,CONV2:
      case((weight_cnt+1)%4)
        0:
        begin
          if(~height_mod)
            if(~width_mod)
              nnsram_wen_0 = 0;
            else
              nnsram_wen_1 = 0;
          else
            if(~width_mod)
              nnsram_wen_2 = 0;
            else
              nnsram_wen_3 = 0;
        end
      endcase
      CONV3:
      case((conv3_ch_cnt+1)%12)
        0:
        begin
          if(~height[1]) // height=0,1
            if(~width[1]) // width=0,1
              nnsram_wen_0 = 0;
            else // width=2,3
              nnsram_wen_1 = 0;
          else // height=1,3
            if(~width[1]) // width=0,1
              nnsram_wen_2 = 0;
            else // width=1,3
              nnsram_wen_3 = 0;
        end
      endcase
    endcase
  end

  always@(posedge clk)
  begin
    nsram_wen_0 <= nnsram_wen_0;
    nsram_wen_1 <= nnsram_wen_1;
    nsram_wen_2 <= nnsram_wen_2;
    nsram_wen_3 <= nnsram_wen_3;
    if(state!=CONV2)
    begin // state==CONV || state==CONV3
      sram_wen_b0 <= nsram_wen_0;
      sram_wen_b1 <= nsram_wen_1;
      sram_wen_b2 <= nsram_wen_2;
      sram_wen_b3 <= nsram_wen_3;
    end
    else
    begin
      sram_wen_b0 <= 1;
      sram_wen_b1 <= 1;
      sram_wen_b2 <= 1;
      sram_wen_b3 <= 1;
    end

    if(state==CONV2)
    begin
      sram_wen_a0 <= nsram_wen_0;
      sram_wen_a1 <= nsram_wen_1;
      sram_wen_a2 <= nsram_wen_2;
      sram_wen_a3 <= nsram_wen_3;
    end
    else
    begin
      sram_wen_a0 <= 1;
      sram_wen_a1 <= 1;
      sram_wen_a2 <= 1;
      sram_wen_a3 <= 1;
    end
  end

  // ===== SRAM_A raddr & SRAM_B_raddr ===== //
  reg [5:0] sram_raddr_0, sram_raddr_1, sram_raddr_2, sram_raddr_3;
  always@*
  begin
    {sram_raddr_0, sram_raddr_1, sram_raddr_2, sram_raddr_3} = 4'b0000;
    case(nnheight)
      0:
      begin
        case(nnwidth)
          0:
          begin
            sram_raddr_0 = 0;
            sram_raddr_1 = 0;
            sram_raddr_2 = 0;
            sram_raddr_3 = 0;
          end
          1:
          begin
            sram_raddr_0 = 1;
            sram_raddr_1 = 0;
            sram_raddr_2 = 1;
            sram_raddr_3 = 0;
          end
          2:
          begin
            sram_raddr_0 = 1;
            sram_raddr_1 = 1;
            sram_raddr_2 = 1;
            sram_raddr_3 = 1;
          end
          3:
          begin
            sram_raddr_0 = 2;
            sram_raddr_1 = 1;
            sram_raddr_2 = 2;
            sram_raddr_3 = 1;
          end
          4:
          begin
            sram_raddr_0 = 2;
            sram_raddr_1 = 2;
            sram_raddr_2 = 2;
            sram_raddr_3 = 2;
          end
          5:
          begin
            sram_raddr_0 = 3;
            sram_raddr_1 = 2;
            sram_raddr_2 = 3;
            sram_raddr_3 = 2;
          end
        endcase
      end

      1:
      begin
        case(nnwidth)
          0:
          begin
            sram_raddr_0 = 6;
            sram_raddr_1 = 6;
            sram_raddr_2 = 0;
            sram_raddr_3 = 0;
          end
          1:
          begin
            sram_raddr_0 = 7;
            sram_raddr_1 = 6;
            sram_raddr_2 = 1;
            sram_raddr_3 = 0;
          end
          2:
          begin
            sram_raddr_0 = 7;
            sram_raddr_1 = 7;
            sram_raddr_2 = 1;
            sram_raddr_3 = 1;
          end
          3:
          begin
            sram_raddr_0 = 8;
            sram_raddr_1 = 7;
            sram_raddr_2 = 2;
            sram_raddr_3 = 1;
          end
          4:
          begin
            sram_raddr_0 = 8;
            sram_raddr_1 = 8;
            sram_raddr_2 = 2;
            sram_raddr_3 = 2;
          end
          5:
          begin
            sram_raddr_0 = 9;
            sram_raddr_1 = 8;
            sram_raddr_2 = 3;
            sram_raddr_3 = 2;
          end
        endcase
      end

      2:
      begin
        case(nnwidth)
          0:
          begin
            sram_raddr_0 = 0+6;
            sram_raddr_1 = 0+6;
            sram_raddr_2 = 0+6;
            sram_raddr_3 = 0+6;
          end
          1:
          begin
            sram_raddr_0 = 1+6;
            sram_raddr_1 = 0+6;
            sram_raddr_2 = 1+6;
            sram_raddr_3 = 0+6;
          end
          2:
          begin
            sram_raddr_0 = 1+6;
            sram_raddr_1 = 1+6;
            sram_raddr_2 = 1+6;
            sram_raddr_3 = 1+6;
          end
          3:
          begin
            sram_raddr_0 = 2+6;
            sram_raddr_1 = 1+6;
            sram_raddr_2 = 2+6;
            sram_raddr_3 = 1+6;
          end
          4:
          begin
            sram_raddr_0 = 2+6;
            sram_raddr_1 = 2+6;
            sram_raddr_2 = 2+6;
            sram_raddr_3 = 2+6;
          end
          5:
          begin
            sram_raddr_0 = 3+6;
            sram_raddr_1 = 2+6;
            sram_raddr_2 = 3+6;
            sram_raddr_3 = 2+6;
          end
        endcase
      end

      3:
      begin
        case(nnwidth)
          0:
          begin
            sram_raddr_0 = 6+6;
            sram_raddr_1 = 6+6;
            sram_raddr_2 = 0+6;
            sram_raddr_3 = 0+6;
          end
          1:
          begin
            sram_raddr_0 = 7+6;
            sram_raddr_1 = 6+6;
            sram_raddr_2 = 1+6;
            sram_raddr_3 = 0+6;
          end
          2:
          begin
            sram_raddr_0 = 7+6;
            sram_raddr_1 = 7+6;
            sram_raddr_2 = 1+6;
            sram_raddr_3 = 1+6;
          end
          3:
          begin
            sram_raddr_0 = 8+6;
            sram_raddr_1 = 7+6;
            sram_raddr_2 = 2+6;
            sram_raddr_3 = 1+6;
          end
          4:
          begin
            sram_raddr_0 = 8+6;
            sram_raddr_1 = 8+6;
            sram_raddr_2 = 2+6;
            sram_raddr_3 = 2+6;
          end
          5:
          begin
            sram_raddr_0 = 9+6;
            sram_raddr_1 = 8+6;
            sram_raddr_2 = 3+6;
            sram_raddr_3 = 2+6;
          end
        endcase
      end

      4:
      begin
        case(nnwidth)
          0:
          begin
            sram_raddr_0 = 0+6*2;
            sram_raddr_1 = 0+6*2;
            sram_raddr_2 = 0+6*2;
            sram_raddr_3 = 0+6*2;
          end
          1:
          begin
            sram_raddr_0 = 1+6*2;
            sram_raddr_1 = 0+6*2;
            sram_raddr_2 = 1+6*2;
            sram_raddr_3 = 0+6*2;
          end
          2:
          begin
            sram_raddr_0 = 1+6*2;
            sram_raddr_1 = 1+6*2;
            sram_raddr_2 = 1+6*2;
            sram_raddr_3 = 1+6*2;
          end
          3:
          begin
            sram_raddr_0 = 2+6*2;
            sram_raddr_1 = 1+6*2;
            sram_raddr_2 = 2+6*2;
            sram_raddr_3 = 1+6*2;
          end
          4:
          begin
            sram_raddr_0 = 2+6*2;
            sram_raddr_1 = 2+6*2;
            sram_raddr_2 = 2+6*2;
            sram_raddr_3 = 2+6*2;
          end
          5:
          begin
            sram_raddr_0 = 3+6*2;
            sram_raddr_1 = 2+6*2;
            sram_raddr_2 = 3+6*2;
            sram_raddr_3 = 2+6*2;
          end
        endcase
      end

      5:
      begin
        case(nnwidth)
          0:
          begin
            sram_raddr_0 = 6+6*2;
            sram_raddr_1 = 6+6*2;
            sram_raddr_2 = 0+6*2;
            sram_raddr_3 = 0+6*2;
          end
          1:
          begin
            sram_raddr_0 = 7+6*2;
            sram_raddr_1 = 6+6*2;
            sram_raddr_2 = 1+6*2;
            sram_raddr_3 = 0+6*2;
          end
          2:
          begin
            sram_raddr_0 = 7+6*2;
            sram_raddr_1 = 7+6*2;
            sram_raddr_2 = 1+6*2;
            sram_raddr_3 = 1+6*2;
          end
          3:
          begin
            sram_raddr_0 = 8+6*2;
            sram_raddr_1 = 7+6*2;
            sram_raddr_2 = 2+6*2;
            sram_raddr_3 = 1+6*2;
          end
          4:
          begin
            sram_raddr_0 = 8+6*2;
            sram_raddr_1 = 8+6*2;
            sram_raddr_2 = 2+6*2;
            sram_raddr_3 = 2+6*2;
          end
          5:
          begin
            sram_raddr_0 = 9+6*2;
            sram_raddr_1 = 8+6*2;
            sram_raddr_2 = 3+6*2;
            sram_raddr_3 = 2+6*2;
          end
        endcase
      end
    endcase
  end

  always@*
  begin
    sram_raddr_a0 = sram_raddr_0;
    sram_raddr_a1 = sram_raddr_1;
    sram_raddr_a2 = sram_raddr_2;
    sram_raddr_a3 = sram_raddr_3;
    sram_raddr_b0 = sram_raddr_0;
    sram_raddr_b1 = sram_raddr_1;
    sram_raddr_b2 = sram_raddr_2;
    sram_raddr_b3 = sram_raddr_3;
    if(state==CONV3)
    begin
      if(conv3_ch_cnt>9)
      begin
        sram_raddr_a0 = sram_raddr_0;
        sram_raddr_a1 = sram_raddr_1;
        sram_raddr_a2 = sram_raddr_2;
        sram_raddr_a3 = sram_raddr_3;
      end
      else if(conv3_ch_cnt>5)
      begin
        sram_raddr_a0 = sram_raddr_0 + 18;
        sram_raddr_a1 = sram_raddr_1 + 18;
        sram_raddr_a2 = sram_raddr_2 + 18;
        sram_raddr_a3 = sram_raddr_3 + 18;
      end
      else if(conv3_ch_cnt>1)
      begin
        sram_raddr_a0 = sram_raddr_0 + 3;
        sram_raddr_a1 = sram_raddr_1 + 3;
        sram_raddr_a2 = sram_raddr_2 + 3;
        sram_raddr_a3 = sram_raddr_3 + 3;
      end
    end
  end

  // ===== store convolution region in to input feature map ===== //
  reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] nsram_rdata_0, nsram_rdata_1, nsram_rdata_2, nsram_rdata_3;
  reg signed [4*4*12-1:0] ifeature_map;   // ***** this can do pipeline ***** //
  always@*
  begin
    if(state==CONV || state==CONV3)
    begin
      nsram_rdata_0 = nsram_rdata_a0;
      nsram_rdata_1 = nsram_rdata_a1;
      nsram_rdata_2 = nsram_rdata_a2;
      nsram_rdata_3 = nsram_rdata_a3;
    end
    else
    begin// state == CONV2
      nsram_rdata_0 = nsram_rdata_b0;
      nsram_rdata_1 = nsram_rdata_b1;
      nsram_rdata_2 = nsram_rdata_b2;
      nsram_rdata_3 = nsram_rdata_b3;
    end
  end

  always@*
  begin
    ifeature_map = 0;
    case(weight_cnt[1:0]) // synopsys parallel_case
      2'b00: // 0 4 8 12 16 20 24 28 ....
      begin
        case({height[0],width[0]}) // synopsys parallel_case
          2'b00:
            ifeature_map = {nsram_rdata_0[191:180], nsram_rdata_0[179:168], nsram_rdata_1[191:180], nsram_rdata_1[179:168], nsram_rdata_0[167:156], nsram_rdata_0[155:144], nsram_rdata_1[167:156], nsram_rdata_1[155:144],
                            nsram_rdata_2[191:180], nsram_rdata_2[179:168], nsram_rdata_3[191:180], nsram_rdata_3[179:168], nsram_rdata_2[167:156], nsram_rdata_2[155:144], nsram_rdata_3[167:156], nsram_rdata_3[155:144]};
          2'b01:
            ifeature_map = {nsram_rdata_1[191:180], nsram_rdata_1[179:168], nsram_rdata_0[191:180], nsram_rdata_0[179:168], nsram_rdata_1[167:156], nsram_rdata_1[155:144], nsram_rdata_0[167:156], nsram_rdata_0[155:144],
                            nsram_rdata_3[191:180], nsram_rdata_3[179:168], nsram_rdata_2[191:180], nsram_rdata_2[179:168], nsram_rdata_3[167:156], nsram_rdata_3[155:144], nsram_rdata_2[167:156], nsram_rdata_2[155:144]};
          2'b10:
            ifeature_map = {nsram_rdata_2[191:180], nsram_rdata_2[179:168], nsram_rdata_3[191:180], nsram_rdata_3[179:168], nsram_rdata_2[167:156], nsram_rdata_2[155:144], nsram_rdata_3[167:156], nsram_rdata_3[155:144],
                            nsram_rdata_0[191:180], nsram_rdata_0[179:168], nsram_rdata_1[191:180], nsram_rdata_1[179:168], nsram_rdata_0[167:156], nsram_rdata_0[155:144], nsram_rdata_1[167:156], nsram_rdata_1[155:144]};
          2'b11:
            ifeature_map = {nsram_rdata_3[191:180], nsram_rdata_3[179:168], nsram_rdata_2[191:180], nsram_rdata_2[179:168], nsram_rdata_3[167:156], nsram_rdata_3[155:144], nsram_rdata_2[167:156], nsram_rdata_2[155:144],
                            nsram_rdata_1[191:180], nsram_rdata_1[179:168], nsram_rdata_0[191:180], nsram_rdata_0[179:168], nsram_rdata_1[167:156], nsram_rdata_1[155:144], nsram_rdata_0[167:156], nsram_rdata_0[155:144]};
        endcase
      end

      2'b01: // 1 5 9 13 17 21 25 29 ....
      begin
        case({height[0],width[0]}) // synopsys parallel_case
          2'b00:
            ifeature_map = {nsram_rdata_0[143:132], nsram_rdata_0[131:120], nsram_rdata_1[143:132], nsram_rdata_1[131:120], nsram_rdata_0[119:108], nsram_rdata_0[107:96], nsram_rdata_1[119:108], nsram_rdata_1[107:96],
                            nsram_rdata_2[143:132], nsram_rdata_2[131:120], nsram_rdata_3[143:132], nsram_rdata_3[131:120], nsram_rdata_2[119:108], nsram_rdata_2[107:96], nsram_rdata_3[119:108], nsram_rdata_3[107:96]};
          2'b01:
            ifeature_map = {nsram_rdata_1[143:132], nsram_rdata_1[131:120], nsram_rdata_0[143:132], nsram_rdata_0[131:120], nsram_rdata_1[119:108], nsram_rdata_1[107:96], nsram_rdata_0[119:108], nsram_rdata_0[107:96],
                            nsram_rdata_3[143:132], nsram_rdata_3[131:120], nsram_rdata_2[143:132], nsram_rdata_2[131:120], nsram_rdata_3[119:108], nsram_rdata_3[107:96], nsram_rdata_2[119:108], nsram_rdata_2[107:96]};
          2'b10:
            ifeature_map = {nsram_rdata_2[143:132], nsram_rdata_2[131:120], nsram_rdata_3[143:132], nsram_rdata_3[131:120], nsram_rdata_2[119:108], nsram_rdata_2[107:96], nsram_rdata_3[119:108], nsram_rdata_3[107:96],
                            nsram_rdata_0[143:132], nsram_rdata_0[131:120], nsram_rdata_1[143:132], nsram_rdata_1[131:120], nsram_rdata_0[119:108], nsram_rdata_0[107:96], nsram_rdata_1[119:108], nsram_rdata_1[107:96]};
          2'b11:
            ifeature_map = {nsram_rdata_3[143:132], nsram_rdata_3[131:120], nsram_rdata_2[143:132], nsram_rdata_2[131:120], nsram_rdata_3[119:108], nsram_rdata_3[107:96], nsram_rdata_2[119:108], nsram_rdata_2[107:96],
                            nsram_rdata_1[143:132], nsram_rdata_1[131:120], nsram_rdata_0[143:132], nsram_rdata_0[131:120], nsram_rdata_1[119:108], nsram_rdata_1[107:96], nsram_rdata_0[119:108], nsram_rdata_0[107:96]};
        endcase
      end

      2'b10: // 2 6 10 14 18 22 26 30 ....
      begin
        case({height[0],width[0]}) // synopsys parallel_case
          2'b00:
            ifeature_map = {nsram_rdata_0[95:84], nsram_rdata_0[83:72], nsram_rdata_1[95:84], nsram_rdata_1[83:72], nsram_rdata_0[71:60], nsram_rdata_0[59:48], nsram_rdata_1[71:60], nsram_rdata_1[59:48],
                            nsram_rdata_2[95:84], nsram_rdata_2[83:72], nsram_rdata_3[95:84], nsram_rdata_3[83:72], nsram_rdata_2[71:60], nsram_rdata_2[59:48], nsram_rdata_3[71:60], nsram_rdata_3[59:48]};
          2'b01:
            ifeature_map = {nsram_rdata_1[95:84], nsram_rdata_1[83:72], nsram_rdata_0[95:84], nsram_rdata_0[83:72], nsram_rdata_1[71:60], nsram_rdata_1[59:48], nsram_rdata_0[71:60], nsram_rdata_0[59:48],
                            nsram_rdata_3[95:84], nsram_rdata_3[83:72], nsram_rdata_2[95:84], nsram_rdata_2[83:72], nsram_rdata_3[71:60], nsram_rdata_3[59:48], nsram_rdata_2[71:60], nsram_rdata_2[59:48]};
          2'b10:
            ifeature_map = {nsram_rdata_2[95:84], nsram_rdata_2[83:72], nsram_rdata_3[95:84], nsram_rdata_3[83:72], nsram_rdata_2[71:60], nsram_rdata_2[59:48], nsram_rdata_3[71:60], nsram_rdata_3[59:48],
                            nsram_rdata_0[95:84], nsram_rdata_0[83:72], nsram_rdata_1[95:84], nsram_rdata_1[83:72], nsram_rdata_0[71:60], nsram_rdata_0[59:48], nsram_rdata_1[71:60], nsram_rdata_1[59:48]};
          2'b11:
            ifeature_map = {nsram_rdata_3[95:84], nsram_rdata_3[83:72], nsram_rdata_2[95:84], nsram_rdata_2[83:72], nsram_rdata_3[71:60], nsram_rdata_3[59:48], nsram_rdata_2[71:60], nsram_rdata_2[59:48],
                            nsram_rdata_1[95:84], nsram_rdata_1[83:72], nsram_rdata_0[95:84], nsram_rdata_0[83:72], nsram_rdata_1[71:60], nsram_rdata_1[59:48], nsram_rdata_0[71:60], nsram_rdata_0[59:48]};
        endcase
      end

      2'b11: // 3 7 11 15 19 23 27 31 ....
      begin
        case({height[0],width[0]}) // synopsys parallel_case

          2'b00:
            ifeature_map = {nsram_rdata_0[47:36], nsram_rdata_0[35:24], nsram_rdata_1[47:36], nsram_rdata_1[35:24], nsram_rdata_0[23:12], nsram_rdata_0[11:0], nsram_rdata_1[23:12], nsram_rdata_1[11:0],
                            nsram_rdata_2[47:36], nsram_rdata_2[35:24], nsram_rdata_3[47:36], nsram_rdata_3[35:24], nsram_rdata_2[23:12], nsram_rdata_2[11:0], nsram_rdata_3[23:12], nsram_rdata_3[11:0]};
          2'b01:
            ifeature_map = {nsram_rdata_1[47:36], nsram_rdata_1[35:24], nsram_rdata_0[47:36], nsram_rdata_0[35:24], nsram_rdata_1[23:12], nsram_rdata_1[11:0], nsram_rdata_0[23:12], nsram_rdata_0[11:0],
                            nsram_rdata_3[47:36], nsram_rdata_3[35:24], nsram_rdata_2[47:36], nsram_rdata_2[35:24], nsram_rdata_3[23:12], nsram_rdata_3[11:0], nsram_rdata_2[23:12], nsram_rdata_2[11:0]};
          2'b10:
            ifeature_map = {nsram_rdata_2[47:36], nsram_rdata_2[35:24], nsram_rdata_3[47:36], nsram_rdata_3[35:24], nsram_rdata_2[23:12], nsram_rdata_2[11:0], nsram_rdata_3[23:12], nsram_rdata_3[11:0],
                            nsram_rdata_0[47:36], nsram_rdata_0[35:24], nsram_rdata_1[47:36], nsram_rdata_1[35:24], nsram_rdata_0[23:12], nsram_rdata_0[11:0], nsram_rdata_1[23:12], nsram_rdata_1[11:0]};
          2'b11:
            ifeature_map = {nsram_rdata_3[47:36], nsram_rdata_3[35:24], nsram_rdata_2[47:36], nsram_rdata_2[35:24], nsram_rdata_3[23:12], nsram_rdata_3[11:0], nsram_rdata_2[23:12], nsram_rdata_2[11:0],
                            nsram_rdata_1[47:36], nsram_rdata_1[35:24], nsram_rdata_0[47:36], nsram_rdata_0[35:24], nsram_rdata_1[23:12], nsram_rdata_1[11:0], nsram_rdata_0[23:12], nsram_rdata_0[11:0]};
        endcase
      end
    endcase
  end

  // ==== convolution ===== //
  reg signed [20:0] conv_result0[0:2];
  reg signed [20:0] nconv_result0[0:2];
  reg signed [20:0] conv_result1[0:2];
  reg signed [20:0] nconv_result1[0:2];
  reg signed [20:0] conv_result2[0:2];
  reg signed [20:0] nconv_result2[0:2];
  reg signed [20:0] conv_result3[0:2];
  reg signed [20:0] nconv_result3[0:2];
  reg signed [20:0] conv_out0[0:2];
  reg signed [20:0] conv_out1[0:2];
  reg signed [20:0] conv_out2[0:2];
  reg signed [20:0] conv_out3[0:2];

  always@*
  begin																								 // ***** critical path is adder , here can do pipeline ***** //
    nconv_result3[0] = conv_result3[0] +
                 ( $signed(ifeature_map[191:180])*$signed(nsram_rdata_weight[71:64]) + $signed(ifeature_map[179:168])*$signed(nsram_rdata_weight[63:56]) + $signed(ifeature_map[167:156])*$signed(nsram_rdata_weight[55:48]));
    nconv_result3[1] = conv_result3[1] +
                 ( $signed(ifeature_map[143:132])*$signed(nsram_rdata_weight[47:40]) + $signed(ifeature_map[131:120])*$signed(nsram_rdata_weight[39:32]) + $signed(ifeature_map[119:108])*$signed(nsram_rdata_weight[31:24]));
    nconv_result3[2] = conv_result3[2] +
                 ( $signed(ifeature_map[95:84])  *$signed(nsram_rdata_weight[23:16]) + $signed(ifeature_map[83:72])  *$signed(nsram_rdata_weight[15:8])  + $signed(ifeature_map[71:60])  *$signed(nsram_rdata_weight[7:0]));


    nconv_result2[0] = conv_result2[0] +
                 ( $signed(ifeature_map[179:168])*$signed(nsram_rdata_weight[71:64]) + $signed(ifeature_map[167:156])*$signed(nsram_rdata_weight[63:56]) + $signed(ifeature_map[155:144])*$signed(nsram_rdata_weight[55:48]));
    nconv_result2[1] = conv_result2[1] +
                 ( $signed(ifeature_map[131:120])*$signed(nsram_rdata_weight[47:40]) + $signed(ifeature_map[119:108])*$signed(nsram_rdata_weight[39:32]) + $signed(ifeature_map[107:96]) *$signed(nsram_rdata_weight[31:24]));
    nconv_result2[2] = conv_result2[2] +
                 ( $signed(ifeature_map[83:72])  *$signed(nsram_rdata_weight[23:16]) + $signed(ifeature_map[71:60])  *$signed(nsram_rdata_weight[15:8])  + $signed(ifeature_map[59:48])  *$signed(nsram_rdata_weight[7:0]));


    nconv_result1[0] = conv_result1[0] +
                 ( $signed(ifeature_map[143:132])*$signed(nsram_rdata_weight[71:64]) + $signed(ifeature_map[131:120])*$signed(nsram_rdata_weight[63:56]) + $signed(ifeature_map[119:108])*$signed(nsram_rdata_weight[55:48]));
    nconv_result1[1] = conv_result1[1] +
                 ( $signed(ifeature_map[95:84])  *$signed(nsram_rdata_weight[47:40]) + $signed(ifeature_map[83:72])  *$signed(nsram_rdata_weight[39:32]) + $signed(ifeature_map[71:60])  *$signed(nsram_rdata_weight[31:24]));
    nconv_result1[2] = conv_result1[2] +
                 (	$signed(ifeature_map[47:36])  *$signed(nsram_rdata_weight[23:16]) + $signed(ifeature_map[35:24])  *$signed(nsram_rdata_weight[15:8])  + $signed(ifeature_map[23:12])  *$signed(nsram_rdata_weight[7:0]));


    nconv_result0[0] = conv_result0[0] +
                 ( $signed(ifeature_map[131:120])*$signed(nsram_rdata_weight[71:64]) + $signed(ifeature_map[119:108])*$signed(nsram_rdata_weight[63:56]) + $signed(ifeature_map[107:96]) *$signed(nsram_rdata_weight[55:48]));
    nconv_result0[1] = conv_result0[1] +
                 (	$signed(ifeature_map[83:72])  *$signed(nsram_rdata_weight[47:40]) + $signed(ifeature_map[71:60])  *$signed(nsram_rdata_weight[39:32]) + $signed(ifeature_map[59:48])  *$signed(nsram_rdata_weight[31:24]));
    nconv_result0[2] = conv_result0[2] +
                 (	$signed(ifeature_map[35:24])   *$signed(nsram_rdata_weight[23:16]) + $signed(ifeature_map[23:12])  *$signed(nsram_rdata_weight[15:8])  + $signed(ifeature_map[11:0])   *$signed(nsram_rdata_weight[7:0]));
  end

  always@(posedge clk)
  begin
    if(~rst_n || done || done2)
    begin
      for(i=0; i<3; i=i+1)
      begin
        conv_result0[i] <= 0;
        conv_result1[i] <= 0;
        conv_result2[i] <= 0;
        conv_result3[i] <= 0;
      end
    end
    else if(state==CONV3 && conv3_ch_cnt==11)
    begin
      for(i=0; i<3; i=i+1)
      begin
        conv_result0[i] <= 0;
        conv_result1[i] <= 0;
        conv_result2[i] <= 0;
        conv_result3[i] <= 0;
      end
    end
    else if((state==CONV || state==CONV2) && (weight_cnt+1)%4==0)
    begin
      for(i=0; i<3; i=i+1)
      begin
        conv_result0[i] <= 0;
        conv_result1[i] <= 0;
        conv_result2[i] <= 0;
        conv_result3[i] <= 0;
      end
    end
    else if(load_enable)
    begin
      for(i=0; i<3; i=i+1)
      begin
        conv_result0[i] <= nconv_result0[i];
        conv_result1[i] <= nconv_result1[i];
        conv_result2[i] <= nconv_result2[i];
        conv_result3[i] <= nconv_result3[i];
      end
    end

    for(i=0; i<3; i=i+1)
    begin
      conv_out0[i] <= nconv_result0[i];
      conv_out1[i] <= nconv_result1[i];
      conv_out2[i] <= nconv_result2[i];
      conv_out3[i] <= nconv_result3[i];
    end
  end


  // ===== add bias ===== //
  reg signed [20:0] naccumulated_out[0:3];
  reg signed [20:0] q_out[0:3];
  reg signed [20:0] q_out_tmp[0:3];
  reg signed [20:0] npooling_avg;
  reg signed [20:0] pooling_avg;
  reg signed [20:0] pooling_out;
  reg signed [20:0] pooling_out_tmp;
  always@*
  begin
    if( (conv_out3[0] + conv_out3[1] + conv_out3[2] + (nsram_rdata_bias<<8))>0 )
      naccumulated_out[3] = conv_out3[0] + conv_out3[1] + conv_out3[2] + (nsram_rdata_bias<<8);
    else
      naccumulated_out[3] = 0;
    if( (conv_out2[0] + conv_out2[1] + conv_out2[2] + (nsram_rdata_bias<<8))>0 )
      naccumulated_out[2] = conv_out2[0] + conv_out2[1] + conv_out2[2] + (nsram_rdata_bias<<8);
    else
      naccumulated_out[2] = 0;
    if( (conv_out1[0] + conv_out1[1] + conv_out1[2] + (nsram_rdata_bias<<8))>0 )
      naccumulated_out[1] = conv_out1[0] + conv_out1[1] + conv_out1[2] + (nsram_rdata_bias<<8);
    else
      naccumulated_out[1] = 0;
    if( (conv_out0[0] + conv_out0[1] + conv_out0[2] + (nsram_rdata_bias<<8))>0 )
      naccumulated_out[0] = conv_out0[0] + conv_out0[1] + conv_out0[2] + (nsram_rdata_bias<<8);
    else
      naccumulated_out[0] = 0;

    npooling_avg = (naccumulated_out[3] + naccumulated_out[2] + naccumulated_out[1] + naccumulated_out[0])>>2 ;
  end

  reg signed [20:0] accumulated_out[0:3];
  always@(posedge clk)
  begin
    for(i=0; i<4; i=i+1)
    begin
      accumulated_out[i] <= naccumulated_out[i];
    end
    pooling_avg <= npooling_avg;
  end

  always@*
  begin
    // ===== quantize ===== //
    q_out_tmp[3] = (accumulated_out[3] + 2**6) >>> 7;
    q_out_tmp[2] = (accumulated_out[2] + 2**6) >>> 7;
    q_out_tmp[1] = (accumulated_out[1] + 2**6) >>> 7;
    q_out_tmp[0] = (accumulated_out[0] + 2**6) >>> 7;
    pooling_out_tmp =  (pooling_avg + 2**6) >>> 7 ;
    if(q_out_tmp[0] > 2047)
      q_out[0] = 2047;
    else if(q_out_tmp[0]< -2048)
      q_out[0] = -2048;
    else
      q_out[0] = q_out_tmp[0][11:0] ;

    if(q_out_tmp[1] > 2047)
      q_out[1] = 2047;
    else if(q_out_tmp[1]< -2048)
      q_out[1] = -2048;
    else
      q_out[1] = q_out_tmp[1][11:0] ;

    if(q_out_tmp[2] > 2047)
      q_out[2] = 2047;
    else if(q_out_tmp[2]< -2048)
      q_out[2] = -2048;
    else
      q_out[2] = q_out_tmp[2][11:0] ;

    if(q_out_tmp[3] > 2047)
      q_out[3] = 2047;
    else if(q_out_tmp[3]< -2048)
      q_out[3] = -2048;
    else
      q_out[3] = q_out_tmp[3][11:0] ;


    if(pooling_out_tmp > 2047)
      pooling_out = 2047;
    else if(pooling_out_tmp< -2048)
      pooling_out = -2048;
    else
      pooling_out = pooling_out_tmp[11:0] ;

  end

  // ===== mask & store to SRAM_B ===== //
  always@*
  begin
    sram_wordmask_b = 16'b1111111111111111;
    sram_wdata_b = 0;
    case(weight_cnt)
      // for conv1
      5:
      begin
        sram_wdata_b[191:144] = {q_out[3][11:0], q_out[2][11:0], q_out[1][11:0], q_out[0][11:0]};
        {sram_wordmask_b[15],sram_wordmask_b[14],sram_wordmask_b[13],sram_wordmask_b[12]} = 0;
      end

      9:
      begin
        sram_wdata_b[143:96] = {q_out[3][11:0], q_out[2][11:0], q_out[1][11:0], q_out[0][11:0]};
        {sram_wordmask_b[11],sram_wordmask_b[10],sram_wordmask_b[9],sram_wordmask_b[8]} = 0;
      end

      13:
      begin
        sram_wdata_b[95:48] = {q_out[3][11:0], q_out[2][11:0], q_out[1][11:0], q_out[0][11:0]};
        {sram_wordmask_b[7],sram_wordmask_b[6],sram_wordmask_b[5],sram_wordmask_b[4]} = 0;
      end

      1:
      begin
        sram_wdata_b[47:0] = {q_out[3][11:0], q_out[2][11:0], q_out[1][11:0], q_out[0][11:0]};
        {sram_wordmask_b[3],sram_wordmask_b[2],sram_wordmask_b[1],sram_wordmask_b[0]} = 0;
      end
      // for conv3
      77,125,173,221,269,317,365,413,461,509,557,605:
      begin
        case({height[0],width[0]})
          2'b00:
          begin // (height,width) = (0,0) & (0,2) & (2,0) & (2,2)
            sram_wdata_b[191:180] = pooling_out[11:0];
            sram_wordmask_b[15] = 0;
          end
          2'b01:
          begin // (height,width) = (0,1) & (0,3) & (2,1) & (2,3)
            sram_wdata_b[179:168] = pooling_out[11:0];
            sram_wordmask_b[14] = 0;
          end
          2'b10:
          begin // (height,width) = (1,0) & (1,2) & (3,0) & (3,2)
            sram_wdata_b[167:156] = pooling_out[11:0];
            sram_wordmask_b[13] = 0;
          end
          2'b11:
          begin // (height,width) = (1,1) & (1,3) & (3,1) & (3,3)
            sram_wdata_b[155:144] = pooling_out[11:0];
            sram_wordmask_b[12] = 0;
          end
        endcase
      end
      89,137,185,233,281,329,377,425,473,521,569,617:
      begin
        case({height[0],width[0]})
          2'b00:
          begin // (height,width) = (0,0) & (0,2) & (2,0) & (2,2)
            sram_wdata_b[143:132] = pooling_out[11:0];
            sram_wordmask_b[11] = 0;
          end
          2'b01:
          begin // (height,width) = (0,1) & (0,3) & (2,1) & (2,3)
            sram_wdata_b[131:120] = pooling_out[11:0];
            sram_wordmask_b[10] = 0;
          end
          2'b10:
          begin // (height,width) = (1,0) & (1,2) & (3,0) & (3,2)
            sram_wdata_b[119:108] = pooling_out[11:0];
            sram_wordmask_b[9] = 0;
          end
          2'b11:
          begin // (height,width) = (1,1) & (1,3) & (3,1) & (3,3)
            sram_wdata_b[107:96] = pooling_out[11:0];
            sram_wordmask_b[8] = 0;
          end
        endcase
      end
      101,149,197,245,293,341,389,437,485,533,581,629:
      begin
        case({height[0],width[0]})
          2'b00:
          begin // (height,width) = (0,0) & (0,2) & (2,0) & (2,2)
            sram_wdata_b[95:84] = pooling_out[11:0];
            sram_wordmask_b[7] = 0;
          end
          2'b01:
          begin // (height,width) = (0,1) & (0,3) & (2,1) & (2,3)
            sram_wdata_b[83:72] = pooling_out[11:0];
            sram_wordmask_b[6] = 0;
          end
          2'b10:
          begin // (height,width) = (1,0) & (1,2) & (3,0) & (3,2)
            sram_wdata_b[71:60] = pooling_out[11:0];
            sram_wordmask_b[5] = 0;
          end
          2'b11:
          begin // (height,width) = (1,1) & (1,3) & (3,1) & (3,3)
            sram_wdata_b[59:48] = pooling_out[11:0];
            sram_wordmask_b[4] = 0;
          end
        endcase
      end
      113,161,209,257,305,353,401,449,497,545,593:
      begin
        case({height[0],width[0]})
          2'b00:
          begin // (height,width) = (0,0) & (0,2) & (2,0) & (2,2)
            sram_wdata_b[47:36] = pooling_out[11:0];
            sram_wordmask_b[3] = 0;
          end
          2'b01:
          begin // (height,width) = (0,1) & (0,3) & (2,1) & (2,3)
            sram_wdata_b[35:24] = pooling_out[11:0];
            sram_wordmask_b[2] = 0;
          end
          2'b10:
          begin // (height,width) = (1,0) & (1,2) & (3,0) & (3,2)
            sram_wdata_b[23:12] = pooling_out[11:0];
            sram_wordmask_b[1] = 0;
          end
          2'b11:
          begin // (height,width) = (1,1) & (1,3) & (3,1) & (3,3)
            sram_wdata_b[11:0] = pooling_out[11:0];
            sram_wordmask_b[0] = 0;
          end
        endcase
      end
      65:
      begin
        case(height)
          0:
          case(width)
            1,3:
            begin
              sram_wdata_b[47:36] = pooling_out[11:0];
              sram_wordmask_b[3] = 0;
            end
            2:
            begin
              sram_wdata_b[35:24] = pooling_out[11:0];
              sram_wordmask_b[2] = 0;
            end
          endcase
          1:
          case(width)
            0:
            begin
              sram_wdata_b[35:24] = pooling_out[11:0];
              sram_wordmask_b[2] = 0;
            end
            1,3:
            begin
              sram_wdata_b[23:12] = pooling_out[11:0];
              sram_wordmask_b[1] = 0;
            end
            2:
            begin
              sram_wdata_b[11:0] = pooling_out[11:0];
              sram_wordmask_b[0] = 0;
            end
          endcase
          2:
          case(width)
            0:
            begin
              sram_wdata_b[11:0] = pooling_out[11:0];
              sram_wordmask_b[0] = 0;
            end
            1,3:
            begin
              sram_wdata_b[47:36] = pooling_out[11:0];
              sram_wordmask_b[3] = 0;
            end
            2:
            begin
              sram_wdata_b[35:24] = pooling_out[11:0];
              sram_wordmask_b[2] = 0;
            end
          endcase
          3:
          case(width)
            0:
            begin
              sram_wdata_b[35:24] = pooling_out[11:0];
              sram_wordmask_b[2] = 0;
            end
            1,3:
            begin
              sram_wdata_b[23:12] = pooling_out[11:0];
              sram_wordmask_b[1] = 0;
            end
            2:
            begin
              sram_wdata_b[11:0] = pooling_out[11:0];
              sram_wordmask_b[0] = 0;
            end
          endcase
          4:
          begin
            sram_wdata_b[11:0] = pooling_out[11:0];
            sram_wordmask_b[0] = 0;
          end
        endcase
      end
    endcase
  end

  // ===== mask & store to SRAM_A ===== //
  always@*
  begin
    sram_wordmask_a = 16'b1111111111111111;
    sram_wdata_a = 0;
    case(weight_cnt)
      21,37,53:
      begin
        sram_wdata_a[191:144] = {q_out[3][11:0], q_out[2][11:0], q_out[1][11:0], q_out[0][11:0]};
        {sram_wordmask_a[15],sram_wordmask_a[14],sram_wordmask_a[13],sram_wordmask_a[12]} = 0;
      end

      25,41,57:
      begin
        sram_wdata_a[143:96] = {q_out[3][11:0], q_out[2][11:0], q_out[1][11:0], q_out[0][11:0]};
        {sram_wordmask_a[11],sram_wordmask_a[10],sram_wordmask_a[9],sram_wordmask_a[8]} = 0;
      end

      29,45,61:
      begin
        sram_wdata_a[95:48] = {q_out[3][11:0], q_out[2][11:0], q_out[1][11:0], q_out[0][11:0]};
        {sram_wordmask_a[7],sram_wordmask_a[6],sram_wordmask_a[5],sram_wordmask_a[4]} = 0;
      end

      17,33,49:
      begin
        sram_wdata_a[47:0] = {q_out[3][11:0], q_out[2][11:0], q_out[1][11:0], q_out[0][11:0]};
        {sram_wordmask_a[3],sram_wordmask_a[2],sram_wordmask_a[1],sram_wordmask_a[0]} = 0;
      end
    endcase
  end

  // =====because the pipeline delay, so the done signal should be delay=====//
  always@(posedge clk)
  begin
    nconv_done <= nnconv_done;
    conv_done <= nconv_done;
  end

endmodule

