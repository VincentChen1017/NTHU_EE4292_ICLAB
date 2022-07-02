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
  reg rotorA_en;
  reg rotorA_en_tmp;
  reg rotorB_en;
  reg [1:0] rotorB_cnt;
  reg [1:0] rotorB_cnt_tmp;
  reg [6-1:0]code_in_tmp;
  wire load_A;
  wire load_B;
  wire load_C;
  reg [1:0] sb4_mode;
  reg [8-1:0] load_idx_tmp;

  // flip flop input
  always@(posedge clk)
  begin
    if(~srstn)
    begin
      code_in_tmp <= 0;
      load_idx_tmp <= 0;
    end
    else
    begin
      code_in_tmp <= code_in;
      load_idx_tmp <= load_idx;
    end
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
  always@*
  begin
    if(encrypt)
      rotorA_en_tmp = 1;
    else
      rotorA_en_tmp = rotorA_en;
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

  // rotorA register
  assign load_A = (load_idx_tmp[7:6]==2'b00)? 1:0;
  always@(posedge clk)
  begin
    if(~srstn)
    begin
      rotorA_table[0] <= 0;
      rotorA_table[1] <= 0;
      rotorA_table[2] <= 0;
      rotorA_table[3] <= 0;
      rotorA_table[4] <= 0;
      rotorA_table[5] <= 0;
      rotorA_table[6] <= 0;
      rotorA_table[7] <= 0;
      rotorA_table[8] <= 0;
      rotorA_table[9] <= 0;
      rotorA_table[10] <= 0;
      rotorA_table[11] <= 0;
      rotorA_table[12] <= 0;
      rotorA_table[13] <= 0;
      rotorA_table[14] <= 0;
      rotorA_table[15] <= 0;
      rotorA_table[16] <= 0;
      rotorA_table[17] <= 0;
      rotorA_table[18] <= 0;
      rotorA_table[19] <= 0;
      rotorA_table[20] <= 0;
      rotorA_table[21] <= 0;
      rotorA_table[22] <= 0;
      rotorA_table[23] <= 0;
      rotorA_table[24] <= 0;
      rotorA_table[25] <= 0;
      rotorA_table[26] <= 0;
      rotorA_table[27] <= 0;
      rotorA_table[28] <= 0;
      rotorA_table[29] <= 0;
      rotorA_table[30] <= 0;
      rotorA_table[31] <= 0;
      rotorA_table[32] <= 0;
      rotorA_table[33] <= 0;
      rotorA_table[34] <= 0;
      rotorA_table[35] <= 0;
      rotorA_table[36] <= 0;
      rotorA_table[37] <= 0;
      rotorA_table[38] <= 0;
      rotorA_table[39] <= 0;
      rotorA_table[40] <= 0;
      rotorA_table[41] <= 0;
      rotorA_table[42] <= 0;
      rotorA_table[43] <= 0;
      rotorA_table[44] <= 0;
      rotorA_table[45] <= 0;
      rotorA_table[46] <= 0;
      rotorA_table[47] <= 0;
      rotorA_table[48] <= 0;
      rotorA_table[49] <= 0;
      rotorA_table[50] <= 0;
      rotorA_table[51] <= 0;
      rotorA_table[52] <= 0;
      rotorA_table[53] <= 0;
      rotorA_table[54] <= 0;
      rotorA_table[55] <= 0;
      rotorA_table[56] <= 0;
      rotorA_table[57] <= 0;
      rotorA_table[58] <= 0;
      rotorA_table[59] <= 0;
      rotorA_table[60] <= 0;
      rotorA_table[61] <= 0;
      rotorA_table[62] <= 0;
      rotorA_table[63] <= 0;
    end
    else if(load & load_A)
    begin
      rotorA_table[63] <= code_in_tmp;
      rotorA_table[62] <= rotorA_table[63];
      rotorA_table[61] <= rotorA_table[62];
      rotorA_table[60] <= rotorA_table[61];
      rotorA_table[59] <= rotorA_table[60];
      rotorA_table[58] <= rotorA_table[59];
      rotorA_table[57] <= rotorA_table[58];
      rotorA_table[56] <= rotorA_table[57];
      rotorA_table[55] <= rotorA_table[56];
      rotorA_table[54] <= rotorA_table[55];
      rotorA_table[53] <= rotorA_table[54];
      rotorA_table[52] <= rotorA_table[53];
      rotorA_table[51] <= rotorA_table[52];
      rotorA_table[50] <= rotorA_table[51];
      rotorA_table[49] <= rotorA_table[50];
      rotorA_table[48] <= rotorA_table[49];
      rotorA_table[47] <= rotorA_table[48];
      rotorA_table[46] <= rotorA_table[47];
      rotorA_table[45] <= rotorA_table[46];
      rotorA_table[44] <= rotorA_table[45];
      rotorA_table[43] <= rotorA_table[44];
      rotorA_table[42] <= rotorA_table[43];
      rotorA_table[41] <= rotorA_table[42];
      rotorA_table[40] <= rotorA_table[41];
      rotorA_table[39] <= rotorA_table[40];
      rotorA_table[38] <= rotorA_table[39];
      rotorA_table[37] <= rotorA_table[38];
      rotorA_table[36] <= rotorA_table[37];
      rotorA_table[35] <= rotorA_table[36];
      rotorA_table[34] <= rotorA_table[35];
      rotorA_table[33] <= rotorA_table[34];
      rotorA_table[32] <= rotorA_table[33];
      rotorA_table[31] <= rotorA_table[32];
      rotorA_table[30] <= rotorA_table[31];
      rotorA_table[29] <= rotorA_table[30];
      rotorA_table[28] <= rotorA_table[29];
      rotorA_table[27] <= rotorA_table[28];
      rotorA_table[26] <= rotorA_table[27];
      rotorA_table[25] <= rotorA_table[26];
      rotorA_table[24] <= rotorA_table[25];
      rotorA_table[23] <= rotorA_table[24];
      rotorA_table[22] <= rotorA_table[23];
      rotorA_table[21] <= rotorA_table[22];
      rotorA_table[20] <= rotorA_table[21];
      rotorA_table[19] <= rotorA_table[20];
      rotorA_table[18] <= rotorA_table[19];
      rotorA_table[17] <= rotorA_table[18];
      rotorA_table[16] <= rotorA_table[17];
      rotorA_table[15] <= rotorA_table[16];
      rotorA_table[14] <= rotorA_table[15];
      rotorA_table[13] <= rotorA_table[14];
      rotorA_table[12] <= rotorA_table[13];
      rotorA_table[11] <= rotorA_table[12];
      rotorA_table[10] <= rotorA_table[11];
      rotorA_table[9] <= rotorA_table[10];
      rotorA_table[8] <= rotorA_table[9];
      rotorA_table[7] <= rotorA_table[8];
      rotorA_table[6] <= rotorA_table[7];
      rotorA_table[5] <= rotorA_table[6];
      rotorA_table[4] <= rotorA_table[5];
      rotorA_table[3] <= rotorA_table[4];
      rotorA_table[2] <= rotorA_table[3];
      rotorA_table[1] <= rotorA_table[2];
      rotorA_table[0] <= rotorA_table[1];
    end
    else if(rotorA_en)
    begin
      rotorA_table[0] <= rotorA_table[63];
      rotorA_table[1] <= rotorA_table[0];
      rotorA_table[2] <= rotorA_table[1];
      rotorA_table[3] <= rotorA_table[2];
      rotorA_table[4] <= rotorA_table[3];
      rotorA_table[5] <= rotorA_table[4];
      rotorA_table[6] <= rotorA_table[5];
      rotorA_table[7] <= rotorA_table[6];
      rotorA_table[8] <= rotorA_table[7];
      rotorA_table[9] <= rotorA_table[8];
      rotorA_table[10] <= rotorA_table[9];
      rotorA_table[11] <= rotorA_table[10];
      rotorA_table[12] <= rotorA_table[11];
      rotorA_table[13] <= rotorA_table[12];
      rotorA_table[14] <= rotorA_table[13];
      rotorA_table[15] <= rotorA_table[14];
      rotorA_table[16] <= rotorA_table[15];
      rotorA_table[17] <= rotorA_table[16];
      rotorA_table[18] <= rotorA_table[17];
      rotorA_table[19] <= rotorA_table[18];
      rotorA_table[20] <= rotorA_table[19];
      rotorA_table[21] <= rotorA_table[20];
      rotorA_table[22] <= rotorA_table[21];
      rotorA_table[23] <= rotorA_table[22];
      rotorA_table[24] <= rotorA_table[23];
      rotorA_table[25] <= rotorA_table[24];
      rotorA_table[26] <= rotorA_table[25];
      rotorA_table[27] <= rotorA_table[26];
      rotorA_table[28] <= rotorA_table[27];
      rotorA_table[29] <= rotorA_table[28];
      rotorA_table[30] <= rotorA_table[29];
      rotorA_table[31] <= rotorA_table[30];
      rotorA_table[32] <= rotorA_table[31];
      rotorA_table[33] <= rotorA_table[32];
      rotorA_table[34] <= rotorA_table[33];
      rotorA_table[35] <= rotorA_table[34];
      rotorA_table[36] <= rotorA_table[35];
      rotorA_table[37] <= rotorA_table[36];
      rotorA_table[38] <= rotorA_table[37];
      rotorA_table[39] <= rotorA_table[38];
      rotorA_table[40] <= rotorA_table[39];
      rotorA_table[41] <= rotorA_table[40];
      rotorA_table[42] <= rotorA_table[41];
      rotorA_table[43] <= rotorA_table[42];
      rotorA_table[44] <= rotorA_table[43];
      rotorA_table[45] <= rotorA_table[44];
      rotorA_table[46] <= rotorA_table[45];
      rotorA_table[47] <= rotorA_table[46];
      rotorA_table[48] <= rotorA_table[47];
      rotorA_table[49] <= rotorA_table[48];
      rotorA_table[50] <= rotorA_table[49];
      rotorA_table[51] <= rotorA_table[50];
      rotorA_table[52] <= rotorA_table[51];
      rotorA_table[53] <= rotorA_table[52];
      rotorA_table[54] <= rotorA_table[53];
      rotorA_table[55] <= rotorA_table[54];
      rotorA_table[56] <= rotorA_table[55];
      rotorA_table[57] <= rotorA_table[56];
      rotorA_table[58] <= rotorA_table[57];
      rotorA_table[59] <= rotorA_table[58];
      rotorA_table[60] <= rotorA_table[59];
      rotorA_table[61] <= rotorA_table[60];
      rotorA_table[62] <= rotorA_table[61];
      rotorA_table[63] <= rotorA_table[62];
    end
    else
    begin
      rotorA_table[0] <= rotorA_table[0];
      rotorA_table[1] <= rotorA_table[1];
      rotorA_table[2] <= rotorA_table[2];
      rotorA_table[3] <= rotorA_table[3];
      rotorA_table[4] <= rotorA_table[4];
      rotorA_table[5] <= rotorA_table[5];
      rotorA_table[6] <= rotorA_table[6];
      rotorA_table[7] <= rotorA_table[7];
      rotorA_table[8] <= rotorA_table[8];
      rotorA_table[9] <= rotorA_table[9];
      rotorA_table[10] <= rotorA_table[10];
      rotorA_table[11] <= rotorA_table[11];
      rotorA_table[12] <= rotorA_table[12];
      rotorA_table[13] <= rotorA_table[13];
      rotorA_table[14] <= rotorA_table[14];
      rotorA_table[15] <= rotorA_table[15];
      rotorA_table[16] <= rotorA_table[16];
      rotorA_table[17] <= rotorA_table[17];
      rotorA_table[18] <= rotorA_table[18];
      rotorA_table[19] <= rotorA_table[19];
      rotorA_table[20] <= rotorA_table[20];
      rotorA_table[21] <= rotorA_table[21];
      rotorA_table[22] <= rotorA_table[22];
      rotorA_table[23] <= rotorA_table[23];
      rotorA_table[24] <= rotorA_table[24];
      rotorA_table[25] <= rotorA_table[25];
      rotorA_table[26] <= rotorA_table[26];
      rotorA_table[27] <= rotorA_table[27];
      rotorA_table[28] <= rotorA_table[28];
      rotorA_table[29] <= rotorA_table[29];
      rotorA_table[30] <= rotorA_table[30];
      rotorA_table[31] <= rotorA_table[31];
      rotorA_table[32] <= rotorA_table[32];
      rotorA_table[33] <= rotorA_table[33];
      rotorA_table[34] <= rotorA_table[34];
      rotorA_table[35] <= rotorA_table[35];
      rotorA_table[36] <= rotorA_table[36];
      rotorA_table[37] <= rotorA_table[37];
      rotorA_table[38] <= rotorA_table[38];
      rotorA_table[39] <= rotorA_table[39];
      rotorA_table[40] <= rotorA_table[40];
      rotorA_table[41] <= rotorA_table[41];
      rotorA_table[42] <= rotorA_table[42];
      rotorA_table[43] <= rotorA_table[43];
      rotorA_table[44] <= rotorA_table[44];
      rotorA_table[45] <= rotorA_table[45];
      rotorA_table[46] <= rotorA_table[46];
      rotorA_table[47] <= rotorA_table[47];
      rotorA_table[48] <= rotorA_table[48];
      rotorA_table[49] <= rotorA_table[49];
      rotorA_table[50] <= rotorA_table[50];
      rotorA_table[51] <= rotorA_table[51];
      rotorA_table[52] <= rotorA_table[52];
      rotorA_table[53] <= rotorA_table[53];
      rotorA_table[54] <= rotorA_table[54];
      rotorA_table[55] <= rotorA_table[55];
      rotorA_table[56] <= rotorA_table[56];
      rotorA_table[57] <= rotorA_table[57];
      rotorA_table[58] <= rotorA_table[58];
      rotorA_table[59] <= rotorA_table[59];
      rotorA_table[60] <= rotorA_table[60];
      rotorA_table[61] <= rotorA_table[61];
      rotorA_table[62] <= rotorA_table[62];
      rotorA_table[63] <= rotorA_table[63];
    end
  end

  // rotorA output
  always@*
  begin
    rotA_o = rotorA_table[code_in_tmp];
  end

  // rotorB register
  assign load_B = (load_idx_tmp[7:6]==2'b01)? 1:0;
  always@(posedge clk)
  begin
    if(~srstn)
    begin
      rotorB_table[0] <= 0;
      rotorB_table[1] <= 0;
      rotorB_table[2] <= 0;
      rotorB_table[3] <= 0;
      rotorB_table[4] <= 0;
      rotorB_table[5] <= 0;
      rotorB_table[6] <= 0;
      rotorB_table[7] <= 0;
      rotorB_table[8] <= 0;
      rotorB_table[9] <= 0;
      rotorB_table[10] <= 0;
      rotorB_table[11] <= 0;
      rotorB_table[12] <= 0;
      rotorB_table[13] <= 0;
      rotorB_table[14] <= 0;
      rotorB_table[15] <= 0;
      rotorB_table[16] <= 0;
      rotorB_table[17] <= 0;
      rotorB_table[18] <= 0;
      rotorB_table[19] <= 0;
      rotorB_table[20] <= 0;
      rotorB_table[21] <= 0;
      rotorB_table[22] <= 0;
      rotorB_table[23] <= 0;
      rotorB_table[24] <= 0;
      rotorB_table[25] <= 0;
      rotorB_table[26] <= 0;
      rotorB_table[27] <= 0;
      rotorB_table[28] <= 0;
      rotorB_table[29] <= 0;
      rotorB_table[30] <= 0;
      rotorB_table[31] <= 0;
      rotorB_table[32] <= 0;
      rotorB_table[33] <= 0;
      rotorB_table[34] <= 0;
      rotorB_table[35] <= 0;
      rotorB_table[36] <= 0;
      rotorB_table[37] <= 0;
      rotorB_table[38] <= 0;
      rotorB_table[39] <= 0;
      rotorB_table[40] <= 0;
      rotorB_table[41] <= 0;
      rotorB_table[42] <= 0;
      rotorB_table[43] <= 0;
      rotorB_table[44] <= 0;
      rotorB_table[45] <= 0;
      rotorB_table[46] <= 0;
      rotorB_table[47] <= 0;
      rotorB_table[48] <= 0;
      rotorB_table[49] <= 0;
      rotorB_table[50] <= 0;
      rotorB_table[51] <= 0;
      rotorB_table[52] <= 0;
      rotorB_table[53] <= 0;
      rotorB_table[54] <= 0;
      rotorB_table[55] <= 0;
      rotorB_table[56] <= 0;
      rotorB_table[57] <= 0;
      rotorB_table[58] <= 0;
      rotorB_table[59] <= 0;
      rotorB_table[60] <= 0;
      rotorB_table[61] <= 0;
      rotorB_table[62] <= 0;
      rotorB_table[63] <= 0;
    end
    else if(load & load_B)
    begin
      rotorB_table[63] <= code_in_tmp;
      rotorB_table[62] <= rotorB_table[63];
      rotorB_table[61] <= rotorB_table[62];
      rotorB_table[60] <= rotorB_table[61];
      rotorB_table[59] <= rotorB_table[60];
      rotorB_table[58] <= rotorB_table[59];
      rotorB_table[57] <= rotorB_table[58];
      rotorB_table[56] <= rotorB_table[57];
      rotorB_table[55] <= rotorB_table[56];
      rotorB_table[54] <= rotorB_table[55];
      rotorB_table[53] <= rotorB_table[54];
      rotorB_table[52] <= rotorB_table[53];
      rotorB_table[51] <= rotorB_table[52];
      rotorB_table[50] <= rotorB_table[51];
      rotorB_table[49] <= rotorB_table[50];
      rotorB_table[48] <= rotorB_table[49];
      rotorB_table[47] <= rotorB_table[48];
      rotorB_table[46] <= rotorB_table[47];
      rotorB_table[45] <= rotorB_table[46];
      rotorB_table[44] <= rotorB_table[45];
      rotorB_table[43] <= rotorB_table[44];
      rotorB_table[42] <= rotorB_table[43];
      rotorB_table[41] <= rotorB_table[42];
      rotorB_table[40] <= rotorB_table[41];
      rotorB_table[39] <= rotorB_table[40];
      rotorB_table[38] <= rotorB_table[39];
      rotorB_table[37] <= rotorB_table[38];
      rotorB_table[36] <= rotorB_table[37];
      rotorB_table[35] <= rotorB_table[36];
      rotorB_table[34] <= rotorB_table[35];
      rotorB_table[33] <= rotorB_table[34];
      rotorB_table[32] <= rotorB_table[33];
      rotorB_table[31] <= rotorB_table[32];
      rotorB_table[30] <= rotorB_table[31];
      rotorB_table[29] <= rotorB_table[30];
      rotorB_table[28] <= rotorB_table[29];
      rotorB_table[27] <= rotorB_table[28];
      rotorB_table[26] <= rotorB_table[27];
      rotorB_table[25] <= rotorB_table[26];
      rotorB_table[24] <= rotorB_table[25];
      rotorB_table[23] <= rotorB_table[24];
      rotorB_table[22] <= rotorB_table[23];
      rotorB_table[21] <= rotorB_table[22];
      rotorB_table[20] <= rotorB_table[21];
      rotorB_table[19] <= rotorB_table[20];
      rotorB_table[18] <= rotorB_table[19];
      rotorB_table[17] <= rotorB_table[18];
      rotorB_table[16] <= rotorB_table[17];
      rotorB_table[15] <= rotorB_table[16];
      rotorB_table[14] <= rotorB_table[15];
      rotorB_table[13] <= rotorB_table[14];
      rotorB_table[12] <= rotorB_table[13];
      rotorB_table[11] <= rotorB_table[12];
      rotorB_table[10] <= rotorB_table[11];
      rotorB_table[9] <= rotorB_table[10];
      rotorB_table[8] <= rotorB_table[9];
      rotorB_table[7] <= rotorB_table[8];
      rotorB_table[6] <= rotorB_table[7];
      rotorB_table[5] <= rotorB_table[6];
      rotorB_table[4] <= rotorB_table[5];
      rotorB_table[3] <= rotorB_table[4];
      rotorB_table[2] <= rotorB_table[3];
      rotorB_table[1] <= rotorB_table[2];
      rotorB_table[0] <= rotorB_table[1];
    end
    else if(rotorB_en)
    begin
      rotorB_table[0] <= rotorB_table[63];
      rotorB_table[1] <= rotorB_table[0];
      rotorB_table[2] <= rotorB_table[1];
      rotorB_table[3] <= rotorB_table[2];
      rotorB_table[4] <= rotorB_table[3];
      rotorB_table[5] <= rotorB_table[4];
      rotorB_table[6] <= rotorB_table[5];
      rotorB_table[7] <= rotorB_table[6];
      rotorB_table[8] <= rotorB_table[7];
      rotorB_table[9] <= rotorB_table[8];
      rotorB_table[10] <= rotorB_table[9];
      rotorB_table[11] <= rotorB_table[10];
      rotorB_table[12] <= rotorB_table[11];
      rotorB_table[13] <= rotorB_table[12];
      rotorB_table[14] <= rotorB_table[13];
      rotorB_table[15] <= rotorB_table[14];
      rotorB_table[16] <= rotorB_table[15];
      rotorB_table[17] <= rotorB_table[16];
      rotorB_table[18] <= rotorB_table[17];
      rotorB_table[19] <= rotorB_table[18];
      rotorB_table[20] <= rotorB_table[19];
      rotorB_table[21] <= rotorB_table[20];
      rotorB_table[22] <= rotorB_table[21];
      rotorB_table[23] <= rotorB_table[22];
      rotorB_table[24] <= rotorB_table[23];
      rotorB_table[25] <= rotorB_table[24];
      rotorB_table[26] <= rotorB_table[25];
      rotorB_table[27] <= rotorB_table[26];
      rotorB_table[28] <= rotorB_table[27];
      rotorB_table[29] <= rotorB_table[28];
      rotorB_table[30] <= rotorB_table[29];
      rotorB_table[31] <= rotorB_table[30];
      rotorB_table[32] <= rotorB_table[31];
      rotorB_table[33] <= rotorB_table[32];
      rotorB_table[34] <= rotorB_table[33];
      rotorB_table[35] <= rotorB_table[34];
      rotorB_table[36] <= rotorB_table[35];
      rotorB_table[37] <= rotorB_table[36];
      rotorB_table[38] <= rotorB_table[37];
      rotorB_table[39] <= rotorB_table[38];
      rotorB_table[40] <= rotorB_table[39];
      rotorB_table[41] <= rotorB_table[40];
      rotorB_table[42] <= rotorB_table[41];
      rotorB_table[43] <= rotorB_table[42];
      rotorB_table[44] <= rotorB_table[43];
      rotorB_table[45] <= rotorB_table[44];
      rotorB_table[46] <= rotorB_table[45];
      rotorB_table[47] <= rotorB_table[46];
      rotorB_table[48] <= rotorB_table[47];
      rotorB_table[49] <= rotorB_table[48];
      rotorB_table[50] <= rotorB_table[49];
      rotorB_table[51] <= rotorB_table[50];
      rotorB_table[52] <= rotorB_table[51];
      rotorB_table[53] <= rotorB_table[52];
      rotorB_table[54] <= rotorB_table[53];
      rotorB_table[55] <= rotorB_table[54];
      rotorB_table[56] <= rotorB_table[55];
      rotorB_table[57] <= rotorB_table[56];
      rotorB_table[58] <= rotorB_table[57];
      rotorB_table[59] <= rotorB_table[58];
      rotorB_table[60] <= rotorB_table[59];
      rotorB_table[61] <= rotorB_table[60];
      rotorB_table[62] <= rotorB_table[61];
      rotorB_table[63] <= rotorB_table[62];
    end
    else
    begin
      rotorB_table[0] <= rotorB_table[0];
      rotorB_table[1] <= rotorB_table[1];
      rotorB_table[2] <= rotorB_table[2];
      rotorB_table[3] <= rotorB_table[3];
      rotorB_table[4] <= rotorB_table[4];
      rotorB_table[5] <= rotorB_table[5];
      rotorB_table[6] <= rotorB_table[6];
      rotorB_table[7] <= rotorB_table[7];
      rotorB_table[8] <= rotorB_table[8];
      rotorB_table[9] <= rotorB_table[9];
      rotorB_table[10] <= rotorB_table[10];
      rotorB_table[11] <= rotorB_table[11];
      rotorB_table[12] <= rotorB_table[12];
      rotorB_table[13] <= rotorB_table[13];
      rotorB_table[14] <= rotorB_table[14];
      rotorB_table[15] <= rotorB_table[15];
      rotorB_table[16] <= rotorB_table[16];
      rotorB_table[17] <= rotorB_table[17];
      rotorB_table[18] <= rotorB_table[18];
      rotorB_table[19] <= rotorB_table[19];
      rotorB_table[20] <= rotorB_table[20];
      rotorB_table[21] <= rotorB_table[21];
      rotorB_table[22] <= rotorB_table[22];
      rotorB_table[23] <= rotorB_table[23];
      rotorB_table[24] <= rotorB_table[24];
      rotorB_table[25] <= rotorB_table[25];
      rotorB_table[26] <= rotorB_table[26];
      rotorB_table[27] <= rotorB_table[27];
      rotorB_table[28] <= rotorB_table[28];
      rotorB_table[29] <= rotorB_table[29];
      rotorB_table[30] <= rotorB_table[30];
      rotorB_table[31] <= rotorB_table[31];
      rotorB_table[32] <= rotorB_table[32];
      rotorB_table[33] <= rotorB_table[33];
      rotorB_table[34] <= rotorB_table[34];
      rotorB_table[35] <= rotorB_table[35];
      rotorB_table[36] <= rotorB_table[36];
      rotorB_table[37] <= rotorB_table[37];
      rotorB_table[38] <= rotorB_table[38];
      rotorB_table[39] <= rotorB_table[39];
      rotorB_table[40] <= rotorB_table[40];
      rotorB_table[41] <= rotorB_table[41];
      rotorB_table[42] <= rotorB_table[42];
      rotorB_table[43] <= rotorB_table[43];
      rotorB_table[44] <= rotorB_table[44];
      rotorB_table[45] <= rotorB_table[45];
      rotorB_table[46] <= rotorB_table[46];
      rotorB_table[47] <= rotorB_table[47];
      rotorB_table[48] <= rotorB_table[48];
      rotorB_table[49] <= rotorB_table[49];
      rotorB_table[50] <= rotorB_table[50];
      rotorB_table[51] <= rotorB_table[51];
      rotorB_table[52] <= rotorB_table[52];
      rotorB_table[53] <= rotorB_table[53];
      rotorB_table[54] <= rotorB_table[54];
      rotorB_table[55] <= rotorB_table[55];
      rotorB_table[56] <= rotorB_table[56];
      rotorB_table[57] <= rotorB_table[57];
      rotorB_table[58] <= rotorB_table[58];
      rotorB_table[59] <= rotorB_table[59];
      rotorB_table[60] <= rotorB_table[60];
      rotorB_table[61] <= rotorB_table[61];
      rotorB_table[62] <= rotorB_table[62];
      rotorB_table[63] <= rotorB_table[63];
    end
  end

  // rotorB output
  always@*
  begin
    rotB_o = rotorB_table[rotA_o];
  end

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

  // rotorC register
  assign load_C = (load_idx_tmp[7:6]==2'b10)? 1:0;
  always@(posedge clk)
  begin
    if(~srstn)
    begin
      rotorC_table[0] <= 0;
      rotorC_table[1] <= 0;
      rotorC_table[2] <= 0;
      rotorC_table[3] <= 0;
      rotorC_table[4] <= 0;
      rotorC_table[5] <= 0;
      rotorC_table[6] <= 0;
      rotorC_table[7] <= 0;
      rotorC_table[8] <= 0;
      rotorC_table[9] <= 0;
      rotorC_table[10] <= 0;
      rotorC_table[11] <= 0;
      rotorC_table[12] <= 0;
      rotorC_table[13] <= 0;
      rotorC_table[14] <= 0;
      rotorC_table[15] <= 0;
      rotorC_table[16] <= 0;
      rotorC_table[17] <= 0;
      rotorC_table[18] <= 0;
      rotorC_table[19] <= 0;
      rotorC_table[20] <= 0;
      rotorC_table[21] <= 0;
      rotorC_table[22] <= 0;
      rotorC_table[23] <= 0;
      rotorC_table[24] <= 0;
      rotorC_table[25] <= 0;
      rotorC_table[26] <= 0;
      rotorC_table[27] <= 0;
      rotorC_table[28] <= 0;
      rotorC_table[29] <= 0;
      rotorC_table[30] <= 0;
      rotorC_table[31] <= 0;
      rotorC_table[32] <= 0;
      rotorC_table[33] <= 0;
      rotorC_table[34] <= 0;
      rotorC_table[35] <= 0;
      rotorC_table[36] <= 0;
      rotorC_table[37] <= 0;
      rotorC_table[38] <= 0;
      rotorC_table[39] <= 0;
      rotorC_table[40] <= 0;
      rotorC_table[41] <= 0;
      rotorC_table[42] <= 0;
      rotorC_table[43] <= 0;
      rotorC_table[44] <= 0;
      rotorC_table[45] <= 0;
      rotorC_table[46] <= 0;
      rotorC_table[47] <= 0;
      rotorC_table[48] <= 0;
      rotorC_table[49] <= 0;
      rotorC_table[50] <= 0;
      rotorC_table[51] <= 0;
      rotorC_table[52] <= 0;
      rotorC_table[53] <= 0;
      rotorC_table[54] <= 0;
      rotorC_table[55] <= 0;
      rotorC_table[56] <= 0;
      rotorC_table[57] <= 0;
      rotorC_table[58] <= 0;
      rotorC_table[59] <= 0;
      rotorC_table[60] <= 0;
      rotorC_table[61] <= 0;
      rotorC_table[62] <= 0;
      rotorC_table[63] <= 0;
    end
    else if(load & load_C)
    begin
      rotorC_table[63] <= code_in_tmp;
      rotorC_table[62] <= rotorC_table[63];
      rotorC_table[61] <= rotorC_table[62];
      rotorC_table[60] <= rotorC_table[61];
      rotorC_table[59] <= rotorC_table[60];
      rotorC_table[58] <= rotorC_table[59];
      rotorC_table[57] <= rotorC_table[58];
      rotorC_table[56] <= rotorC_table[57];
      rotorC_table[55] <= rotorC_table[56];
      rotorC_table[54] <= rotorC_table[55];
      rotorC_table[53] <= rotorC_table[54];
      rotorC_table[52] <= rotorC_table[53];
      rotorC_table[51] <= rotorC_table[52];
      rotorC_table[50] <= rotorC_table[51];
      rotorC_table[49] <= rotorC_table[50];
      rotorC_table[48] <= rotorC_table[49];
      rotorC_table[47] <= rotorC_table[48];
      rotorC_table[46] <= rotorC_table[47];
      rotorC_table[45] <= rotorC_table[46];
      rotorC_table[44] <= rotorC_table[45];
      rotorC_table[43] <= rotorC_table[44];
      rotorC_table[42] <= rotorC_table[43];
      rotorC_table[41] <= rotorC_table[42];
      rotorC_table[40] <= rotorC_table[41];
      rotorC_table[39] <= rotorC_table[40];
      rotorC_table[38] <= rotorC_table[39];
      rotorC_table[37] <= rotorC_table[38];
      rotorC_table[36] <= rotorC_table[37];
      rotorC_table[35] <= rotorC_table[36];
      rotorC_table[34] <= rotorC_table[35];
      rotorC_table[33] <= rotorC_table[34];
      rotorC_table[32] <= rotorC_table[33];
      rotorC_table[31] <= rotorC_table[32];
      rotorC_table[30] <= rotorC_table[31];
      rotorC_table[29] <= rotorC_table[30];
      rotorC_table[28] <= rotorC_table[29];
      rotorC_table[27] <= rotorC_table[28];
      rotorC_table[26] <= rotorC_table[27];
      rotorC_table[25] <= rotorC_table[26];
      rotorC_table[24] <= rotorC_table[25];
      rotorC_table[23] <= rotorC_table[24];
      rotorC_table[22] <= rotorC_table[23];
      rotorC_table[21] <= rotorC_table[22];
      rotorC_table[20] <= rotorC_table[21];
      rotorC_table[19] <= rotorC_table[20];
      rotorC_table[18] <= rotorC_table[19];
      rotorC_table[17] <= rotorC_table[18];
      rotorC_table[16] <= rotorC_table[17];
      rotorC_table[15] <= rotorC_table[16];
      rotorC_table[14] <= rotorC_table[15];
      rotorC_table[13] <= rotorC_table[14];
      rotorC_table[12] <= rotorC_table[13];
      rotorC_table[11] <= rotorC_table[12];
      rotorC_table[10] <= rotorC_table[11];
      rotorC_table[9] <= rotorC_table[10];
      rotorC_table[8] <= rotorC_table[9];
      rotorC_table[7] <= rotorC_table[8];
      rotorC_table[6] <= rotorC_table[7];
      rotorC_table[5] <= rotorC_table[6];
      rotorC_table[4] <= rotorC_table[5];
      rotorC_table[3] <= rotorC_table[4];
      rotorC_table[2] <= rotorC_table[3];
      rotorC_table[1] <= rotorC_table[2];
      rotorC_table[0] <= rotorC_table[1];
    end
    else if(rotorA_en) // rotorA and rotorC will rotor simultaneously
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
    else
    begin
      rotorC_table[0] <= rotorC_table[0];
      rotorC_table[1] <= rotorC_table[1];
      rotorC_table[2] <= rotorC_table[2];
      rotorC_table[3] <= rotorC_table[3];
      rotorC_table[4] <= rotorC_table[4];
      rotorC_table[5] <= rotorC_table[5];
      rotorC_table[6] <= rotorC_table[6];
      rotorC_table[7] <= rotorC_table[7];
      rotorC_table[8] <= rotorC_table[8];
      rotorC_table[9] <= rotorC_table[9];
      rotorC_table[10] <= rotorC_table[10];
      rotorC_table[11] <= rotorC_table[11];
      rotorC_table[12] <= rotorC_table[12];
      rotorC_table[13] <= rotorC_table[13];
      rotorC_table[14] <= rotorC_table[14];
      rotorC_table[15] <= rotorC_table[15];
      rotorC_table[16] <= rotorC_table[16];
      rotorC_table[17] <= rotorC_table[17];
      rotorC_table[18] <= rotorC_table[18];
      rotorC_table[19] <= rotorC_table[19];
      rotorC_table[20] <= rotorC_table[20];
      rotorC_table[21] <= rotorC_table[21];
      rotorC_table[22] <= rotorC_table[22];
      rotorC_table[23] <= rotorC_table[23];
      rotorC_table[24] <= rotorC_table[24];
      rotorC_table[25] <= rotorC_table[25];
      rotorC_table[26] <= rotorC_table[26];
      rotorC_table[27] <= rotorC_table[27];
      rotorC_table[28] <= rotorC_table[28];
      rotorC_table[29] <= rotorC_table[29];
      rotorC_table[30] <= rotorC_table[30];
      rotorC_table[31] <= rotorC_table[31];
      rotorC_table[32] <= rotorC_table[32];
      rotorC_table[33] <= rotorC_table[33];
      rotorC_table[34] <= rotorC_table[34];
      rotorC_table[35] <= rotorC_table[35];
      rotorC_table[36] <= rotorC_table[36];
      rotorC_table[37] <= rotorC_table[37];
      rotorC_table[38] <= rotorC_table[38];
      rotorC_table[39] <= rotorC_table[39];
      rotorC_table[40] <= rotorC_table[40];
      rotorC_table[41] <= rotorC_table[41];
      rotorC_table[42] <= rotorC_table[42];
      rotorC_table[43] <= rotorC_table[43];
      rotorC_table[44] <= rotorC_table[44];
      rotorC_table[45] <= rotorC_table[45];
      rotorC_table[46] <= rotorC_table[46];
      rotorC_table[47] <= rotorC_table[47];
      rotorC_table[48] <= rotorC_table[48];
      rotorC_table[49] <= rotorC_table[49];
      rotorC_table[50] <= rotorC_table[50];
      rotorC_table[51] <= rotorC_table[51];
      rotorC_table[52] <= rotorC_table[52];
      rotorC_table[53] <= rotorC_table[53];
      rotorC_table[54] <= rotorC_table[54];
      rotorC_table[55] <= rotorC_table[55];
      rotorC_table[56] <= rotorC_table[56];
      rotorC_table[57] <= rotorC_table[57];
      rotorC_table[58] <= rotorC_table[58];
      rotorC_table[59] <= rotorC_table[59];
      rotorC_table[60] <= rotorC_table[60];
      rotorC_table[61] <= rotorC_table[61];
      rotorC_table[62] <= rotorC_table[62];
      rotorC_table[63] <= rotorC_table[63];
    end
  end

  // rotorC output
  always@*
  begin
    rotC_o = rotorC_table[rotB_o];
  end

  // reflector lut
  always@*
  begin
    if(crypt_mode==0)
    begin
      ref_o = 6'd00;
      case(rotC_o)
        6'd0:
          ref_o = 6'd63;
        6'd1:
          ref_o = 6'd62;
        6'd2:
          ref_o = 6'd61;
        6'd3:
          ref_o = 6'd60;
        6'd4:
          ref_o = 6'd59;
        6'd5:
          ref_o = 6'd58;
        6'd6:
          ref_o = 6'd57;
        6'd7:
          ref_o = 6'd56;
        6'd8:
          ref_o = 6'd55;
        6'd9:
          ref_o = 6'd54;
        6'd10:
          ref_o = 6'd53;
        6'd11:
          ref_o = 6'd52;
        6'd12:
          ref_o = 6'd51;
        6'd13:
          ref_o = 6'd50;
        6'd14:
          ref_o = 6'd49;
        6'd15:
          ref_o = 6'd48;
        6'd16:
          ref_o = 6'd47;
        6'd17:
          ref_o = 6'd46;
        6'd18:
          ref_o = 6'd45;
        6'd19:
          ref_o = 6'd44;
        6'd20:
          ref_o = 6'd43;
        6'd21:
          ref_o = 6'd42;
        6'd22:
          ref_o = 6'd41;
        6'd23:
          ref_o = 6'd40;
        6'd24:
          ref_o = 6'd39;
        6'd25:
          ref_o = 6'd38;
        6'd26:
          ref_o = 6'd37;
        6'd27:
          ref_o = 6'd36;
        6'd28:
          ref_o = 6'd35;
        6'd29:
          ref_o = 6'd34;
        6'd30:
          ref_o = 6'd33;
        6'd31:
          ref_o = 6'd32;
        6'd32:
          ref_o = 6'd31;
        6'd33:
          ref_o = 6'd30;
        6'd34:
          ref_o = 6'd29;
        6'd35:
          ref_o = 6'd28;
        6'd36:
          ref_o = 6'd27;
        6'd37:
          ref_o = 6'd26;
        6'd38:
          ref_o = 6'd25;
        6'd39:
          ref_o = 6'd24;
        6'd40:
          ref_o = 6'd23;
        6'd41:
          ref_o = 6'd22;
        6'd42:
          ref_o = 6'd21;
        6'd43:
          ref_o = 6'd20;
        6'd44:
          ref_o = 6'd19;
        6'd45:
          ref_o = 6'd18;
        6'd46:
          ref_o = 6'd17;
        6'd47:
          ref_o = 6'd16;
        6'd48:
          ref_o = 6'd15;
        6'd49:
          ref_o = 6'd14;
        6'd50:
          ref_o = 6'd13;
        6'd51:
          ref_o = 6'd12;
        6'd52:
          ref_o = 6'd11;
        6'd53:
          ref_o = 6'd10;
        6'd54:
          ref_o = 6'd9;
        6'd55:
          ref_o = 6'd8;
        6'd56:
          ref_o = 6'd7;
        6'd57:
          ref_o = 6'd6;
        6'd58:
          ref_o = 6'd5;
        6'd59:
          ref_o = 6'd4;
        6'd60:
          ref_o = 6'd3;
        6'd61:
          ref_o = 6'd2;
        6'd62:
          ref_o = 6'd1;
        6'd63:
          ref_o = 6'd0;
      endcase
    end
    else
      ref_o = rotC_o;
  end

  // Inverse rotor: reflector to rotorC
  always@*
    if(crypt_mode==0)
    begin
      rotC_o_inv = ref_o;
    end
    else
    begin
      case(ref_o)
        6'd63:
          rotC_o_inv = 6'd0;
        6'd62:
          rotC_o_inv = 6'd1;
        6'd61:
          rotC_o_inv = 6'd2;
        6'd60:
          rotC_o_inv = 6'd3;
        6'd59:
          rotC_o_inv = 6'd4;
        6'd58:
          rotC_o_inv = 6'd5;
        6'd57:
          rotC_o_inv = 6'd6;
        6'd56:
          rotC_o_inv = 6'd7;
        6'd55:
          rotC_o_inv = 6'd8;
        6'd54:
          rotC_o_inv = 6'd9;
        6'd53:
          rotC_o_inv = 6'd10;
        6'd52:
          rotC_o_inv = 6'd11;
        6'd51:
          rotC_o_inv = 6'd12;
        6'd50:
          rotC_o_inv = 6'd13;
        6'd49:
          rotC_o_inv = 6'd14;
        6'd48:
          rotC_o_inv = 6'd15;
        6'd47:
          rotC_o_inv = 6'd16;
        6'd46:
          rotC_o_inv = 6'd17;
        6'd45:
          rotC_o_inv = 6'd18;
        6'd44:
          rotC_o_inv = 6'd19;
        6'd43:
          rotC_o_inv = 6'd20;
        6'd42:
          rotC_o_inv = 6'd21;
        6'd41:
          rotC_o_inv = 6'd22;
        6'd40:
          rotC_o_inv = 6'd23;
        6'd39:
          rotC_o_inv = 6'd24;
        6'd38:
          rotC_o_inv = 6'd25;
        6'd37:
          rotC_o_inv = 6'd26;
        6'd36:
          rotC_o_inv = 6'd27;
        6'd35:
          rotC_o_inv = 6'd28;
        6'd34:
          rotC_o_inv = 6'd29;
        6'd33:
          rotC_o_inv = 6'd30;
        6'd32:
          rotC_o_inv = 6'd31;
        6'd31:
          rotC_o_inv = 6'd32;
        6'd30:
          rotC_o_inv = 6'd33;
        6'd29:
          rotC_o_inv = 6'd34;
        6'd28:
          rotC_o_inv = 6'd35;
        6'd27:
          rotC_o_inv = 6'd36;
        6'd26:
          rotC_o_inv = 6'd37;
        6'd25:
          rotC_o_inv = 6'd38;
        6'd24:
          rotC_o_inv = 6'd39;
        6'd23:
          rotC_o_inv = 6'd40;
        6'd22:
          rotC_o_inv = 6'd41;
        6'd21:
          rotC_o_inv = 6'd42;
        6'd20:
          rotC_o_inv = 6'd43;
        6'd19:
          rotC_o_inv = 6'd44;
        6'd18:
          rotC_o_inv = 6'd45;
        6'd17:
          rotC_o_inv = 6'd46;
        6'd16:
          rotC_o_inv = 6'd47;
        6'd15:
          rotC_o_inv = 6'd48;
        6'd14:
          rotC_o_inv = 6'd49;
        6'd13:
          rotC_o_inv = 6'd50;
        6'd12:
          rotC_o_inv = 6'd51;
        6'd11:
          rotC_o_inv = 6'd52;
        6'd10:
          rotC_o_inv = 6'd53;
        6'd9:
          rotC_o_inv = 6'd54;
        6'd8:
          rotC_o_inv = 6'd55;
        6'd7:
          rotC_o_inv = 6'd56;
        6'd6:
          rotC_o_inv = 6'd57;
        6'd5:
          rotC_o_inv = 6'd58;
        6'd4:
          rotC_o_inv = 6'd59;
        6'd3:
          rotC_o_inv = 6'd60;
        6'd2:
          rotC_o_inv = 6'd61;
        6'd1:
          rotC_o_inv = 6'd62;
        6'd0:
          rotC_o_inv = 6'd63;
      endcase
    end

  // Inverse rotor rotorC to rotorB
  always@*
    if(rotC_o_inv==rotorC_table[0])
    begin
      rotB_o_inv = 0;
    end
    else if(rotC_o_inv==rotorC_table[1])
    begin
      rotB_o_inv = 1;
    end
    else if(rotC_o_inv==rotorC_table[2])
    begin
      rotB_o_inv = 2;
    end
    else if(rotC_o_inv==rotorC_table[3])
    begin
      rotB_o_inv = 3;
    end
    else if(rotC_o_inv==rotorC_table[4])
    begin
      rotB_o_inv = 4;
    end
    else if(rotC_o_inv==rotorC_table[5])
    begin
      rotB_o_inv = 5;
    end
    else if(rotC_o_inv==rotorC_table[6])
    begin
      rotB_o_inv = 6;
    end
    else if(rotC_o_inv==rotorC_table[7])
    begin
      rotB_o_inv = 7;
    end
    else if(rotC_o_inv==rotorC_table[8])
    begin
      rotB_o_inv = 8;
    end
    else if(rotC_o_inv==rotorC_table[9])
    begin
      rotB_o_inv = 9;
    end
    else if(rotC_o_inv==rotorC_table[10])
    begin
      rotB_o_inv = 10;
    end
    else if(rotC_o_inv==rotorC_table[11])
    begin
      rotB_o_inv = 11;
    end
    else if(rotC_o_inv==rotorC_table[12])
    begin
      rotB_o_inv = 12;
    end
    else if(rotC_o_inv==rotorC_table[13])
    begin
      rotB_o_inv = 13;
    end
    else if(rotC_o_inv==rotorC_table[14])
    begin
      rotB_o_inv = 14;
    end
    else if(rotC_o_inv==rotorC_table[15])
    begin
      rotB_o_inv = 15;
    end
    else if(rotC_o_inv==rotorC_table[16])
    begin
      rotB_o_inv = 16;
    end
    else if(rotC_o_inv==rotorC_table[17])
    begin
      rotB_o_inv = 17;
    end
    else if(rotC_o_inv==rotorC_table[18])
    begin
      rotB_o_inv = 18;
    end
    else if(rotC_o_inv==rotorC_table[19])
    begin
      rotB_o_inv = 19;
    end
    else if(rotC_o_inv==rotorC_table[20])
    begin
      rotB_o_inv = 20;
    end
    else if(rotC_o_inv==rotorC_table[21])
    begin
      rotB_o_inv = 21;
    end
    else if(rotC_o_inv==rotorC_table[22])
    begin
      rotB_o_inv = 22;
    end
    else if(rotC_o_inv==rotorC_table[23])
    begin
      rotB_o_inv = 23;
    end
    else if(rotC_o_inv==rotorC_table[24])
    begin
      rotB_o_inv = 24;
    end
    else if(rotC_o_inv==rotorC_table[25])
    begin
      rotB_o_inv = 25;
    end
    else if(rotC_o_inv==rotorC_table[26])
    begin
      rotB_o_inv = 26;
    end
    else if(rotC_o_inv==rotorC_table[27])
    begin
      rotB_o_inv = 27;
    end
    else if(rotC_o_inv==rotorC_table[28])
    begin
      rotB_o_inv = 28;
    end
    else if(rotC_o_inv==rotorC_table[29])
    begin
      rotB_o_inv = 29;
    end
    else if(rotC_o_inv==rotorC_table[30])
    begin
      rotB_o_inv = 30;
    end
    else if(rotC_o_inv==rotorC_table[31])
    begin
      rotB_o_inv = 31;
    end
    else if(rotC_o_inv==rotorC_table[32])
    begin
      rotB_o_inv = 32;
    end
    else if(rotC_o_inv==rotorC_table[33])
    begin
      rotB_o_inv = 33;
    end
    else if(rotC_o_inv==rotorC_table[34])
    begin
      rotB_o_inv = 34;
    end
    else if(rotC_o_inv==rotorC_table[35])
    begin
      rotB_o_inv = 35;
    end
    else if(rotC_o_inv==rotorC_table[36])
    begin
      rotB_o_inv = 36;
    end
    else if(rotC_o_inv==rotorC_table[37])
    begin
      rotB_o_inv = 37;
    end
    else if(rotC_o_inv==rotorC_table[38])
    begin
      rotB_o_inv = 38;
    end
    else if(rotC_o_inv==rotorC_table[39])
    begin
      rotB_o_inv = 39;
    end
    else if(rotC_o_inv==rotorC_table[40])
    begin
      rotB_o_inv = 40;
    end
    else if(rotC_o_inv==rotorC_table[41])
    begin
      rotB_o_inv = 41;
    end
    else if(rotC_o_inv==rotorC_table[42])
    begin
      rotB_o_inv = 42;
    end
    else if(rotC_o_inv==rotorC_table[43])
    begin
      rotB_o_inv = 43;
    end
    else if(rotC_o_inv==rotorC_table[44])
    begin
      rotB_o_inv = 44;
    end
    else if(rotC_o_inv==rotorC_table[45])
    begin
      rotB_o_inv = 45;
    end
    else if(rotC_o_inv==rotorC_table[46])
    begin
      rotB_o_inv = 46;
    end
    else if(rotC_o_inv==rotorC_table[47])
    begin
      rotB_o_inv = 47;
    end
    else if(rotC_o_inv==rotorC_table[48])
    begin
      rotB_o_inv = 48;
    end
    else if(rotC_o_inv==rotorC_table[49])
    begin
      rotB_o_inv = 49;
    end
    else if(rotC_o_inv==rotorC_table[50])
    begin
      rotB_o_inv = 50;
    end
    else if(rotC_o_inv==rotorC_table[51])
    begin
      rotB_o_inv = 51;
    end
    else if(rotC_o_inv==rotorC_table[52])
    begin
      rotB_o_inv = 52;
    end
    else if(rotC_o_inv==rotorC_table[53])
    begin
      rotB_o_inv = 53;
    end
    else if(rotC_o_inv==rotorC_table[54])
    begin
      rotB_o_inv = 54;
    end
    else if(rotC_o_inv==rotorC_table[55])
    begin
      rotB_o_inv = 55;
    end
    else if(rotC_o_inv==rotorC_table[56])
    begin
      rotB_o_inv = 56;
    end
    else if(rotC_o_inv==rotorC_table[57])
    begin
      rotB_o_inv = 57;
    end
    else if(rotC_o_inv==rotorC_table[58])
    begin
      rotB_o_inv = 58;
    end
    else if(rotC_o_inv==rotorC_table[59])
    begin
      rotB_o_inv = 59;
    end
    else if(rotC_o_inv==rotorC_table[60])
    begin
      rotB_o_inv = 60;
    end
    else if(rotC_o_inv==rotorC_table[61])
    begin
      rotB_o_inv = 61;
    end
    else if(rotC_o_inv==rotorC_table[62])
    begin
      rotB_o_inv = 62;
    end
    else
    begin
      rotB_o_inv = 63;
    end

  // Inverse rotor rotorB to rotorA
  always@*
    if(rotB_o_inv==rotorB_table[0])
    begin
      rotA_o_inv = 0;
    end
    else if(rotB_o_inv==rotorB_table[1])
    begin
      rotA_o_inv = 1;
    end
    else if(rotB_o_inv==rotorB_table[2])
    begin
      rotA_o_inv = 2;
    end
    else if(rotB_o_inv==rotorB_table[3])
    begin
      rotA_o_inv = 3;
    end
    else if(rotB_o_inv==rotorB_table[4])
    begin
      rotA_o_inv = 4;
    end
    else if(rotB_o_inv==rotorB_table[5])
    begin
      rotA_o_inv = 5;
    end
    else if(rotB_o_inv==rotorB_table[6])
    begin
      rotA_o_inv = 6;
    end
    else if(rotB_o_inv==rotorB_table[7])
    begin
      rotA_o_inv = 7;
    end
    else if(rotB_o_inv==rotorB_table[8])
    begin
      rotA_o_inv = 8;
    end
    else if(rotB_o_inv==rotorB_table[9])
    begin
      rotA_o_inv = 9;
    end
    else if(rotB_o_inv==rotorB_table[10])
    begin
      rotA_o_inv = 10;
    end
    else if(rotB_o_inv==rotorB_table[11])
    begin
      rotA_o_inv = 11;
    end
    else if(rotB_o_inv==rotorB_table[12])
    begin
      rotA_o_inv = 12;
    end
    else if(rotB_o_inv==rotorB_table[13])
    begin
      rotA_o_inv = 13;
    end
    else if(rotB_o_inv==rotorB_table[14])
    begin
      rotA_o_inv = 14;
    end
    else if(rotB_o_inv==rotorB_table[15])
    begin
      rotA_o_inv = 15;
    end
    else if(rotB_o_inv==rotorB_table[16])
    begin
      rotA_o_inv = 16;
    end
    else if(rotB_o_inv==rotorB_table[17])
    begin
      rotA_o_inv = 17;
    end
    else if(rotB_o_inv==rotorB_table[18])
    begin
      rotA_o_inv = 18;
    end
    else if(rotB_o_inv==rotorB_table[19])
    begin
      rotA_o_inv = 19;
    end
    else if(rotB_o_inv==rotorB_table[20])
    begin
      rotA_o_inv = 20;
    end
    else if(rotB_o_inv==rotorB_table[21])
    begin
      rotA_o_inv = 21;
    end
    else if(rotB_o_inv==rotorB_table[22])
    begin
      rotA_o_inv = 22;
    end
    else if(rotB_o_inv==rotorB_table[23])
    begin
      rotA_o_inv = 23;
    end
    else if(rotB_o_inv==rotorB_table[24])
    begin
      rotA_o_inv = 24;
    end
    else if(rotB_o_inv==rotorB_table[25])
    begin
      rotA_o_inv = 25;
    end
    else if(rotB_o_inv==rotorB_table[26])
    begin
      rotA_o_inv = 26;
    end
    else if(rotB_o_inv==rotorB_table[27])
    begin
      rotA_o_inv = 27;
    end
    else if(rotB_o_inv==rotorB_table[28])
    begin
      rotA_o_inv = 28;
    end
    else if(rotB_o_inv==rotorB_table[29])
    begin
      rotA_o_inv = 29;
    end
    else if(rotB_o_inv==rotorB_table[30])
    begin
      rotA_o_inv = 30;
    end
    else if(rotB_o_inv==rotorB_table[31])
    begin
      rotA_o_inv = 31;
    end
    else if(rotB_o_inv==rotorB_table[32])
    begin
      rotA_o_inv = 32;
    end
    else if(rotB_o_inv==rotorB_table[33])
    begin
      rotA_o_inv = 33;
    end
    else if(rotB_o_inv==rotorB_table[34])
    begin
      rotA_o_inv = 34;
    end
    else if(rotB_o_inv==rotorB_table[35])
    begin
      rotA_o_inv = 35;
    end
    else if(rotB_o_inv==rotorB_table[36])
    begin
      rotA_o_inv = 36;
    end
    else if(rotB_o_inv==rotorB_table[37])
    begin
      rotA_o_inv = 37;
    end
    else if(rotB_o_inv==rotorB_table[38])
    begin
      rotA_o_inv = 38;
    end
    else if(rotB_o_inv==rotorB_table[39])
    begin
      rotA_o_inv = 39;
    end
    else if(rotB_o_inv==rotorB_table[40])
    begin
      rotA_o_inv = 40;
    end
    else if(rotB_o_inv==rotorB_table[41])
    begin
      rotA_o_inv = 41;
    end
    else if(rotB_o_inv==rotorB_table[42])
    begin
      rotA_o_inv = 42;
    end
    else if(rotB_o_inv==rotorB_table[43])
    begin
      rotA_o_inv = 43;
    end
    else if(rotB_o_inv==rotorB_table[44])
    begin
      rotA_o_inv = 44;
    end
    else if(rotB_o_inv==rotorB_table[45])
    begin
      rotA_o_inv = 45;
    end
    else if(rotB_o_inv==rotorB_table[46])
    begin
      rotA_o_inv = 46;
    end
    else if(rotB_o_inv==rotorB_table[47])
    begin
      rotA_o_inv = 47;
    end
    else if(rotB_o_inv==rotorB_table[48])
    begin
      rotA_o_inv = 48;
    end
    else if(rotB_o_inv==rotorB_table[49])
    begin
      rotA_o_inv = 49;
    end
    else if(rotB_o_inv==rotorB_table[50])
    begin
      rotA_o_inv = 50;
    end
    else if(rotB_o_inv==rotorB_table[51])
    begin
      rotA_o_inv = 51;
    end
    else if(rotB_o_inv==rotorB_table[52])
    begin
      rotA_o_inv = 52;
    end
    else if(rotB_o_inv==rotorB_table[53])
    begin
      rotA_o_inv = 53;
    end
    else if(rotB_o_inv==rotorB_table[54])
    begin
      rotA_o_inv = 54;
    end
    else if(rotB_o_inv==rotorB_table[55])
    begin
      rotA_o_inv = 55;
    end
    else if(rotB_o_inv==rotorB_table[56])
    begin
      rotA_o_inv = 56;
    end
    else if(rotB_o_inv==rotorB_table[57])
    begin
      rotA_o_inv = 57;
    end
    else if(rotB_o_inv==rotorB_table[58])
    begin
      rotA_o_inv = 58;
    end
    else if(rotB_o_inv==rotorB_table[59])
    begin
      rotA_o_inv = 59;
    end
    else if(rotB_o_inv==rotorB_table[60])
    begin
      rotA_o_inv = 60;
    end
    else if(rotB_o_inv==rotorB_table[61])
    begin
      rotA_o_inv = 61;
    end
    else if(rotB_o_inv==rotorB_table[62])
    begin
      rotA_o_inv = 62;
    end
    else
    begin
      rotA_o_inv = 63;
    end

  // Inverse rotor rotorA to output
  always@*
    if(rotA_o_inv==rotorA_table[0])
    begin
      code_out_tmp = 0;

    end
    else if(rotA_o_inv==rotorA_table[1])
    begin
      code_out_tmp = 1;

    end
    else if(rotA_o_inv==rotorA_table[2])
    begin
      code_out_tmp = 2;

    end
    else if(rotA_o_inv==rotorA_table[3])
    begin
      code_out_tmp = 3;

    end
    else if(rotA_o_inv==rotorA_table[4])
    begin
      code_out_tmp = 4;

    end
    else if(rotA_o_inv==rotorA_table[5])
    begin
      code_out_tmp = 5;

    end
    else if(rotA_o_inv==rotorA_table[6])
    begin
      code_out_tmp = 6;

    end
    else if(rotA_o_inv==rotorA_table[7])
    begin
      code_out_tmp = 7;

    end
    else if(rotA_o_inv==rotorA_table[8])
    begin
      code_out_tmp = 8;

    end
    else if(rotA_o_inv==rotorA_table[9])
    begin
      code_out_tmp = 9;

    end
    else if(rotA_o_inv==rotorA_table[10])
    begin
      code_out_tmp = 10;

    end
    else if(rotA_o_inv==rotorA_table[11])
    begin
      code_out_tmp = 11;

    end
    else if(rotA_o_inv==rotorA_table[12])
    begin
      code_out_tmp = 12;

    end
    else if(rotA_o_inv==rotorA_table[13])
    begin
      code_out_tmp = 13;

    end
    else if(rotA_o_inv==rotorA_table[14])
    begin
      code_out_tmp = 14;

    end
    else if(rotA_o_inv==rotorA_table[15])
    begin
      code_out_tmp = 15;

    end
    else if(rotA_o_inv==rotorA_table[16])
    begin
      code_out_tmp = 16;

    end
    else if(rotA_o_inv==rotorA_table[17])
    begin
      code_out_tmp = 17;

    end
    else if(rotA_o_inv==rotorA_table[18])
    begin
      code_out_tmp = 18;

    end
    else if(rotA_o_inv==rotorA_table[19])
    begin
      code_out_tmp = 19;

    end
    else if(rotA_o_inv==rotorA_table[20])
    begin
      code_out_tmp = 20;

    end
    else if(rotA_o_inv==rotorA_table[21])
    begin
      code_out_tmp = 21;

    end
    else if(rotA_o_inv==rotorA_table[22])
    begin
      code_out_tmp = 22;

    end
    else if(rotA_o_inv==rotorA_table[23])
    begin
      code_out_tmp = 23;

    end
    else if(rotA_o_inv==rotorA_table[24])
    begin
      code_out_tmp = 24;

    end
    else if(rotA_o_inv==rotorA_table[25])
    begin
      code_out_tmp = 25;

    end
    else if(rotA_o_inv==rotorA_table[26])
    begin
      code_out_tmp = 26;

    end
    else if(rotA_o_inv==rotorA_table[27])
    begin
      code_out_tmp = 27;

    end
    else if(rotA_o_inv==rotorA_table[28])
    begin
      code_out_tmp = 28;

    end
    else if(rotA_o_inv==rotorA_table[29])
    begin
      code_out_tmp = 29;

    end
    else if(rotA_o_inv==rotorA_table[30])
    begin
      code_out_tmp = 30;

    end
    else if(rotA_o_inv==rotorA_table[31])
    begin
      code_out_tmp = 31;

    end
    else if(rotA_o_inv==rotorA_table[32])
    begin
      code_out_tmp = 32;

    end
    else if(rotA_o_inv==rotorA_table[33])
    begin
      code_out_tmp = 33;

    end
    else if(rotA_o_inv==rotorA_table[34])
    begin
      code_out_tmp = 34;

    end
    else if(rotA_o_inv==rotorA_table[35])
    begin
      code_out_tmp = 35;

    end
    else if(rotA_o_inv==rotorA_table[36])
    begin
      code_out_tmp = 36;

    end
    else if(rotA_o_inv==rotorA_table[37])
    begin
      code_out_tmp = 37;

    end
    else if(rotA_o_inv==rotorA_table[38])
    begin
      code_out_tmp = 38;

    end
    else if(rotA_o_inv==rotorA_table[39])
    begin
      code_out_tmp = 39;

    end
    else if(rotA_o_inv==rotorA_table[40])
    begin
      code_out_tmp = 40;

    end
    else if(rotA_o_inv==rotorA_table[41])
    begin
      code_out_tmp = 41;

    end
    else if(rotA_o_inv==rotorA_table[42])
    begin
      code_out_tmp = 42;

    end
    else if(rotA_o_inv==rotorA_table[43])
    begin
      code_out_tmp = 43;

    end
    else if(rotA_o_inv==rotorA_table[44])
    begin
      code_out_tmp = 44;

    end
    else if(rotA_o_inv==rotorA_table[45])
    begin
      code_out_tmp = 45;

    end
    else if(rotA_o_inv==rotorA_table[46])
    begin
      code_out_tmp = 46;

    end
    else if(rotA_o_inv==rotorA_table[47])
    begin
      code_out_tmp = 47;

    end
    else if(rotA_o_inv==rotorA_table[48])
    begin
      code_out_tmp = 48;

    end
    else if(rotA_o_inv==rotorA_table[49])
    begin
      code_out_tmp = 49;

    end
    else if(rotA_o_inv==rotorA_table[50])
    begin
      code_out_tmp = 50;

    end

    else if(rotA_o_inv==rotorA_table[51])
    begin
      code_out_tmp = 51;

    end
    else if(rotA_o_inv==rotorA_table[52])
    begin
      code_out_tmp = 52;

    end
    else if(rotA_o_inv==rotorA_table[53])
    begin
      code_out_tmp = 53;

    end
    else if(rotA_o_inv==rotorA_table[54])
    begin
      code_out_tmp = 54;

    end
    else if(rotA_o_inv==rotorA_table[55])
    begin
      code_out_tmp = 55;

    end
    else if(rotA_o_inv==rotorA_table[56])
    begin
      code_out_tmp = 56;

    end
    else if(rotA_o_inv==rotorA_table[57])
    begin
      code_out_tmp = 57;

    end
    else if(rotA_o_inv==rotorA_table[58])
    begin
      code_out_tmp = 58;

    end
    else if(rotA_o_inv==rotorA_table[59])
    begin
      code_out_tmp = 59;

    end
    else if(rotA_o_inv==rotorA_table[60])
    begin
      code_out_tmp = 60;

    end
    else if(rotA_o_inv==rotorA_table[61])
    begin
      code_out_tmp = 61;

    end
    else if(rotA_o_inv==rotorA_table[62])
    begin
      code_out_tmp = 62;

    end
    else
    begin
      code_out_tmp = 63;

    end

  // flip-flop output
  always@(posedge clk)
    if(~srstn)
    begin
      code_out <= 0;
      code_valid <=0;
    end
    else
    begin
      code_out <= code_out_tmp;
      code_valid <= code_valid_tmp;
    end

endmodule
