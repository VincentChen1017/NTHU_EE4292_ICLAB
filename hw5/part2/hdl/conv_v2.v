module conv1 #(
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
    // read data from parameter SRAM
    input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_weight,
    input [BIAS_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_bias,
    // read address to SRAM group A
    output reg [5:0] sram_raddr_a0,
    output reg [5:0] sram_raddr_a1,
    output reg [5:0] sram_raddr_a2,
    output reg [5:0] sram_raddr_a3,
    // read address to parameter SRAM
    output reg [9:0] sram_raddr_weight,
    output reg [5:0] sram_raddr_bias,
    // write enable for SRAM groups A & B
    output reg sram_wen_b0,
    output reg sram_wen_b1,
    output reg sram_wen_b2,
    output reg sram_wen_b3,
    // word mask for SRAM groups A & B
    output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b,
    // write addrress to SRAM groups A & B
    output reg [5:0] sram_waddr_b,
    // write data to SRAM groups A & B
    output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b
  );

  localparam IDLE = 0,
             CONV	= 1,
             DONE = 2;
	integer i;
  reg [1:0]state, nstate;
  reg conv_enable;
  reg conv_done, nconv_done, nnconv_done;

  // ===== FSM ===== //
  always@*
  begin
    conv_enable = 0;
    valid = 0;
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
        valid = 1;
        nstate = DONE;
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
  reg signed[WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] nsram_rdata_weight;
  reg signed[BIAS_PER_ADDR*BW_PER_PARAM-1:0] nsram_rdata_bias;

  always@(posedge clk)
  begin
    nsram_rdata_a0 <= sram_rdata_a0;
    nsram_rdata_a1 <= sram_rdata_a1;
    nsram_rdata_a2 <= sram_rdata_a2;
    nsram_rdata_a3 <= sram_rdata_a3;
    nsram_rdata_weight <= sram_rdata_weight;
    nsram_rdata_bias <= sram_rdata_bias;
  end

  // ===== weight and bias addr ===== //
  always@(posedge clk)
    if(~rst_n)
      sram_raddr_weight <= 0;
    else if(sram_raddr_weight==15)
      sram_raddr_weight <= 0;
    else if(conv_enable)
      sram_raddr_weight <= sram_raddr_weight + 1;

  always@(posedge clk)
    if(sram_raddr_weight==2)
      sram_raddr_bias <= 0;
    else if(sram_raddr_weight==6)
      sram_raddr_bias <= 1;
    else if(sram_raddr_weight==10)
      sram_raddr_bias <= 2;
    else if(sram_raddr_weight==14)
      sram_raddr_bias <= 3;

  reg load_enable, nload_enable;
  always@(posedge clk)
		if(conv_enable)
      nload_enable <= 1;
    else
      nload_enable <= 0;

  always@(posedge clk)
    load_enable <= nload_enable; // because of the input dff delay, weight_cnt must be delay two cycle to start to count.

  reg [3:0] weight_cnt;
  always@(posedge clk)
    if(~rst_n)
      weight_cnt <= 0;
    else if(weight_cnt==15)
      weight_cnt <= 0;
    else if(load_enable)
      weight_cnt <= weight_cnt + 1;

  // ===== feature_map position ===== //
  reg [2:0] height, nheight, width, nwidth, nnheight, nnwidth;
  always@(posedge clk)
    if(~rst_n)
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
    else
      nnconv_done = 0;

  end


  // ===== SRAM_B waddr ===== //
  reg [5:0] nsram_waddr_b;
  always@(posedge clk)
    if(~rst_n)
      sram_waddr_b <= 0;
    else
      sram_waddr_b <= nsram_waddr_b;

  always@*
  begin
    nsram_waddr_b = sram_waddr_b;
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
  end

  // ===== SRAM_B en ===== //
  reg height_mod, width_mod; // To decide which the bank the input should store into.
  reg nsram_wen_b0, nsram_wen_b1, nsram_wen_b2, nsram_wen_b3;
  reg nnsram_wen_b0, nnsram_wen_b1, nnsram_wen_b2, nnsram_wen_b3;
  always@*
  begin
    height_mod = height[0];
    width_mod = width[0];
		{nnsram_wen_b0, nnsram_wen_b1, nnsram_wen_b2, nnsram_wen_b3} = 4'b1111;
		case((weight_cnt+1)%4)
			0:begin
		    if(~height_mod)
		      if(~width_mod)
		        nnsram_wen_b0 = 0;
		      else
		        nnsram_wen_b1 = 0;
		    else
		      if(~width_mod)
		        nnsram_wen_b2 = 0;
		      else
		        nnsram_wen_b3 = 0;
			end
		endcase
	end

  always@(posedge clk)
    begin
      sram_wen_b0 <= nsram_wen_b0;
      sram_wen_b1 <= nsram_wen_b1;
      sram_wen_b2 <= nsram_wen_b2;
      sram_wen_b3 <= nsram_wen_b3;

      nsram_wen_b0 <= nnsram_wen_b0;
      nsram_wen_b1 <= nnsram_wen_b1;
      nsram_wen_b2 <= nnsram_wen_b2;
      nsram_wen_b3 <= nnsram_wen_b3;
    end

  // ===== SRAM_A raddr ===== //
  always@*
  begin
    {sram_raddr_a0, sram_raddr_a1, sram_raddr_a2, sram_raddr_a3} = 4'b0000;
    case(nnheight)
      0:
      begin
        case(nnwidth)
          0:
          begin
            sram_raddr_a0 = 0;
            sram_raddr_a1 = 0;
            sram_raddr_a2 = 0;
            sram_raddr_a3 = 0;
          end
          1:
          begin
            sram_raddr_a0 = 1;
            sram_raddr_a1 = 0;
            sram_raddr_a2 = 1;
            sram_raddr_a3 = 0;
          end
          2:
          begin
            sram_raddr_a0 = 1;
            sram_raddr_a1 = 1;
            sram_raddr_a2 = 1;
            sram_raddr_a3 = 1;
          end
          3:
          begin
            sram_raddr_a0 = 2;
            sram_raddr_a1 = 1;
            sram_raddr_a2 = 2;
            sram_raddr_a3 = 1;
          end
          4:
          begin
            sram_raddr_a0 = 2;
            sram_raddr_a1 = 2;
            sram_raddr_a2 = 2;
            sram_raddr_a3 = 2;
          end
          5:
          begin
            sram_raddr_a0 = 3;
            sram_raddr_a1 = 2;
            sram_raddr_a2 = 3;
            sram_raddr_a3 = 2;
          end
        endcase
      end

      1:
      begin
        case(nnwidth)
          0:
          begin
            sram_raddr_a0 = 6;
            sram_raddr_a1 = 6;
            sram_raddr_a2 = 0;
            sram_raddr_a3 = 0;
          end
          1:
          begin
            sram_raddr_a0 = 7;
            sram_raddr_a1 = 6;
            sram_raddr_a2 = 1;
            sram_raddr_a3 = 0;
          end
          2:
          begin
            sram_raddr_a0 = 7;
            sram_raddr_a1 = 7;
            sram_raddr_a2 = 1;
            sram_raddr_a3 = 1;
          end
          3:
          begin
            sram_raddr_a0 = 8;
            sram_raddr_a1 = 7;
            sram_raddr_a2 = 2;
            sram_raddr_a3 = 1;
          end
          4:
          begin
            sram_raddr_a0 = 8;
            sram_raddr_a1 = 8;
            sram_raddr_a2 = 2;
            sram_raddr_a3 = 2;
          end
          5:
          begin
            sram_raddr_a0 = 9;
            sram_raddr_a1 = 8;
            sram_raddr_a2 = 3;
            sram_raddr_a3 = 2;
          end
        endcase
      end

      2:
      begin
        case(nnwidth)
          0:
          begin
            sram_raddr_a0 = 0+6;
            sram_raddr_a1 = 0+6;
            sram_raddr_a2 = 0+6;
            sram_raddr_a3 = 0+6;
          end
          1:
          begin
            sram_raddr_a0 = 1+6;
            sram_raddr_a1 = 0+6;
            sram_raddr_a2 = 1+6;
            sram_raddr_a3 = 0+6;
          end
          2:
          begin
            sram_raddr_a0 = 1+6;
            sram_raddr_a1 = 1+6;
            sram_raddr_a2 = 1+6;
            sram_raddr_a3 = 1+6;
          end
          3:
          begin
            sram_raddr_a0 = 2+6;
            sram_raddr_a1 = 1+6;
            sram_raddr_a2 = 2+6;
            sram_raddr_a3 = 1+6;
          end
          4:
          begin
            sram_raddr_a0 = 2+6;
            sram_raddr_a1 = 2+6;
            sram_raddr_a2 = 2+6;
            sram_raddr_a3 = 2+6;
          end
          5:
          begin
            sram_raddr_a0 = 3+6;
            sram_raddr_a1 = 2+6;
            sram_raddr_a2 = 3+6;
            sram_raddr_a3 = 2+6;
          end
        endcase
      end

      3:
      begin
        case(nnwidth)
          0:
          begin
            sram_raddr_a0 = 6+6;
            sram_raddr_a1 = 6+6;
            sram_raddr_a2 = 0+6;
            sram_raddr_a3 = 0+6;
          end
          1:
          begin
            sram_raddr_a0 = 7+6;
            sram_raddr_a1 = 6+6;
            sram_raddr_a2 = 1+6;
            sram_raddr_a3 = 0+6;
          end
          2:
          begin
            sram_raddr_a0 = 7+6;
            sram_raddr_a1 = 7+6;
            sram_raddr_a2 = 1+6;
            sram_raddr_a3 = 1+6;
          end
          3:
          begin
            sram_raddr_a0 = 8+6;
            sram_raddr_a1 = 7+6;
            sram_raddr_a2 = 2+6;
            sram_raddr_a3 = 1+6;
          end
          4:
          begin
            sram_raddr_a0 = 8+6;
            sram_raddr_a1 = 8+6;
            sram_raddr_a2 = 2+6;
            sram_raddr_a3 = 2+6;
          end
          5:
          begin
            sram_raddr_a0 = 9+6;
            sram_raddr_a1 = 8+6;
            sram_raddr_a2 = 3+6;
            sram_raddr_a3 = 2+6;
          end
        endcase
      end

      4:
      begin
        case(nnwidth)
          0:
          begin
            sram_raddr_a0 = 0+6*2;
            sram_raddr_a1 = 0+6*2;
            sram_raddr_a2 = 0+6*2;
            sram_raddr_a3 = 0+6*2;
          end
          1:
          begin
            sram_raddr_a0 = 1+6*2;
            sram_raddr_a1 = 0+6*2;
            sram_raddr_a2 = 1+6*2;
            sram_raddr_a3 = 0+6*2;
          end
          2:
          begin
            sram_raddr_a0 = 1+6*2;
            sram_raddr_a1 = 1+6*2;
            sram_raddr_a2 = 1+6*2;
            sram_raddr_a3 = 1+6*2;
          end
          3:
          begin
            sram_raddr_a0 = 2+6*2;
            sram_raddr_a1 = 1+6*2;
            sram_raddr_a2 = 2+6*2;
            sram_raddr_a3 = 1+6*2;
          end
          4:
          begin
            sram_raddr_a0 = 2+6*2;
            sram_raddr_a1 = 2+6*2;
            sram_raddr_a2 = 2+6*2;
            sram_raddr_a3 = 2+6*2;
          end
          5:
          begin
            sram_raddr_a0 = 3+6*2;
            sram_raddr_a1 = 2+6*2;
            sram_raddr_a2 = 3+6*2;
            sram_raddr_a3 = 2+6*2;
          end
        endcase
      end

      5:
      begin
        case(nnwidth)
          0:
          begin
            sram_raddr_a0 = 6+6*2;
            sram_raddr_a1 = 6+6*2;
            sram_raddr_a2 = 0+6*2;
            sram_raddr_a3 = 0+6*2;
          end
          1:
          begin
            sram_raddr_a0 = 7+6*2;
            sram_raddr_a1 = 6+6*2;
            sram_raddr_a2 = 1+6*2;
            sram_raddr_a3 = 0+6*2;
          end
          2:
          begin
            sram_raddr_a0 = 7+6*2;
            sram_raddr_a1 = 7+6*2;
            sram_raddr_a2 = 1+6*2;
            sram_raddr_a3 = 1+6*2;
          end
          3:
          begin
            sram_raddr_a0 = 8+6*2;
            sram_raddr_a1 = 7+6*2;
            sram_raddr_a2 = 2+6*2;
            sram_raddr_a3 = 1+6*2;
          end
          4:
          begin
            sram_raddr_a0 = 8+6*2;
            sram_raddr_a1 = 8+6*2;
            sram_raddr_a2 = 2+6*2;
            sram_raddr_a3 = 2+6*2;
          end
          5:
          begin
            sram_raddr_a0 = 9+6*2;
            sram_raddr_a1 = 8+6*2;
            sram_raddr_a2 = 3+6*2;
            sram_raddr_a3 = 2+6*2;
          end
        endcase
      end
    endcase
  end

  // ===== store convolution region in to input feature map ===== //
  reg signed [4*4*12-1:0] ifeature_map;   // ***** this can do pipeline ***** //
  always@*
  begin
		ifeature_map = 0;
    case(weight_cnt[1:0])
      2'b00: // 0 4 8 12
      begin
        case(height[0])
          0: // 0 2 4
          begin
            case(width[0])
              0: // 0 2 4
                ifeature_map = {nsram_rdata_a0[191:180], nsram_rdata_a0[179:168], nsram_rdata_a1[191:180], nsram_rdata_a1[179:168], nsram_rdata_a0[167:156], nsram_rdata_a0[155:144], nsram_rdata_a1[167:156], nsram_rdata_a1[155:144],
                                nsram_rdata_a2[191:180], nsram_rdata_a2[179:168], nsram_rdata_a3[191:180], nsram_rdata_a3[179:168], nsram_rdata_a2[167:156], nsram_rdata_a2[155:144], nsram_rdata_a3[167:156], nsram_rdata_a3[155:144]};
              1:
                ifeature_map = {nsram_rdata_a1[191:180], nsram_rdata_a1[179:168], nsram_rdata_a0[191:180], nsram_rdata_a0[179:168], nsram_rdata_a1[167:156], nsram_rdata_a1[155:144], nsram_rdata_a0[167:156], nsram_rdata_a0[155:144],
                                nsram_rdata_a3[191:180], nsram_rdata_a3[179:168], nsram_rdata_a2[191:180], nsram_rdata_a2[179:168], nsram_rdata_a3[167:156], nsram_rdata_a3[155:144], nsram_rdata_a2[167:156], nsram_rdata_a2[155:144]};
            endcase
          end

          1:
          begin
            case(width[0])
              0:
                ifeature_map = {nsram_rdata_a2[191:180], nsram_rdata_a2[179:168], nsram_rdata_a3[191:180], nsram_rdata_a3[179:168], nsram_rdata_a2[167:156], nsram_rdata_a2[155:144], nsram_rdata_a3[167:156], nsram_rdata_a3[155:144],
                                nsram_rdata_a0[191:180], nsram_rdata_a0[179:168], nsram_rdata_a1[191:180], nsram_rdata_a1[179:168], nsram_rdata_a0[167:156], nsram_rdata_a0[155:144], nsram_rdata_a1[167:156], nsram_rdata_a1[155:144]};
              1:
                ifeature_map = {nsram_rdata_a3[191:180], nsram_rdata_a3[179:168], nsram_rdata_a2[191:180], nsram_rdata_a2[179:168], nsram_rdata_a3[167:156], nsram_rdata_a3[155:144], nsram_rdata_a2[167:156], nsram_rdata_a2[155:144],
                                nsram_rdata_a1[191:180], nsram_rdata_a1[179:168], nsram_rdata_a0[191:180], nsram_rdata_a0[179:168], nsram_rdata_a1[167:156], nsram_rdata_a1[155:144], nsram_rdata_a0[167:156], nsram_rdata_a0[155:144]};
            endcase
          end
        endcase
      end

      2'b01: // 1 5 9 13
      begin
        case(height[0])
          0:
          begin
            case(width[0])
              0:
                ifeature_map = {nsram_rdata_a0[143:132], nsram_rdata_a0[131:120], nsram_rdata_a1[143:132], nsram_rdata_a1[131:120], nsram_rdata_a0[119:108], nsram_rdata_a0[107:96], nsram_rdata_a1[119:108], nsram_rdata_a1[107:96],
                                nsram_rdata_a2[143:132], nsram_rdata_a2[131:120], nsram_rdata_a3[143:132], nsram_rdata_a3[131:120], nsram_rdata_a2[119:108], nsram_rdata_a2[107:96], nsram_rdata_a3[119:108], nsram_rdata_a3[107:96]};
              1:
                ifeature_map = {nsram_rdata_a1[143:132], nsram_rdata_a1[131:120], nsram_rdata_a0[143:132], nsram_rdata_a0[131:120], nsram_rdata_a1[119:108], nsram_rdata_a1[107:96], nsram_rdata_a0[119:108], nsram_rdata_a0[107:96],
                                nsram_rdata_a3[143:132], nsram_rdata_a3[131:120], nsram_rdata_a2[143:132], nsram_rdata_a2[131:120], nsram_rdata_a3[119:108], nsram_rdata_a3[107:96], nsram_rdata_a2[119:108], nsram_rdata_a2[107:96]};
            endcase
          end

          1:
          begin
            case(width[0])
              0:
                ifeature_map = {nsram_rdata_a2[143:132], nsram_rdata_a2[131:120], nsram_rdata_a3[143:132], nsram_rdata_a3[131:120], nsram_rdata_a2[119:108], nsram_rdata_a2[107:96], nsram_rdata_a3[119:108], nsram_rdata_a3[107:96],
                                nsram_rdata_a0[143:132], nsram_rdata_a0[131:120], nsram_rdata_a1[143:132], nsram_rdata_a1[131:120], nsram_rdata_a0[119:108], nsram_rdata_a0[107:96], nsram_rdata_a1[119:108], nsram_rdata_a1[107:96]};
              1:
                ifeature_map = {nsram_rdata_a3[143:132], nsram_rdata_a3[131:120], nsram_rdata_a2[143:132], nsram_rdata_a2[131:120], nsram_rdata_a3[119:108], nsram_rdata_a3[107:96], nsram_rdata_a2[119:108], nsram_rdata_a2[107:96],
                                nsram_rdata_a1[143:132], nsram_rdata_a1[131:120], nsram_rdata_a0[143:132], nsram_rdata_a0[131:120], nsram_rdata_a1[119:108], nsram_rdata_a1[107:96], nsram_rdata_a0[119:108], nsram_rdata_a0[107:96]};
            endcase
          end
        endcase
      end

      2'b10: // 2 6 10 14
      begin
        case(height[0])
          0:
          begin
            case(width[0])
              0:
                ifeature_map = {nsram_rdata_a0[95:84], nsram_rdata_a0[83:72], nsram_rdata_a1[95:84], nsram_rdata_a1[83:72], nsram_rdata_a0[71:60], nsram_rdata_a0[59:48], nsram_rdata_a1[71:60], nsram_rdata_a1[59:48],
                                nsram_rdata_a2[95:84], nsram_rdata_a2[83:72], nsram_rdata_a3[95:84], nsram_rdata_a3[83:72], nsram_rdata_a2[71:60], nsram_rdata_a2[59:48], nsram_rdata_a3[71:60], nsram_rdata_a3[59:48]};
              1:
                ifeature_map = {nsram_rdata_a1[95:84], nsram_rdata_a1[83:72], nsram_rdata_a0[95:84], nsram_rdata_a0[83:72], nsram_rdata_a1[71:60], nsram_rdata_a1[59:48], nsram_rdata_a0[71:60], nsram_rdata_a0[59:48],
                                nsram_rdata_a3[95:84], nsram_rdata_a3[83:72], nsram_rdata_a2[95:84], nsram_rdata_a2[83:72], nsram_rdata_a3[71:60], nsram_rdata_a3[59:48], nsram_rdata_a2[71:60], nsram_rdata_a2[59:48]};
            endcase
          end

          1:
          begin
            case(width[0])
              0:
                ifeature_map = {nsram_rdata_a2[95:84], nsram_rdata_a2[83:72], nsram_rdata_a3[95:84], nsram_rdata_a3[83:72], nsram_rdata_a2[71:60], nsram_rdata_a2[59:48], nsram_rdata_a3[71:60], nsram_rdata_a3[59:48],
                                nsram_rdata_a0[95:84], nsram_rdata_a0[83:72], nsram_rdata_a1[95:84], nsram_rdata_a1[83:72], nsram_rdata_a0[71:60], nsram_rdata_a0[59:48], nsram_rdata_a1[71:60], nsram_rdata_a1[59:48]};
              1:
                ifeature_map = {nsram_rdata_a3[95:84], nsram_rdata_a3[83:72], nsram_rdata_a2[95:84], nsram_rdata_a2[83:72], nsram_rdata_a3[71:60], nsram_rdata_a3[59:48], nsram_rdata_a2[71:60], nsram_rdata_a2[59:48],
                                nsram_rdata_a1[95:84], nsram_rdata_a1[83:72], nsram_rdata_a0[95:84], nsram_rdata_a0[83:72], nsram_rdata_a1[71:60], nsram_rdata_a1[59:48], nsram_rdata_a0[71:60], nsram_rdata_a0[59:48]};
            endcase
          end
        endcase
      end

      2'b11: // 3 7 11 15
      begin
        case(height[0])
          0:
          begin
            case(width[0])
              0:
                ifeature_map = {nsram_rdata_a0[47:36], nsram_rdata_a0[35:24], nsram_rdata_a1[47:36], nsram_rdata_a1[35:24], nsram_rdata_a0[23:12], nsram_rdata_a0[11:0], nsram_rdata_a1[23:12], nsram_rdata_a1[11:0],
                                nsram_rdata_a2[47:36], nsram_rdata_a2[35:24], nsram_rdata_a3[47:36], nsram_rdata_a3[35:24], nsram_rdata_a2[23:12], nsram_rdata_a2[11:0], nsram_rdata_a3[23:12], nsram_rdata_a3[11:0]};
              1:
                ifeature_map = {nsram_rdata_a1[47:36], nsram_rdata_a1[35:24], nsram_rdata_a0[47:36], nsram_rdata_a0[35:24], nsram_rdata_a1[23:12], nsram_rdata_a1[11:0], nsram_rdata_a0[23:12], nsram_rdata_a0[11:0],
                                nsram_rdata_a3[47:36], nsram_rdata_a3[35:24], nsram_rdata_a2[47:36], nsram_rdata_a2[35:24], nsram_rdata_a3[23:12], nsram_rdata_a3[11:0], nsram_rdata_a2[23:12], nsram_rdata_a2[11:0]};
            endcase
          end

          1:
          begin
            case(width[0])
              0:
                ifeature_map = {nsram_rdata_a2[47:36], nsram_rdata_a2[35:24], nsram_rdata_a3[47:36], nsram_rdata_a3[35:24], nsram_rdata_a2[23:12], nsram_rdata_a2[11:0], nsram_rdata_a3[23:12], nsram_rdata_a3[11:0],
                                nsram_rdata_a0[47:36], nsram_rdata_a0[35:24], nsram_rdata_a1[47:36], nsram_rdata_a1[35:24], nsram_rdata_a0[23:12], nsram_rdata_a0[11:0], nsram_rdata_a1[23:12], nsram_rdata_a1[11:0]};
              1:
                ifeature_map = {nsram_rdata_a3[47:36], nsram_rdata_a3[35:24], nsram_rdata_a2[47:36], nsram_rdata_a2[35:24], nsram_rdata_a3[23:12], nsram_rdata_a3[11:0], nsram_rdata_a2[23:12], nsram_rdata_a2[11:0],
                                nsram_rdata_a1[47:36], nsram_rdata_a1[35:24], nsram_rdata_a0[47:36], nsram_rdata_a0[35:24], nsram_rdata_a1[23:12], nsram_rdata_a1[11:0], nsram_rdata_a0[23:12], nsram_rdata_a0[11:0]};
            endcase
          end
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
    if(~rst_n)
    begin
			for(i=0; i<3; i=i+1)begin
				conv_result0[i] <= 0;
				conv_result1[i] <= 0;
				conv_result2[i] <= 0;
				conv_result3[i] <= 0;
			end
    end
    else if((weight_cnt+1)%4==0)
    begin
			for(i=0; i<3; i=i+1)begin
				conv_result0[i] <= 0;
				conv_result1[i] <= 0;
				conv_result2[i] <= 0;
				conv_result3[i] <= 0;
			end
    end
    else if(load_enable)
    begin
			for(i=0; i<3; i=i+1)begin
				conv_result0[i] <= nconv_result0[i];
				conv_result1[i] <= nconv_result1[i];
				conv_result2[i] <= nconv_result2[i];
				conv_result3[i] <= nconv_result3[i];
			end
    end
		
		for(i=0; i<3; i=i+1)begin
    conv_out0[i] <= nconv_result0[i];
    conv_out1[i] <= nconv_result1[i];
    conv_out2[i] <= nconv_result2[i];
    conv_out3[i] <= nconv_result3[i]; 
		end
  end


  // ===== add bias ===== //
  reg signed [20:0] naccumulated_out[0:3];
  reg signed [20:0] q_out[0:3];
  always@*
  begin
    // ===== quantize ===== //
		if( conv_out3[0] + conv_out3[1] + conv_out3[2] + (nsram_rdata_bias<<8)>0 )
			naccumulated_out[3] = conv_out3[0] + conv_out3[1] + conv_out3[2] + (nsram_rdata_bias<<8);
		else
			naccumulated_out[3] = 0;
		if( conv_out2[0] + conv_out2[1] + conv_out2[2] + (nsram_rdata_bias<<8)>0 )
			naccumulated_out[2] = conv_out2[0] + conv_out2[1] + conv_out2[2] + (nsram_rdata_bias<<8);
		else
			naccumulated_out[2] = 0;
		if( conv_out1[0] + conv_out1[1] + conv_out1[2] + (nsram_rdata_bias<<8)>0 )
			naccumulated_out[1] = conv_out1[0] + conv_out1[1] + conv_out1[2] + (nsram_rdata_bias<<8);
		else
			naccumulated_out[1] = 0;
		if( conv_out0[0] + conv_out0[1] + conv_out0[2] + (nsram_rdata_bias<<8)>0 )
			naccumulated_out[0] = conv_out0[0] + conv_out0[1] + conv_out0[2] + (nsram_rdata_bias<<8);
		else
			naccumulated_out[0] = 0;
	end
	
  reg signed [20:0] accumulated_out[0:3];
	always@(posedge clk)
		for(i=0; i<4; i=i+1) begin
			accumulated_out[i] <= naccumulated_out[i];
		end

  always@*
  begin
    q_out[3] = (accumulated_out[3] + 2**6) >>> 7;
    q_out[2] = (accumulated_out[2] + 2**6) >>> 7;
    q_out[1] = (accumulated_out[1] + 2**6) >>> 7;
    q_out[0] = (accumulated_out[0] + 2**6) >>> 7;

    if(q_out[0] > 2047)
      q_out[0] = 2047;
    else if(q_out[0]< -2048)
      q_out[0] = -2048;
    else
      q_out[0] = q_out[0][11:0] ;

    if(q_out[1] > 2047)
      q_out[1] = 2047;
    else if(q_out[1]< -2048)
      q_out[1] = -2048;
    else
      q_out[1] = q_out[1][11:0] ;

    if(q_out[2] > 2047)
      q_out[2] = 2047;
    else if(q_out[2]< -2048)
      q_out[2] = -2048;
    else
      q_out[2] = q_out[2][11:0] ;

    if(q_out[3] > 2047)
      q_out[3] = 2047;
    else if(q_out[3]< -2048)
      q_out[3] = -2048;
    else
      q_out[3] = q_out[3][11:0] ;
  end

  // ===== mask & store to SRAM_B ===== //
  always@*
  begin
    sram_wordmask_b = 16'b1111111111111111;
    sram_wdata_b = 0;
    case(weight_cnt)
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
    endcase
  end

  // =====because the pipeline delay, so the done signal should be delay=====//
  always@(posedge clk)
		begin
			nconv_done <= nnconv_done;
      conv_done <= nconv_done;
		end

endmodule



