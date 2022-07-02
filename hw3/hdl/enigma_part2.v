module enigma_part2
  #(
     parameter IDLE = 0,
     parameter LOAD = 1,
     parameter READY = 2,
     parameter MODE0 = 0,
     parameter MODE1 = 1,
     parameter MODE2 = 2,
     parameter MODE3 = 3
   )
   (
     input clk,
     input srstn,
     input load,
     input encrypt,
     input crypt_mode,
     input [8-1:0] load_idx,
     input [6-1:0] code_in,
     output reg [6-1:0] code_out,
     output reg code_valid
   );

  integer i;
  reg [1:0] state, nstate;
  reg [6-1:0] rotorA_table [0:63]; //64-6bit register file
  reg [6-1:0] rotorB_table [0:63];
  reg [6-1:0] rotorC_table [0:63];
  reg [6-1:0] ref_o;
  reg [6-1:0] rotA_o;
  reg [6-1:0] rotB_o;
  reg [6-1:0] rotC_o;
  reg [6-1:0] rotB_o_inv;
  reg [6-1:0] rotC_o_inv;
  reg [6-1:0 ]rotA_o_inv;
  reg [6-1:0] code_out_tmp;
  reg code_valid_tmp;
  reg code_valid_tmp_S2;
  reg code_valid_tmp_S3;
  reg code_valid_tmp_S4;
  reg code_valid_tmp_S5;
  reg rotorA_en;
  reg rotorA_en_tmp;
  reg rotorB_en;
  reg rotorC_en_S2;
  reg [1:0] rotorB_cnt;
  reg [1:0] rotorB_cnt_tmp;
  reg [6-1:0]code_in_tmp;
  wire load_A;
  wire load_B;
  wire load_C;
  reg [1:0] sb4_mode;
  reg [8-1:0] load_idx_tmp;
  reg [6-1:0] rotB_o_tmp;
  reg [6-1:0] rotC_o_inv_tmp;
  reg [6-1:0] rotB_o_inv_tmp;
  reg [6-1:0] rotA_o_inv_tmp;
  reg [6-1:0] rotorC_table_S3 [0:63];
  reg [1:0]shift_idx_B;
  reg star_en;



  // flip flop input
  always@(posedge clk)
  begin
    code_in_tmp <= code_in;
    load_idx_tmp <= load_idx;
  end

  // FSM for state change
  always@*
  begin
    nstate = IDLE;
    case(state)
      IDLE:
      begin
        if(load)
          nstate = LOAD;
        else
          nstate = IDLE;
      end
      LOAD:
      begin
        if(~load)
          nstate = READY;
        else
          nstate = LOAD;
      end
      READY:
        nstate = READY;
    endcase
  end

  always@(posedge clk)
    if(~srstn)
      state <= IDLE;
    else
      state <= nstate;

  // rotorA table shift detection & rotorC table shift simultaneously with rotorA
  always@(posedge clk)
    if(~srstn)
      rotorA_en <= 0;
    else
      rotorA_en <= rotorA_en_tmp;

  always@(posedge clk)
    if(~srstn)
      star_en <= 0;
    else if(encrypt)
      star_en <= 1;

  always@*
  begin
    if(encrypt | star_en)
      rotorA_en_tmp = 1;
    else
      rotorA_en_tmp = 0;
  end

  always@*
    if(rotorA_en)
      code_valid_tmp = 1;
    else
      code_valid_tmp = 0;

  // rotorB table shift detection
  always@*
    if(rotorA_en & rotorB_cnt!=1 )
      rotorB_cnt_tmp = rotorB_cnt + 1;
    else
      rotorB_cnt_tmp = 0;
  always@(posedge clk)
    if(~srstn)
      rotorB_cnt <= 0;
    else
      rotorB_cnt <= rotorB_cnt_tmp;
  always@*
    if(rotorB_cnt==1)
      rotorB_en = 1;
    else
      rotorB_en = 0;

  ////////// Stage-1 //////////
  // (1) - rotorA register
  assign load_A = (load_idx_tmp[7:6]==2'b00)? 1:0;
  always@(posedge clk)
  begin
    if(load & load_A)
    begin
      rotorA_table[63] <= code_in_tmp;
      for(i=0; i<63; i=i+1)
      begin
        rotorA_table[i] <= rotorA_table[i+1];
      end
    end
    else if(rotorA_en)
    begin
      rotorA_table[0] <= rotorA_table[63];
      for(i=1; i<64; i=i+1)
      begin
        rotorA_table[i] <= rotorA_table[i-1];
      end
    end
  end
  // There are no else rotorA_table <= rotorA_table. Is it ok?

  // (2) - rotorB register
  assign load_B = (load_idx_tmp[7:6]==2'b01)? 1:0;
  always@(posedge clk)
  begin
    if(load & load_B)
    begin
      rotorB_table[63] <= code_in_tmp;
      for(i=0; i<63; i=i+1)
      begin
        rotorB_table[i] <= rotorB_table[i+1];
      end
    end
    else if(rotorB_en)
    begin
      rotorB_table[0] <= rotorB_table[63];
      for(i=1; i<64; i=i+1)
      begin
        rotorB_table[i] <= rotorB_table[i-1];
      end
    end
  end
  // There are no else rotorB_table <= rotorB_table. Is it ok?

  // (3) - rotorC register
  assign load_C = (load_idx_tmp[7:6]==2'b10)? 1:0;
  always@(posedge clk)
  begin
    if(load & load_C)
    begin
      rotorC_table[63] <= code_in_tmp;
      for(i=0; i<63; i=i+1)
      begin
        rotorC_table[i] <= rotorC_table[i+1];
      end
    end
    else if(rotorC_en_S2)
    begin
      case(sb4_mode)
        MODE0:
        begin
          rotorC_table[0]<=rotorC_table[41];
          rotorC_table[1]<=rotorC_table[56];
          rotorC_table[2]<=rotorC_table[61];
          rotorC_table[3]<=rotorC_table[29];
          rotorC_table[4]<=rotorC_table[0];
          rotorC_table[5]<=rotorC_table[26];
          rotorC_table[6]<=rotorC_table[28];
          rotorC_table[7]<=rotorC_table[63];
          rotorC_table[8]<=rotorC_table[34];
          rotorC_table[9]<=rotorC_table[19];
          rotorC_table[10]<=rotorC_table[36];
          rotorC_table[11]<=rotorC_table[46];
          rotorC_table[12]<=rotorC_table[23];
          rotorC_table[13]<=rotorC_table[54];
          rotorC_table[14]<=rotorC_table[44];
          rotorC_table[15]<=rotorC_table[7];
          rotorC_table[16]<=rotorC_table[43];
          rotorC_table[17]<=rotorC_table[1];
          rotorC_table[18]<=rotorC_table[42];
          rotorC_table[19]<=rotorC_table[5];
          rotorC_table[20]<=rotorC_table[40];
          rotorC_table[21]<=rotorC_table[22];
          rotorC_table[22]<=rotorC_table[6];
          rotorC_table[23]<=rotorC_table[33];
          rotorC_table[24]<=rotorC_table[21];
          rotorC_table[25]<=rotorC_table[58];
          rotorC_table[26]<=rotorC_table[13];
          rotorC_table[27]<=rotorC_table[51];
          rotorC_table[28]<=rotorC_table[53];
          rotorC_table[29]<=rotorC_table[24];
          rotorC_table[30]<=rotorC_table[37];
          rotorC_table[31]<=rotorC_table[32];
          rotorC_table[32]<=rotorC_table[31];
          rotorC_table[33]<=rotorC_table[11];
          rotorC_table[34]<=rotorC_table[47];
          rotorC_table[35]<=rotorC_table[25];
          rotorC_table[36]<=rotorC_table[48];
          rotorC_table[37]<=rotorC_table[2];
          rotorC_table[38]<=rotorC_table[10];
          rotorC_table[39]<=rotorC_table[9];
          rotorC_table[40]<=rotorC_table[4];
          rotorC_table[41]<=rotorC_table[52];
          rotorC_table[42]<=rotorC_table[55];
          rotorC_table[43]<=rotorC_table[17];
          rotorC_table[44]<=rotorC_table[8];
          rotorC_table[45]<=rotorC_table[62];
          rotorC_table[46]<=rotorC_table[16];
          rotorC_table[47]<=rotorC_table[50];
          rotorC_table[48]<=rotorC_table[38];
          rotorC_table[49]<=rotorC_table[14];
          rotorC_table[50]<=rotorC_table[30];
          rotorC_table[51]<=rotorC_table[27];
          rotorC_table[52]<=rotorC_table[57];
          rotorC_table[53]<=rotorC_table[18];
          rotorC_table[54]<=rotorC_table[60];
          rotorC_table[55]<=rotorC_table[15];
          rotorC_table[56]<=rotorC_table[49];
          rotorC_table[57]<=rotorC_table[59];
          rotorC_table[58]<=rotorC_table[20];
          rotorC_table[59]<=rotorC_table[12];
          rotorC_table[60]<=rotorC_table[39];
          rotorC_table[61]<=rotorC_table[3];
          rotorC_table[62]<=rotorC_table[35];
          rotorC_table[63]<=rotorC_table[45];
        end
        MODE1:
        begin
          rotorC_table[0]<=rotorC_table[40];
          rotorC_table[1]<=rotorC_table[57];
          rotorC_table[2]<=rotorC_table[60];
          rotorC_table[3]<=rotorC_table[28];
          rotorC_table[4]<=rotorC_table[1];
          rotorC_table[5]<=rotorC_table[27];
          rotorC_table[6]<=rotorC_table[29];
          rotorC_table[7]<=rotorC_table[62];
          rotorC_table[8]<=rotorC_table[35];
          rotorC_table[9]<=rotorC_table[18];
          rotorC_table[10]<=rotorC_table[37];
          rotorC_table[11]<=rotorC_table[47];
          rotorC_table[12]<=rotorC_table[22];
          rotorC_table[13]<=rotorC_table[55];
          rotorC_table[14]<=rotorC_table[45];
          rotorC_table[15]<=rotorC_table[6];
          rotorC_table[16]<=rotorC_table[42];
          rotorC_table[17]<=rotorC_table[0];
          rotorC_table[18]<=rotorC_table[43];
          rotorC_table[19]<=rotorC_table[4];
          rotorC_table[20]<=rotorC_table[41];
          rotorC_table[21]<=rotorC_table[23];
          rotorC_table[22]<=rotorC_table[7];
          rotorC_table[23]<=rotorC_table[32];
          rotorC_table[24]<=rotorC_table[20];
          rotorC_table[25]<=rotorC_table[59];
          rotorC_table[26]<=rotorC_table[12];
          rotorC_table[27]<=rotorC_table[50];
          rotorC_table[28]<=rotorC_table[52];
          rotorC_table[29]<=rotorC_table[25];
          rotorC_table[30]<=rotorC_table[36];
          rotorC_table[31]<=rotorC_table[33];
          rotorC_table[32]<=rotorC_table[30];
          rotorC_table[33]<=rotorC_table[10];
          rotorC_table[34]<=rotorC_table[46];
          rotorC_table[35]<=rotorC_table[24];
          rotorC_table[36]<=rotorC_table[49];
          rotorC_table[37]<=rotorC_table[3];
          rotorC_table[38]<=rotorC_table[11];
          rotorC_table[39]<=rotorC_table[8];
          rotorC_table[40]<=rotorC_table[5];
          rotorC_table[41]<=rotorC_table[53];
          rotorC_table[42]<=rotorC_table[54];
          rotorC_table[43]<=rotorC_table[16];
          rotorC_table[44]<=rotorC_table[9];
          rotorC_table[45]<=rotorC_table[63];
          rotorC_table[46]<=rotorC_table[17];
          rotorC_table[47]<=rotorC_table[51];
          rotorC_table[48]<=rotorC_table[39];
          rotorC_table[49]<=rotorC_table[15];
          rotorC_table[50]<=rotorC_table[31];
          rotorC_table[51]<=rotorC_table[26];
          rotorC_table[52]<=rotorC_table[56];
          rotorC_table[53]<=rotorC_table[19];
          rotorC_table[54]<=rotorC_table[61];
          rotorC_table[55]<=rotorC_table[14];
          rotorC_table[56]<=rotorC_table[48];
          rotorC_table[57]<=rotorC_table[58];
          rotorC_table[58]<=rotorC_table[21];
          rotorC_table[59]<=rotorC_table[13];
          rotorC_table[60]<=rotorC_table[38];
          rotorC_table[61]<=rotorC_table[2];
          rotorC_table[62]<=rotorC_table[34];
          rotorC_table[63]<=rotorC_table[44];
        end
        MODE2:
        begin
          rotorC_table[0]<=rotorC_table[43];
          rotorC_table[1]<=rotorC_table[58];
          rotorC_table[2]<=rotorC_table[63];
          rotorC_table[3]<=rotorC_table[31];
          rotorC_table[4]<=rotorC_table[2];
          rotorC_table[5]<=rotorC_table[24];
          rotorC_table[6]<=rotorC_table[30];
          rotorC_table[7]<=rotorC_table[61];
          rotorC_table[8]<=rotorC_table[32];
          rotorC_table[9]<=rotorC_table[17];
          rotorC_table[10]<=rotorC_table[38];
          rotorC_table[11]<=rotorC_table[44];
          rotorC_table[12]<=rotorC_table[21];
          rotorC_table[13]<=rotorC_table[52];
          rotorC_table[14]<=rotorC_table[46];
          rotorC_table[15]<=rotorC_table[5];
          rotorC_table[16]<=rotorC_table[41];
          rotorC_table[17]<=rotorC_table[3];
          rotorC_table[18]<=rotorC_table[40];
          rotorC_table[19]<=rotorC_table[7];
          rotorC_table[20]<=rotorC_table[42];
          rotorC_table[21]<=rotorC_table[20];
          rotorC_table[22]<=rotorC_table[4];
          rotorC_table[23]<=rotorC_table[35];
          rotorC_table[24]<=rotorC_table[23];
          rotorC_table[25]<=rotorC_table[56];
          rotorC_table[26]<=rotorC_table[15];
          rotorC_table[27]<=rotorC_table[49];
          rotorC_table[28]<=rotorC_table[55];
          rotorC_table[29]<=rotorC_table[26];
          rotorC_table[30]<=rotorC_table[39];
          rotorC_table[31]<=rotorC_table[34];
          rotorC_table[32]<=rotorC_table[29];
          rotorC_table[33]<=rotorC_table[9];
          rotorC_table[34]<=rotorC_table[45];
          rotorC_table[35]<=rotorC_table[27];
          rotorC_table[36]<=rotorC_table[50];
          rotorC_table[37]<=rotorC_table[0];
          rotorC_table[38]<=rotorC_table[8];
          rotorC_table[39]<=rotorC_table[11];
          rotorC_table[40]<=rotorC_table[6];
          rotorC_table[41]<=rotorC_table[54];
          rotorC_table[42]<=rotorC_table[53];
          rotorC_table[43]<=rotorC_table[19];
          rotorC_table[44]<=rotorC_table[10];
          rotorC_table[45]<=rotorC_table[60];
          rotorC_table[46]<=rotorC_table[18];
          rotorC_table[47]<=rotorC_table[48];
          rotorC_table[48]<=rotorC_table[36];
          rotorC_table[49]<=rotorC_table[12];
          rotorC_table[50]<=rotorC_table[28];
          rotorC_table[51]<=rotorC_table[25];
          rotorC_table[52]<=rotorC_table[59];
          rotorC_table[53]<=rotorC_table[16];
          rotorC_table[54]<=rotorC_table[62];
          rotorC_table[55]<=rotorC_table[13];
          rotorC_table[56]<=rotorC_table[51];
          rotorC_table[57]<=rotorC_table[57];
          rotorC_table[58]<=rotorC_table[22];
          rotorC_table[59]<=rotorC_table[14];
          rotorC_table[60]<=rotorC_table[37];
          rotorC_table[61]<=rotorC_table[1];
          rotorC_table[62]<=rotorC_table[33];
          rotorC_table[63]<=rotorC_table[47];
        end
        MODE3:
        begin
          rotorC_table[0]<=rotorC_table[42];
          rotorC_table[1]<=rotorC_table[59];
          rotorC_table[2]<=rotorC_table[62];
          rotorC_table[3]<=rotorC_table[30];
          rotorC_table[4]<=rotorC_table[3];
          rotorC_table[5]<=rotorC_table[25];
          rotorC_table[6]<=rotorC_table[31];
          rotorC_table[7]<=rotorC_table[60];
          rotorC_table[8]<=rotorC_table[33];
          rotorC_table[9]<=rotorC_table[16];
          rotorC_table[10]<=rotorC_table[39];
          rotorC_table[11]<=rotorC_table[45];
          rotorC_table[12]<=rotorC_table[20];
          rotorC_table[13]<=rotorC_table[53];
          rotorC_table[14]<=rotorC_table[47];
          rotorC_table[15]<=rotorC_table[4];
          rotorC_table[16]<=rotorC_table[40];
          rotorC_table[17]<=rotorC_table[2];
          rotorC_table[18]<=rotorC_table[41];
          rotorC_table[19]<=rotorC_table[6];
          rotorC_table[20]<=rotorC_table[43];
          rotorC_table[21]<=rotorC_table[21];
          rotorC_table[22]<=rotorC_table[5];
          rotorC_table[23]<=rotorC_table[34];
          rotorC_table[24]<=rotorC_table[22];
          rotorC_table[25]<=rotorC_table[57];
          rotorC_table[26]<=rotorC_table[14];
          rotorC_table[27]<=rotorC_table[48];
          rotorC_table[28]<=rotorC_table[54];
          rotorC_table[29]<=rotorC_table[27];
          rotorC_table[30]<=rotorC_table[38];
          rotorC_table[31]<=rotorC_table[35];
          rotorC_table[32]<=rotorC_table[28];
          rotorC_table[33]<=rotorC_table[8];
          rotorC_table[34]<=rotorC_table[44];
          rotorC_table[35]<=rotorC_table[26];
          rotorC_table[36]<=rotorC_table[51];
          rotorC_table[37]<=rotorC_table[1];
          rotorC_table[38]<=rotorC_table[9];
          rotorC_table[39]<=rotorC_table[10];
          rotorC_table[40]<=rotorC_table[7];
          rotorC_table[41]<=rotorC_table[55];
          rotorC_table[42]<=rotorC_table[52];
          rotorC_table[43]<=rotorC_table[18];
          rotorC_table[44]<=rotorC_table[11];
          rotorC_table[45]<=rotorC_table[61];
          rotorC_table[46]<=rotorC_table[19];
          rotorC_table[47]<=rotorC_table[49];
          rotorC_table[48]<=rotorC_table[37];
          rotorC_table[49]<=rotorC_table[13];
          rotorC_table[50]<=rotorC_table[29];
          rotorC_table[51]<=rotorC_table[24];
          rotorC_table[52]<=rotorC_table[58];
          rotorC_table[53]<=rotorC_table[17];
          rotorC_table[54]<=rotorC_table[63];
          rotorC_table[55]<=rotorC_table[12];
          rotorC_table[56]<=rotorC_table[50];
          rotorC_table[57]<=rotorC_table[56];
          rotorC_table[58]<=rotorC_table[23];
          rotorC_table[59]<=rotorC_table[15];
          rotorC_table[60]<=rotorC_table[36];
          rotorC_table[61]<=rotorC_table[0];
          rotorC_table[62]<=rotorC_table[32];
          rotorC_table[63]<=rotorC_table[46];
        end
      endcase
    end
  end
  // There are no else rotorC_table <= rotorC_table. Is it ok?

  // (4-1) - rotorA output
  always@*
  begin
    rotA_o = rotorA_table[code_in_tmp];
  end
  // rotorB output
  always@*
  begin
    rotB_o = rotorB_table[rotA_o];
  end

  // pass the data from stage1 to stage2
  always@(posedge clk)
  begin
    if(~srstn)
    begin
      rotorC_en_S2 <= 0;
      code_valid_tmp_S2 <= 0;
    end
    else
    begin
      rotorC_en_S2 <= rotorA_en;
      rotB_o_tmp <= rotB_o;
      code_valid_tmp_S2 <= code_valid_tmp;
    end
  end
  ////////////////////////////////////////////////////////////////////

  ////////// Stage-2 //////////
  // (4-2) - rotorC output
  always@*
  begin
    rotC_o = rotorC_table[rotB_o_tmp];
  end

  // (5) - reflector lut
  always@*
  begin
    if(crypt_mode==0)
      ref_o = 6'd63 - rotC_o;
    else
      ref_o = rotC_o;
  end

  // (6) - Inverse rotor: reflector to rotorC
  always@*
    if(crypt_mode==0)
      rotC_o_inv = ref_o;
    else
      rotC_o_inv = 6'd63 - ref_o;

  // rotorC mode decide
  always@*
  case(crypt_mode)
    1'b0:
    begin
      case(rotC_o[1:0])
        2'b00:
          sb4_mode = MODE0;
        2'b01:
          sb4_mode = MODE1;
        2'b10:
          sb4_mode = MODE2;
        2'b11:
          sb4_mode = MODE3;
      endcase
    end
    1'b1:
    begin
      case(rotC_o_inv[1:0])
        2'b00:
          sb4_mode = MODE0;
        2'b01:
          sb4_mode = MODE1;
        2'b10:
          sb4_mode = MODE2;
        2'b11:
          sb4_mode = MODE3;
      endcase
    end
  endcase

  // pass the data from stage2 to stage3
  always@(posedge clk)
  begin
    if(~srstn)
    begin
      code_valid_tmp_S3 <= 0;
    end
    else
    begin
      code_valid_tmp_S3 <= code_valid_tmp_S2;
      rotC_o_inv_tmp <= rotC_o_inv;
      for(i=0; i<64; i=i+1)
      begin
        rotorC_table_S3[i] <= rotorC_table[i];
      end
    end
  end
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  ////////// Stage-3 //////////
  // (7) - Inverse rotor rotorC to rotorB
  always@*
    if(rotC_o_inv_tmp==rotorC_table_S3[0])
    begin
      rotB_o_inv = 0;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[1])
    begin
      rotB_o_inv = 1;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[2])
    begin
      rotB_o_inv = 2;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[3])
    begin
      rotB_o_inv = 3;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[4])
    begin
      rotB_o_inv = 4;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[5])
    begin
      rotB_o_inv = 5;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[6])
    begin
      rotB_o_inv = 6;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[7])
    begin
      rotB_o_inv = 7;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[8])
    begin
      rotB_o_inv = 8;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[9])
    begin
      rotB_o_inv = 9;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[10])
    begin
      rotB_o_inv = 10;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[11])
    begin
      rotB_o_inv = 11;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[12])
    begin
      rotB_o_inv = 12;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[13])
    begin
      rotB_o_inv = 13;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[14])
    begin
      rotB_o_inv = 14;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[15])
    begin
      rotB_o_inv = 15;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[16])
    begin
      rotB_o_inv = 16;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[17])
    begin
      rotB_o_inv = 17;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[18])
    begin
      rotB_o_inv = 18;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[19])
    begin
      rotB_o_inv = 19;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[20])
    begin
      rotB_o_inv = 20;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[21])
    begin
      rotB_o_inv = 21;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[22])
    begin
      rotB_o_inv = 22;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[23])
    begin
      rotB_o_inv = 23;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[24])
    begin
      rotB_o_inv = 24;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[25])
    begin
      rotB_o_inv = 25;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[26])
    begin
      rotB_o_inv = 26;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[27])
    begin
      rotB_o_inv = 27;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[28])
    begin
      rotB_o_inv = 28;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[29])
    begin
      rotB_o_inv = 29;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[30])
    begin
      rotB_o_inv = 30;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[31])
    begin
      rotB_o_inv = 31;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[32])
    begin
      rotB_o_inv = 32;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[33])
    begin
      rotB_o_inv = 33;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[34])
    begin
      rotB_o_inv = 34;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[35])
    begin
      rotB_o_inv = 35;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[36])
    begin
      rotB_o_inv = 36;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[37])
    begin
      rotB_o_inv = 37;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[38])
    begin
      rotB_o_inv = 38;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[39])
    begin
      rotB_o_inv = 39;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[40])
    begin
      rotB_o_inv = 40;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[41])
    begin
      rotB_o_inv = 41;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[42])
    begin
      rotB_o_inv = 42;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[43])
    begin
      rotB_o_inv = 43;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[44])
    begin
      rotB_o_inv = 44;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[45])
    begin
      rotB_o_inv = 45;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[46])
    begin
      rotB_o_inv = 46;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[47])
    begin
      rotB_o_inv = 47;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[48])
    begin
      rotB_o_inv = 48;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[49])
    begin
      rotB_o_inv = 49;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[50])
    begin
      rotB_o_inv = 50;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[51])
    begin
      rotB_o_inv = 51;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[52])
    begin
      rotB_o_inv = 52;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[53])
    begin
      rotB_o_inv = 53;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[54])
    begin
      rotB_o_inv = 54;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[55])
    begin
      rotB_o_inv = 55;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[56])
    begin
      rotB_o_inv = 56;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[57])
    begin
      rotB_o_inv = 57;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[58])
    begin
      rotB_o_inv = 58;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[59])
    begin
      rotB_o_inv = 59;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[60])
    begin
      rotB_o_inv = 60;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[61])
    begin
      rotB_o_inv = 61;
    end
    else if(rotC_o_inv_tmp==rotorC_table_S3[62])
    begin
      rotB_o_inv = 62;
    end
    else
    begin
      rotB_o_inv = 63;
    end

  // pass the data from stage3 to stage4
  always@(posedge clk)
  begin
    if(~srstn)
    begin
      code_valid_tmp_S4 <= 0;
    end
    else
    begin
      code_valid_tmp_S4 <= code_valid_tmp_S3;
      rotB_o_inv_tmp <= rotB_o_inv;
    end
  end
  ////////////////////////////////////////////////////

  ////////// Stage-4 //////////
  // (8) - Inverse rotor rotorB to rotorA
  always@*
    if(rotorB_en)
      shift_idx_B = 1;
    else
      shift_idx_B = 2;

  always@*
    if(rotB_o_inv_tmp==rotorB_table[0])
    begin
      if(rotorB_en)
        rotA_o_inv = 63;
      else
        rotA_o_inv = 62;
    end
    else if(rotB_o_inv_tmp==rotorB_table[1])
    begin
      if(rotorB_en)
        rotA_o_inv = 0;
      else
        rotA_o_inv = 63;
    end
    else if(rotB_o_inv_tmp==rotorB_table[2])
    begin
      rotA_o_inv = 2-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[3])
    begin
      rotA_o_inv = 3-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[4])
    begin
      rotA_o_inv = 4-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[5])
    begin
      rotA_o_inv = 5-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[6])
    begin
      rotA_o_inv = 6-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[7])
    begin
      rotA_o_inv = 7-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[8])
    begin
      rotA_o_inv = 8-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[9])
    begin
      rotA_o_inv = 9-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[10])
    begin
      rotA_o_inv = 10-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[11])
    begin
      rotA_o_inv = 11-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[12])
    begin
      rotA_o_inv = 12-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[13])
    begin
      rotA_o_inv = 13-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[14])
    begin
      rotA_o_inv = 14-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[15])
    begin
      rotA_o_inv = 15-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[16])
    begin
      rotA_o_inv = 16-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[17])
    begin
      rotA_o_inv = 17-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[18])
    begin
      rotA_o_inv = 18-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[19])
    begin
      rotA_o_inv = 19-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[20])
    begin
      rotA_o_inv = 20-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[21])
    begin
      rotA_o_inv = 21-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[22])
    begin
      rotA_o_inv = 22-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[23])
    begin
      rotA_o_inv = 23-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[24])
    begin
      rotA_o_inv = 24-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[25])
    begin
      rotA_o_inv = 25-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[26])
    begin
      rotA_o_inv = 26-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[27])
    begin
      rotA_o_inv = 27-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[28])
    begin
      rotA_o_inv = 28-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[29])
    begin
      rotA_o_inv = 29-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[30])
    begin
      rotA_o_inv = 30-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[31])
    begin
      rotA_o_inv = 31-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[32])
    begin
      rotA_o_inv = 32-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[33])
    begin
      rotA_o_inv = 33-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[34])
    begin
      rotA_o_inv = 34-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[35])
    begin
      rotA_o_inv = 35-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[36])
    begin
      rotA_o_inv = 36-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[37])
    begin
      rotA_o_inv = 37-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[38])
    begin
      rotA_o_inv = 38-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[39])
    begin
      rotA_o_inv = 39-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[40])
    begin
      rotA_o_inv = 40-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[41])
    begin
      rotA_o_inv = 41-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[42])
    begin
      rotA_o_inv = 42-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[43])
    begin
      rotA_o_inv = 43-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[44])
    begin
      rotA_o_inv = 44-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[45])
    begin
      rotA_o_inv = 45-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[46])
    begin
      rotA_o_inv = 46-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[47])
    begin
      rotA_o_inv = 47-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[48])
    begin
      rotA_o_inv = 48-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[49])
    begin
      rotA_o_inv = 49-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[50])
    begin
      rotA_o_inv = 50-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[51])
    begin
      rotA_o_inv = 51-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[52])
    begin
      rotA_o_inv = 52-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[53])
    begin
      rotA_o_inv = 53-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[54])
    begin
      rotA_o_inv = 54-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[55])
    begin
      rotA_o_inv = 55-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[56])
    begin
      rotA_o_inv = 56-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[57])
    begin
      rotA_o_inv = 57-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[58])
    begin
      rotA_o_inv = 58-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[59])
    begin
      rotA_o_inv = 59-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[60])
    begin
      rotA_o_inv = 60-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[61])
    begin
      rotA_o_inv = 61-shift_idx_B;
    end
    else if(rotB_o_inv_tmp==rotorB_table[62])
    begin
      rotA_o_inv = 62-shift_idx_B;
    end
    else
    begin
      rotA_o_inv = 63-shift_idx_B;
    end

  // pass the data from stage4 to stage5
  always@(posedge clk)
  begin
    if(~srstn)
    begin
      code_valid_tmp_S5 <= 0;
    end
    else
    begin
      code_valid_tmp_S5 <= code_valid_tmp_S4;
      rotA_o_inv_tmp <= rotA_o_inv;
    end
  end
  ////////////////////////////////////////////////////

  ////////// Stage-5 //////////
  // Inverse rotor rotorA to output
  always@*
    if(rotA_o_inv_tmp==rotorA_table[0])
    begin
      code_out_tmp = 60;

    end
    else if(rotA_o_inv_tmp==rotorA_table[1])
    begin
      code_out_tmp = 61;

    end
    else if(rotA_o_inv_tmp==rotorA_table[2])
    begin
      code_out_tmp = 62;

    end
    else if(rotA_o_inv_tmp==rotorA_table[3])
    begin
      code_out_tmp = 63;

    end
    else if(rotA_o_inv_tmp==rotorA_table[4])
    begin
      code_out_tmp = 4-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[5])
    begin
      code_out_tmp = 5-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[6])
    begin
      code_out_tmp = 6-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[7])
    begin
      code_out_tmp = 7-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[8])
    begin
      code_out_tmp = 8-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[9])
    begin
      code_out_tmp = 9-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[10])
    begin
      code_out_tmp = 10-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[11])
    begin
      code_out_tmp = 11-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[12])
    begin
      code_out_tmp = 12-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[13])
    begin
      code_out_tmp = 13-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[14])
    begin
      code_out_tmp = 14-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[15])
    begin
      code_out_tmp = 15-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[16])
    begin
      code_out_tmp = 16-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[17])
    begin
      code_out_tmp = 17-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[18])
    begin
      code_out_tmp = 18-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[19])
    begin
      code_out_tmp = 19-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[20])
    begin
      code_out_tmp = 20-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[21])
    begin
      code_out_tmp = 21-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[22])
    begin
      code_out_tmp = 22-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[23])
    begin
      code_out_tmp = 23-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[24])
    begin
      code_out_tmp = 24-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[25])
    begin
      code_out_tmp = 25-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[26])
    begin
      code_out_tmp = 26-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[27])
    begin
      code_out_tmp = 27-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[28])
    begin
      code_out_tmp = 28-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[29])
    begin
      code_out_tmp = 29-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[30])
    begin
      code_out_tmp = 30-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[31])
    begin
      code_out_tmp = 31-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[32])
    begin
      code_out_tmp = 32-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[33])
    begin
      code_out_tmp = 33-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[34])
    begin
      code_out_tmp = 34-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[35])
    begin
      code_out_tmp = 35-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[36])
    begin
      code_out_tmp = 36-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[37])
    begin
      code_out_tmp = 37-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[38])
    begin
      code_out_tmp = 38-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[39])
    begin
      code_out_tmp = 39-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[40])
    begin
      code_out_tmp = 40-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[41])
    begin
      code_out_tmp = 41-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[42])
    begin
      code_out_tmp = 42-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[43])
    begin
      code_out_tmp = 43-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[44])
    begin
      code_out_tmp = 44-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[45])
    begin
      code_out_tmp = 45-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[46])
    begin
      code_out_tmp = 46-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[47])
    begin
      code_out_tmp = 47-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[48])
    begin
      code_out_tmp = 48-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[49])
    begin
      code_out_tmp = 49-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[50])
    begin
      code_out_tmp = 50-4;

    end

    else if(rotA_o_inv_tmp==rotorA_table[51])
    begin
      code_out_tmp = 51-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[52])
    begin
      code_out_tmp = 52-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[53])
    begin
      code_out_tmp = 53-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[54])
    begin
      code_out_tmp = 54-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[55])
    begin
      code_out_tmp = 55-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[56])
    begin
      code_out_tmp = 56-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[57])
    begin
      code_out_tmp = 57-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[58])
    begin
      code_out_tmp = 58-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[59])
    begin
      code_out_tmp = 59-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[60])
    begin
      code_out_tmp = 60-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[61])
    begin
      code_out_tmp = 61-4;

    end
    else if(rotA_o_inv_tmp==rotorA_table[62])
    begin
      code_out_tmp = 62-4;

    end
    else
    begin
      code_out_tmp = 63-4;

    end

  // pass the data from stage5 to output
  always@(posedge clk)
  begin
    if(~srstn)
    begin
      code_out <= 0;
      code_valid <= 0;
    end
    else
    begin
      code_out <= code_out_tmp;
      code_valid <= code_valid_tmp_S5;
    end
  end
  ////////////////////////////////////////////////////

endmodule
