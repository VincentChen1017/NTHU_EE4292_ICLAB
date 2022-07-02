module ecc(
    input clk,
    input srstn,
    input [351:0] codeword,
    input ecc_valid,
		output reg ECC_done,
		output reg [351:0] correct_codeword
  );
  integer  i,j;
  reg [8:0] an_codeword[0:43];
  wire [8:0] an_value;
  reg [7:0] codeword_array[0:43];
  reg [5:0] code_cnt;
  reg [7:0] S0, S1, S2, S3, S4, S5, S6, S7;
  wire [8:0] S_i [0:7]; // represent S's power value
  wire [7:0] a[0:255];
	reg load_done, nload_done;

  ///// antilog tabel /////
  assign a[0] = 1;
  assign a[1] = 2;
  assign a[2] = 4;
  assign a[3] = 8;
  assign a[4] = 16;
  assign a[5] = 32;
  assign a[6] = 64;
  assign a[7] = 128;
  assign a[8] = 29;
  assign a[9] = 58;
  assign a[10] = 116;
  assign a[11] = 232;
  assign a[12] = 205;
  assign a[13] = 135;
  assign a[14] = 19;
  assign a[15] = 38;
  assign a[16] = 76;
  assign a[17] = 152;
  assign a[18] = 45;
  assign a[19] = 90;
  assign a[20] = 180;
  assign a[21] = 117;
  assign a[22] = 234;
  assign a[23] = 201;
  assign a[24] = 143;
  assign a[25] = 3;
  assign a[26] = 6;
  assign a[27] = 12;
  assign a[28] = 24;
  assign a[29] = 48;
  assign a[30] = 96;
  assign a[31] = 192;
  assign a[32] = 157;
  assign a[33] = 39;
  assign a[34] = 78;
  assign a[35] = 156;
  assign a[36] = 37;
  assign a[37] = 74;
  assign a[38] = 148;
  assign a[39] = 53;
  assign a[40] = 106;
  assign a[41] = 212;
  assign a[42] = 181;
  assign a[43] = 119;
  assign a[44] = 238;
  assign a[45] = 193;
  assign a[46] = 159;
  assign a[47] = 35;
  assign a[48] = 70;
  assign a[49] = 140;
  assign a[50] = 5;
  assign a[51] = 10;
  assign a[52] = 20;
  assign a[53] = 40;
  assign a[54] = 80;
  assign a[55] = 160;
  assign a[56] = 93;
  assign a[57] = 186;
  assign a[58] = 105;
  assign a[59] = 210;
  assign a[60] = 185;
  assign a[61] = 111;
  assign a[62] = 222;
  assign a[63] = 161;
  assign a[64] = 95;
  assign a[65] = 190;
  assign a[66] = 97;
  assign a[67] = 194;
  assign a[68] = 153;
  assign a[69] = 47;
  assign a[70] = 94;
  assign a[71] = 188;
  assign a[72] = 101;
  assign a[73] = 202;
  assign a[74] = 137;
  assign a[75] = 15;
  assign a[76] = 30;
  assign a[77] = 60;
  assign a[78] = 120;
  assign a[79] = 240;
  assign a[80] = 253;
  assign a[81] = 231;
  assign a[82] = 211;
  assign a[83] = 187;
  assign a[84] = 107;
  assign a[85] = 214;
  assign a[86] = 177;
  assign a[87] = 127;
  assign a[88] = 254;
  assign a[89] = 225;
  assign a[90] = 223;
  assign a[91] = 163;
  assign a[92] = 91;
  assign a[93] = 182;
  assign a[94] = 113;
  assign a[95] = 226;
  assign a[96] = 217;
  assign a[97] = 175;
  assign a[98] = 67;
  assign a[99] = 134;
  assign a[100] = 17;
  assign a[101] = 34;
  assign a[102] = 68;
  assign a[103] = 136;
  assign a[104] = 13;
  assign a[105] = 26;
  assign a[106] = 52;
  assign a[107] = 104;
  assign a[108] = 208;
  assign a[109] = 189;
  assign a[110] = 103;
  assign a[111] = 206;
  assign a[112] = 129;
  assign a[113] = 31;
  assign a[114] = 62;
  assign a[115] = 124;
  assign a[116] = 248;
  assign a[117] = 237;
  assign a[118] = 199;
  assign a[119] = 147;
  assign a[120] = 59;
  assign a[121] = 118;
  assign a[122] = 236;
  assign a[123] = 197;
  assign a[124] = 151;
  assign a[125] = 51;
  assign a[126] = 102;
  assign a[127] = 204;
  assign a[128] = 133;
  assign a[129] = 23;
  assign a[130] = 46;
  assign a[131] = 92;
  assign a[132] = 184;
  assign a[133] = 109;
  assign a[134] = 218;
  assign a[135] = 169;
  assign a[136] = 79;
  assign a[137] = 158;
  assign a[138] = 33;
  assign a[139] = 66;
  assign a[140] = 132;
  assign a[141] = 21;
  assign a[142] = 42;
  assign a[143] = 84;
  assign a[144] = 168;
  assign a[145] = 77;
  assign a[146] = 154;
  assign a[147] = 41;
  assign a[148] = 82;
  assign a[149] = 164;
  assign a[150] = 85;
  assign a[151] = 170;
  assign a[152] = 73;
  assign a[153] = 146;
  assign a[154] = 57;
  assign a[155] = 114;
  assign a[156] = 228;
  assign a[157] = 213;
  assign a[158] = 183;
  assign a[159] = 115;
  assign a[160] = 230;
  assign a[161] = 209;
  assign a[162] = 191;
  assign a[163] = 99;
  assign a[164] = 198;
  assign a[165] = 145;
  assign a[166] = 63;
  assign a[167] = 126;
  assign a[168] = 252;
  assign a[169] = 229;
  assign a[170] = 215;
  assign a[171] = 179;
  assign a[172] = 123;
  assign a[173] = 246;
  assign a[174] = 241;
  assign a[175] = 255;
  assign a[176] = 227;
  assign a[177] = 219;
  assign a[178] = 171;
  assign a[179] = 75;
  assign a[180] = 150;
  assign a[181] = 49;
  assign a[182] = 98;
  assign a[183] = 196;
  assign a[184] = 149;
  assign a[185] = 55;
  assign a[186] = 110;
  assign a[187] = 220;
  assign a[188] = 165;
  assign a[189] = 87;
  assign a[190] = 174;
  assign a[191] = 65;
  assign a[192] = 130;
  assign a[193] = 25;
  assign a[194] = 50;
  assign a[195] = 100;
  assign a[196] = 200;
  assign a[197] = 141;
  assign a[198] = 7;
  assign a[199] = 14;
  assign a[200] = 28;
  assign a[201] = 56;
  assign a[202] = 112;
  assign a[203] = 224;
  assign a[204] = 221;
  assign a[205] = 167;
  assign a[206] = 83;
  assign a[207] = 166;
  assign a[208] = 81;
  assign a[209] = 162;
  assign a[210] = 89;
  assign a[211] = 178;
  assign a[212] = 121;
  assign a[213] = 242;
  assign a[214] = 249;
  assign a[215] = 239;
  assign a[216] = 195;
  assign a[217] = 155;
  assign a[218] = 43;
  assign a[219] = 86;
  assign a[220] = 172;
  assign a[221] = 69;
  assign a[222] = 138;
  assign a[223] = 9;
  assign a[224] = 18;
  assign a[225] = 36;
  assign a[226] = 72;
  assign a[227] = 144;
  assign a[228] = 61;
  assign a[229] = 122;
  assign a[230] = 244;
  assign a[231] = 245;
  assign a[232] = 247;
  assign a[233] = 243;
  assign a[234] = 251;
  assign a[235] = 235;
  assign a[236] = 203;
  assign a[237] = 139;
  assign a[238] = 11;
  assign a[239] = 22;
  assign a[240] = 44;
  assign a[241] = 88;
  assign a[242] = 176;
  assign a[243] = 125;
  assign a[244] = 250;
  assign a[245] = 233;
  assign a[246] = 207;
  assign a[247] = 131;
  assign a[248] = 27;
  assign a[249] = 54;
  assign a[250] = 108;
  assign a[251] = 216;
  assign a[252] = 173;
  assign a[253] = 71;
  assign a[254] = 142;
  assign a[255] = 1;
  /////////////////////////

  ///// 1.convert the error codewords to a^n notation  2.store codeword to 43 array /////
  always@(posedge clk)
    if(~srstn) begin
      code_cnt <= 0;
			load_done <= 0;
    end
    else if(ecc_valid && code_cnt!=43) begin
      code_cnt <= code_cnt + 1;
    end
    else  begin
      code_cnt <= code_cnt;
			load_done <= nload_done;
    end
      
  // 1+2:
  always@* begin
		if(code_cnt==43)
			nload_done = 1;
		else
			nload_done = 0;
	end
	
	always@*
		for(i=0; i<44; i=i+1)
			codeword_array[i] = {codeword[7+i*8], codeword[6+i*8], codeword[5+i*8], codeword[4+i*8],codeword[3+i*8], codeword[2+i*8], codeword[1+i*8], codeword[0+i*8]};

	always@(posedge clk) begin
		if(ecc_valid)begin
			an_codeword[code_cnt] <= an_value;
		end
	end
  convert_table
    convert_table0(
      .integer_value(codeword_array[code_cnt]), // input integer
      .an_value(an_value) // an_value
    );
  ///////////////////////////////////////////////////////////////////////////////////////////////////

  ///// calculate the syndrome /////
  //S0
  always@*
  begin
    S0 = codeword_array[0] ^ codeword_array[1] ^ codeword_array[2] ^ codeword_array[3] ^ codeword_array[4] ^ codeword_array[5] ^
       codeword_array[6] ^ codeword_array[7] ^ codeword_array[8] ^ codeword_array[9] ^ codeword_array[10] ^ codeword_array[11] ^
       codeword_array[12] ^ codeword_array[13] ^ codeword_array[14] ^ codeword_array[15] ^ codeword_array[16] ^ codeword_array[17] ^
       codeword_array[18] ^ codeword_array[19] ^ codeword_array[20] ^ codeword_array[21] ^ codeword_array[22] ^ codeword_array[23] ^
       codeword_array[24] ^ codeword_array[25] ^ codeword_array[26] ^ codeword_array[27] ^ codeword_array[28] ^ codeword_array[29] ^
       codeword_array[30] ^ codeword_array[31] ^ codeword_array[32] ^ codeword_array[33] ^ codeword_array[34] ^ codeword_array[35] ^
       codeword_array[36] ^ codeword_array[37] ^ codeword_array[38] ^ codeword_array[39] ^ codeword_array[40] ^ codeword_array[41] ^
       codeword_array[42] ^ codeword_array[43];
  end
  convert_table
    convert_table_S0(
      .integer_value(S0), // input integer
      .an_value(S_i[0]) // an_value
    );

  // S1
  reg [8:0] coeffi_S1_a [0:43]; // represent a^n
  always@*
  begin
    for(i=0; i<44; i=i+1)
      if( (an_codeword[i]+(43-i)) < 256)
        coeffi_S1_a[i] = an_codeword[i] + (43-i);
      else
        coeffi_S1_a[i] = (an_codeword[i] + (43-i)) % 255 ;

    S1 = a[coeffi_S1_a[0][7:0]] ^ a[coeffi_S1_a[1][7:0]] ^ a[coeffi_S1_a[2][7:0]]  ^ a[coeffi_S1_a[3][7:0]]  ^ a[coeffi_S1_a[4][7:0]]  ^ a[coeffi_S1_a[5][7:0]] ^
       a[coeffi_S1_a[6][7:0]]  ^ a[coeffi_S1_a[7][7:0]]  ^ a[coeffi_S1_a[8][7:0]]  ^ a[coeffi_S1_a[9][7:0]]  ^ a[coeffi_S1_a[10][7:0]] ^ a[coeffi_S1_a[11][7:0]] ^
       a[coeffi_S1_a[12][7:0]] ^ a[coeffi_S1_a[13][7:0]] ^ a[coeffi_S1_a[14][7:0]] ^ a[coeffi_S1_a[15][7:0]] ^ a[coeffi_S1_a[16][7:0]] ^ a[coeffi_S1_a[17][7:0]] ^
       a[coeffi_S1_a[18][7:0]] ^ a[coeffi_S1_a[19][7:0]] ^ a[coeffi_S1_a[20][7:0]] ^ a[coeffi_S1_a[21][7:0]] ^ a[coeffi_S1_a[22][7:0]] ^ a[coeffi_S1_a[23][7:0]] ^
       a[coeffi_S1_a[24][7:0]] ^ a[coeffi_S1_a[25][7:0]] ^ a[coeffi_S1_a[26][7:0]] ^ a[coeffi_S1_a[27][7:0]] ^ a[coeffi_S1_a[28][7:0]] ^ a[coeffi_S1_a[29][7:0]] ^
       a[coeffi_S1_a[30][7:0]] ^ a[coeffi_S1_a[31][7:0]] ^ a[coeffi_S1_a[32][7:0]] ^ a[coeffi_S1_a[33][7:0]] ^ a[coeffi_S1_a[34][7:0]] ^ a[coeffi_S1_a[35][7:0]] ^
       a[coeffi_S1_a[36][7:0]] ^ a[coeffi_S1_a[37][7:0]] ^ a[coeffi_S1_a[38][7:0]] ^ a[coeffi_S1_a[39][7:0]] ^ a[coeffi_S1_a[40][7:0]] ^ a[coeffi_S1_a[41][7:0]] ^
       a[coeffi_S1_a[42][7:0]] ^ a[coeffi_S1_a[43][7:0]];
  end
  convert_table
    convert_table_S1(
      .integer_value(S1), // input integer
      .an_value(S_i[1]) // an_value
    );

  // S2
  reg [8:0] coeffi_S2_a [0:43]; // represent a^n
  always@*
  begin
    for(i=0; i<44; i=i+1)
      if( (an_codeword[i]+(43-i)*2) < 256)
        coeffi_S2_a[i] = an_codeword[i] + (43-i)*2;
      else
        coeffi_S2_a[i] = (an_codeword[i] + (43-i)*2) % 255 ;

    S2 = a[coeffi_S2_a[0][7:0]] ^ a[coeffi_S2_a[1][7:0]] ^ a[coeffi_S2_a[2][7:0]]  ^ a[coeffi_S2_a[3][7:0]]  ^ a[coeffi_S2_a[4][7:0]]  ^ a[coeffi_S2_a[5][7:0]] ^
       a[coeffi_S2_a[6][7:0]]  ^ a[coeffi_S2_a[7][7:0]]  ^ a[coeffi_S2_a[8][7:0]]  ^ a[coeffi_S2_a[9][7:0]]  ^ a[coeffi_S2_a[10][7:0]] ^ a[coeffi_S2_a[11][7:0]] ^
       a[coeffi_S2_a[12][7:0]] ^ a[coeffi_S2_a[13][7:0]] ^ a[coeffi_S2_a[14][7:0]] ^ a[coeffi_S2_a[15][7:0]] ^ a[coeffi_S2_a[16][7:0]] ^ a[coeffi_S2_a[17][7:0]] ^
       a[coeffi_S2_a[18][7:0]] ^ a[coeffi_S2_a[19][7:0]] ^ a[coeffi_S2_a[20][7:0]] ^ a[coeffi_S2_a[21][7:0]] ^ a[coeffi_S2_a[22][7:0]] ^ a[coeffi_S2_a[23][7:0]] ^
       a[coeffi_S2_a[24][7:0]] ^ a[coeffi_S2_a[25][7:0]] ^ a[coeffi_S2_a[26][7:0]] ^ a[coeffi_S2_a[27][7:0]] ^ a[coeffi_S2_a[28][7:0]] ^ a[coeffi_S2_a[29][7:0]] ^
       a[coeffi_S2_a[30][7:0]] ^ a[coeffi_S2_a[31][7:0]] ^ a[coeffi_S2_a[32][7:0]] ^ a[coeffi_S2_a[33][7:0]] ^ a[coeffi_S2_a[34][7:0]] ^ a[coeffi_S2_a[35][7:0]] ^
       a[coeffi_S2_a[36][7:0]] ^ a[coeffi_S2_a[37][7:0]] ^ a[coeffi_S2_a[38][7:0]] ^ a[coeffi_S2_a[39][7:0]] ^ a[coeffi_S2_a[40][7:0]] ^ a[coeffi_S2_a[41][7:0]] ^
       a[coeffi_S2_a[42][7:0]] ^ a[coeffi_S2_a[43][7:0]];
  end
  convert_table
    convert_table_S2(
      .integer_value(S2), // input integer
      .an_value(S_i[2]) // an_value
    );

  // S3
  reg [8:0] coeffi_S3_a [0:43]; // represent a^n
  always@*
  begin
    for(i=0; i<44; i=i+1)
      if( (an_codeword[i]+(43-i)*3) < 256)
        coeffi_S3_a[i] = an_codeword[i] + (43-i)*3;
      else
        coeffi_S3_a[i] = (an_codeword[i] + (43-i)*3) % 255 ;

    S3 = a[coeffi_S3_a[0][7:0]] ^ a[coeffi_S3_a[1][7:0]] ^ a[coeffi_S3_a[2][7:0]]  ^ a[coeffi_S3_a[3][7:0]]  ^ a[coeffi_S3_a[4][7:0]]  ^ a[coeffi_S3_a[5][7:0]] ^
       a[coeffi_S3_a[6][7:0]]  ^ a[coeffi_S3_a[7][7:0]]  ^ a[coeffi_S3_a[8][7:0]]  ^ a[coeffi_S3_a[9][7:0]]  ^ a[coeffi_S3_a[10][7:0]] ^ a[coeffi_S3_a[11][7:0]] ^
       a[coeffi_S3_a[12][7:0]] ^ a[coeffi_S3_a[13][7:0]] ^ a[coeffi_S3_a[14][7:0]] ^ a[coeffi_S3_a[15][7:0]] ^ a[coeffi_S3_a[16][7:0]] ^ a[coeffi_S3_a[17][7:0]] ^
       a[coeffi_S3_a[18][7:0]] ^ a[coeffi_S3_a[19][7:0]] ^ a[coeffi_S3_a[20][7:0]] ^ a[coeffi_S3_a[21][7:0]] ^ a[coeffi_S3_a[22][7:0]] ^ a[coeffi_S3_a[23][7:0]] ^
       a[coeffi_S3_a[24][7:0]] ^ a[coeffi_S3_a[25][7:0]] ^ a[coeffi_S3_a[26][7:0]] ^ a[coeffi_S3_a[27][7:0]] ^ a[coeffi_S3_a[28][7:0]] ^ a[coeffi_S3_a[29][7:0]] ^
       a[coeffi_S3_a[30][7:0]] ^ a[coeffi_S3_a[31][7:0]] ^ a[coeffi_S3_a[32][7:0]] ^ a[coeffi_S3_a[33][7:0]] ^ a[coeffi_S3_a[34][7:0]] ^ a[coeffi_S3_a[35][7:0]] ^
       a[coeffi_S3_a[36][7:0]] ^ a[coeffi_S3_a[37][7:0]] ^ a[coeffi_S3_a[38][7:0]] ^ a[coeffi_S3_a[39][7:0]] ^ a[coeffi_S3_a[40][7:0]] ^ a[coeffi_S3_a[41][7:0]] ^
       a[coeffi_S3_a[42][7:0]] ^ a[coeffi_S3_a[43][7:0]];
  end
  convert_table
    convert_table_S3(
      .integer_value(S3), // input integer
      .an_value(S_i[3]) // an_value
    );

  // S4
  reg [8:0] coeffi_S4_a [0:43]; // represent a^n
  always@*
  begin
    for(i=0; i<44; i=i+1)
      if( (an_codeword[i]+(43-i)*4) < 256)
        coeffi_S4_a[i] = an_codeword[i] + (43-i)*4;
      else
        coeffi_S4_a[i] = (an_codeword[i] + (43-i)*4) % 255 ;

    S4 = a[coeffi_S4_a[0][7:0]] ^ a[coeffi_S4_a[1][7:0]] ^ a[coeffi_S4_a[2][7:0]]  ^ a[coeffi_S4_a[3][7:0]]  ^ a[coeffi_S4_a[4][7:0]]  ^ a[coeffi_S4_a[5][7:0]] ^
       a[coeffi_S4_a[6][7:0]]  ^ a[coeffi_S4_a[7][7:0]]  ^ a[coeffi_S4_a[8][7:0]]  ^ a[coeffi_S4_a[9][7:0]]  ^ a[coeffi_S4_a[10][7:0]] ^ a[coeffi_S4_a[11][7:0]] ^
       a[coeffi_S4_a[12][7:0]] ^ a[coeffi_S4_a[13][7:0]] ^ a[coeffi_S4_a[14][7:0]] ^ a[coeffi_S4_a[15][7:0]] ^ a[coeffi_S4_a[16][7:0]] ^ a[coeffi_S4_a[17][7:0]] ^
       a[coeffi_S4_a[18][7:0]] ^ a[coeffi_S4_a[19][7:0]] ^ a[coeffi_S4_a[20][7:0]] ^ a[coeffi_S4_a[21][7:0]] ^ a[coeffi_S4_a[22][7:0]] ^ a[coeffi_S4_a[23][7:0]] ^
       a[coeffi_S4_a[24][7:0]] ^ a[coeffi_S4_a[25][7:0]] ^ a[coeffi_S4_a[26][7:0]] ^ a[coeffi_S4_a[27][7:0]] ^ a[coeffi_S4_a[28][7:0]] ^ a[coeffi_S4_a[29][7:0]] ^
       a[coeffi_S4_a[30][7:0]] ^ a[coeffi_S4_a[31][7:0]] ^ a[coeffi_S4_a[32][7:0]] ^ a[coeffi_S4_a[33][7:0]] ^ a[coeffi_S4_a[34][7:0]] ^ a[coeffi_S4_a[35][7:0]] ^
       a[coeffi_S4_a[36][7:0]] ^ a[coeffi_S4_a[37][7:0]] ^ a[coeffi_S4_a[38][7:0]] ^ a[coeffi_S4_a[39][7:0]] ^ a[coeffi_S4_a[40][7:0]] ^ a[coeffi_S4_a[41][7:0]] ^
       a[coeffi_S4_a[42][7:0]] ^ a[coeffi_S4_a[43][7:0]];
  end
  convert_table
    convert_table_S4(
      .integer_value(S4), // input integer
      .an_value(S_i[4]) // an_value
    );

  // S5
  reg [8:0] coeffi_S5_a [0:43]; // represent a^n
  always@*
  begin
    for(i=0; i<44; i=i+1)
      if( (an_codeword[i]+(43-i)*5) < 256)
        coeffi_S5_a[i] = an_codeword[i] + (43-i)*5;
      else
        coeffi_S5_a[i] = (an_codeword[i] + (43-i)*5) % 255 ;

    S5 = a[coeffi_S5_a[0][7:0]] ^ a[coeffi_S5_a[1][7:0]] ^ a[coeffi_S5_a[2][7:0]]  ^ a[coeffi_S5_a[3][7:0]]  ^ a[coeffi_S5_a[4][7:0]]  ^ a[coeffi_S5_a[5][7:0]] ^
       a[coeffi_S5_a[6][7:0]]  ^ a[coeffi_S5_a[7][7:0]]  ^ a[coeffi_S5_a[8][7:0]]  ^ a[coeffi_S5_a[9][7:0]]  ^ a[coeffi_S5_a[10][7:0]] ^ a[coeffi_S5_a[11][7:0]] ^
       a[coeffi_S5_a[12][7:0]] ^ a[coeffi_S5_a[13][7:0]] ^ a[coeffi_S5_a[14][7:0]] ^ a[coeffi_S5_a[15][7:0]] ^ a[coeffi_S5_a[16][7:0]] ^ a[coeffi_S5_a[17][7:0]] ^
       a[coeffi_S5_a[18][7:0]] ^ a[coeffi_S5_a[19][7:0]] ^ a[coeffi_S5_a[20][7:0]] ^ a[coeffi_S5_a[21][7:0]] ^ a[coeffi_S5_a[22][7:0]] ^ a[coeffi_S5_a[23][7:0]] ^
       a[coeffi_S5_a[24][7:0]] ^ a[coeffi_S5_a[25][7:0]] ^ a[coeffi_S5_a[26][7:0]] ^ a[coeffi_S5_a[27][7:0]] ^ a[coeffi_S5_a[28][7:0]] ^ a[coeffi_S5_a[29][7:0]] ^
       a[coeffi_S5_a[30][7:0]] ^ a[coeffi_S5_a[31][7:0]] ^ a[coeffi_S5_a[32][7:0]] ^ a[coeffi_S5_a[33][7:0]] ^ a[coeffi_S5_a[34][7:0]] ^ a[coeffi_S5_a[35][7:0]] ^
       a[coeffi_S5_a[36][7:0]] ^ a[coeffi_S5_a[37][7:0]] ^ a[coeffi_S5_a[38][7:0]] ^ a[coeffi_S5_a[39][7:0]] ^ a[coeffi_S5_a[40][7:0]] ^ a[coeffi_S5_a[41][7:0]] ^
       a[coeffi_S5_a[42][7:0]] ^ a[coeffi_S5_a[43][7:0]];
  end
  convert_table
    convert_table_S5(
      .integer_value(S5), // input integer
      .an_value(S_i[5]) // an_value
    );

  // S6
  reg [8:0] coeffi_S6_a [0:43]; // represent a^n
  always@*
  begin
    for(i=0; i<44; i=i+1)
      if( (an_codeword[i]+(43-i)*6) < 256)
        coeffi_S6_a[i] = an_codeword[i] + (43-i)*6;
      else
        coeffi_S6_a[i] = (an_codeword[i] + (43-i)*6) % 255 ;

    S6 = a[coeffi_S6_a[0][7:0]] ^ a[coeffi_S6_a[1][7:0]] ^ a[coeffi_S6_a[2][7:0]]  ^ a[coeffi_S6_a[3][7:0]]  ^ a[coeffi_S6_a[4][7:0]]  ^ a[coeffi_S6_a[5][7:0]] ^
       a[coeffi_S6_a[6][7:0]]  ^ a[coeffi_S6_a[7][7:0]]  ^ a[coeffi_S6_a[8][7:0]]  ^ a[coeffi_S6_a[9][7:0]]  ^ a[coeffi_S6_a[10][7:0]] ^ a[coeffi_S6_a[11][7:0]] ^
       a[coeffi_S6_a[12][7:0]] ^ a[coeffi_S6_a[13][7:0]] ^ a[coeffi_S6_a[14][7:0]] ^ a[coeffi_S6_a[15][7:0]] ^ a[coeffi_S6_a[16][7:0]] ^ a[coeffi_S6_a[17][7:0]] ^
       a[coeffi_S6_a[18][7:0]] ^ a[coeffi_S6_a[19][7:0]] ^ a[coeffi_S6_a[20][7:0]] ^ a[coeffi_S6_a[21][7:0]] ^ a[coeffi_S6_a[22][7:0]] ^ a[coeffi_S6_a[23][7:0]] ^
       a[coeffi_S6_a[24][7:0]] ^ a[coeffi_S6_a[25][7:0]] ^ a[coeffi_S6_a[26][7:0]] ^ a[coeffi_S6_a[27][7:0]] ^ a[coeffi_S6_a[28][7:0]] ^ a[coeffi_S6_a[29][7:0]] ^
       a[coeffi_S6_a[30][7:0]] ^ a[coeffi_S6_a[31][7:0]] ^ a[coeffi_S6_a[32][7:0]] ^ a[coeffi_S6_a[33][7:0]] ^ a[coeffi_S6_a[34][7:0]] ^ a[coeffi_S6_a[35][7:0]] ^
       a[coeffi_S6_a[36][7:0]] ^ a[coeffi_S6_a[37][7:0]] ^ a[coeffi_S6_a[38][7:0]] ^ a[coeffi_S6_a[39][7:0]] ^ a[coeffi_S6_a[40][7:0]] ^ a[coeffi_S6_a[41][7:0]] ^
       a[coeffi_S6_a[42][7:0]] ^ a[coeffi_S6_a[43][7:0]];
  end
  convert_table
    convert_table_S6(
      .integer_value(S6), // input integer
      .an_value(S_i[6]) // an_value
    );

  // S7
  reg [8:0] coeffi_S7_a [0:43]; // represent a^n
  always@*
  begin
    for(i=0; i<44; i=i+1)
      if( (an_codeword[i]+(43-i)*7) < 256)
        coeffi_S7_a[i] = an_codeword[i] + (43-i)*7;
      else
        coeffi_S7_a[i] = (an_codeword[i] + (43-i)*7) % 255 ;

    S7 = a[coeffi_S7_a[0][7:0]] ^ a[coeffi_S7_a[1][7:0]] ^ a[coeffi_S7_a[2][7:0]]  ^ a[coeffi_S7_a[3][7:0]]  ^ a[coeffi_S7_a[4][7:0]]  ^ a[coeffi_S7_a[5][7:0]] ^
       a[coeffi_S7_a[6][7:0]]  ^ a[coeffi_S7_a[7][7:0]]  ^ a[coeffi_S7_a[8][7:0]]  ^ a[coeffi_S7_a[9][7:0]]  ^ a[coeffi_S7_a[10][7:0]] ^ a[coeffi_S7_a[11][7:0]] ^
       a[coeffi_S7_a[12][7:0]] ^ a[coeffi_S7_a[13][7:0]] ^ a[coeffi_S7_a[14][7:0]] ^ a[coeffi_S7_a[15][7:0]] ^ a[coeffi_S7_a[16][7:0]] ^ a[coeffi_S7_a[17][7:0]] ^
       a[coeffi_S7_a[18][7:0]] ^ a[coeffi_S7_a[19][7:0]] ^ a[coeffi_S7_a[20][7:0]] ^ a[coeffi_S7_a[21][7:0]] ^ a[coeffi_S7_a[22][7:0]] ^ a[coeffi_S7_a[23][7:0]] ^
       a[coeffi_S7_a[24][7:0]] ^ a[coeffi_S7_a[25][7:0]] ^ a[coeffi_S7_a[26][7:0]] ^ a[coeffi_S7_a[27][7:0]] ^ a[coeffi_S7_a[28][7:0]] ^ a[coeffi_S7_a[29][7:0]] ^
       a[coeffi_S7_a[30][7:0]] ^ a[coeffi_S7_a[31][7:0]] ^ a[coeffi_S7_a[32][7:0]] ^ a[coeffi_S7_a[33][7:0]] ^ a[coeffi_S7_a[34][7:0]] ^ a[coeffi_S7_a[35][7:0]] ^
       a[coeffi_S7_a[36][7:0]] ^ a[coeffi_S7_a[37][7:0]] ^ a[coeffi_S7_a[38][7:0]] ^ a[coeffi_S7_a[39][7:0]] ^ a[coeffi_S7_a[40][7:0]] ^ a[coeffi_S7_a[41][7:0]] ^
       a[coeffi_S7_a[42][7:0]] ^ a[coeffi_S7_a[43][7:0]];
  end
  convert_table
    convert_table_S7(
      .integer_value(S7), // input integer
      .an_value(S_i[7]) // an_value
    );
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  ///// solve the sigma4, sigma3, sigma2, sigma1 /////
  // consider Eq1 & Eq2 to get Eq5 //
  reg [8:0] mul1;  // S_i[1] - S_i[0]
  always@*
  begin
    if(S_i[1] < S_i[0] )
      mul1 = S_i[0] - S_i[1];
    else if(S_i[1] - S_i[0] < 256)
      mul1 = S_i[1] - S_i[0];
    else
      mul1 = S_i[1] - S_i[0] - 255;
  end
  // add mul1 to Eq1, and add Eq1 and Eq2 to generate Eq5,
  reg [7:0] coeffi_Eq5[0:3];
  wire [8:0] coeffi_Eq5_i[0:3];
  reg [8:0] coeffi_Eq5_tmp_i[0:3];// for Eq1's coefficient + mul1
  always@*
  begin
    for(i=1; i<5; i=i+1)
    begin 
			if(S_i[1] > S_i[0])
		    if(S_i[i] + mul1 < 256)
		      coeffi_Eq5_tmp_i[4-i] = S_i[i] + mul1 ;
		    else
		      coeffi_Eq5_tmp_i[4-i] = S_i[i] + mul1 - 255;
			else
		    if(S_i[i+1] + mul1 < 256)
		      coeffi_Eq5_tmp_i[4-i] = S_i[i+1] + mul1 ;
		    else
		      coeffi_Eq5_tmp_i[4-i] = S_i[i+1] + mul1 - 255;
    end
		if(S_i[1] > S_i[0])
		begin
	    coeffi_Eq5[3] = a[coeffi_Eq5_tmp_i[3][7:0]] ^ S2;
	    coeffi_Eq5[2] = a[coeffi_Eq5_tmp_i[2][7:0]] ^ S3;
	    coeffi_Eq5[1] = a[coeffi_Eq5_tmp_i[1][7:0]] ^ S4;
	    coeffi_Eq5[0] = a[coeffi_Eq5_tmp_i[0][7:0]] ^ S5;
		end
		else
		begin
	    coeffi_Eq5[3] = a[coeffi_Eq5_tmp_i[3][7:0]] ^ S1;
	    coeffi_Eq5[2] = a[coeffi_Eq5_tmp_i[2][7:0]] ^ S2;
	    coeffi_Eq5[1] = a[coeffi_Eq5_tmp_i[1][7:0]] ^ S3;
	    coeffi_Eq5[0] = a[coeffi_Eq5_tmp_i[0][7:0]] ^ S4;		
		end	
  end
  convert_table
    convert_table_Eq5_coeffi3(
      .integer_value(coeffi_Eq5[3]), // input integer
      .an_value(coeffi_Eq5_i[3]) // an_value
    );
  convert_table
    convert_table_Eq5_coeffi2(
      .integer_value(coeffi_Eq5[2]), // input integer
      .an_value(coeffi_Eq5_i[2]) // an_value
    );
  convert_table
    convert_table_Eq5_coeffi1(
      .integer_value(coeffi_Eq5[1]), // input integer
      .an_value(coeffi_Eq5_i[1]) // an_value
    );
  convert_table
    convert_table_Eq5_coeffi0(
      .integer_value(coeffi_Eq5[0]), // input integer
      .an_value(coeffi_Eq5_i[0]) // an_value
    );

  // consider Eq2 & Eq3 to get Eq6 //
  reg [8:0] mul2;  // S_i[2] - S_i[1]
  always@*
  begin
    if(S_i[2] < S_i[1])
      mul2 = S_i[1] - S_i[2];
    else if(S_i[2] - S_i[1] < 256)
      mul2 = S_i[2] - S_i[1];
    else
      mul2 = S_i[2] - S_i[1] - 255;
  end
  // add mul2 to Eq2, and add Eq2 and Eq3 to generate Eq6,
  reg [7:0] coeffi_Eq6[0:3];
  wire [8:0] coeffi_Eq6_i[0:3];
  reg [8:0] coeffi_Eq6_tmp_i[0:3];// for Eq2's coefficient + mul1
  always@*
  begin
    for(i=1; i<5; i=i+1)
    begin
			if(S_i[2] > S_i[1])
		    if(S_i[i+1] + mul2 < 256)
		      coeffi_Eq6_tmp_i[4-i] = S_i[i+1] + mul2 ;
		    else
		      coeffi_Eq6_tmp_i[4-i] = S_i[i+1] + mul2 - 255;
			else
		    if(S_i[i+2] + mul2 < 256)
		      coeffi_Eq6_tmp_i[4-i] = S_i[i+2] + mul2 ;
		    else
		      coeffi_Eq6_tmp_i[4-i] = S_i[i+2] + mul2 - 255;
    end
		if(S_i[2] > S_i[1])
		begin
      coeffi_Eq6[3] = a[coeffi_Eq6_tmp_i[3][7:0]] ^ S3;
      coeffi_Eq6[2] = a[coeffi_Eq6_tmp_i[2][7:0]] ^ S4;
      coeffi_Eq6[1] = a[coeffi_Eq6_tmp_i[1][7:0]] ^ S5;
      coeffi_Eq6[0] = a[coeffi_Eq6_tmp_i[0][7:0]] ^ S6;
		end
		else
		begin
		  coeffi_Eq6[3] = a[coeffi_Eq6_tmp_i[3][7:0]] ^ S2;
      coeffi_Eq6[2] = a[coeffi_Eq6_tmp_i[2][7:0]] ^ S3;
      coeffi_Eq6[1] = a[coeffi_Eq6_tmp_i[1][7:0]] ^ S4;
      coeffi_Eq6[0] = a[coeffi_Eq6_tmp_i[0][7:0]] ^ S5;
		end
  end
  convert_table
    convert_table_Eq6_coeffi3(
      .integer_value(coeffi_Eq6[3]), // input integer
      .an_value(coeffi_Eq6_i[3]) // an_value
    );
  convert_table
    convert_table_Eq6_coeffi2(
      .integer_value(coeffi_Eq6[2]), // input integer
      .an_value(coeffi_Eq6_i[2]) // an_value
    );
  convert_table
    convert_table_Eq6_coeffi1(
      .integer_value(coeffi_Eq6[1]), // input integer
      .an_value(coeffi_Eq6_i[1]) // an_value
    );
  convert_table
    convert_table_Eq6_coeffi0(
      .integer_value(coeffi_Eq6[0]), // input integer
      .an_value(coeffi_Eq6_i[0]) // an_value
    );

  // consider Eq3 & Eq4 to get Eq7 //
  reg [8:0] mul3;  // S_i[3] - S_i[2]
  always@*
  begin
    if(S_i[3] <  S_i[2])
      mul3 = S_i[2] - S_i[3] ; //mul3 = ~(S_i[2] - S_i[3]) - 256;
    else if(S_i[3] - S_i[2] < 256)
      mul3 = S_i[3] - S_i[2];
    else
      mul3 = S_i[3] - S_i[2] - 255;
  end
  // add mul3 to Eq3, and add Eq3 and Eq4 to generate Eq7,
  reg [7:0] coeffi_Eq7[0:3];
  wire [8:0] coeffi_Eq7_i[0:3];
  reg [8:0] coeffi_Eq7_tmp_i[0:3];// for Eq3's coefficient + mul1
  always@*
  begin
    for(i=1; i<5; i=i+1)
    begin
			if(S_i[3] > S_i[2])
		    if(S_i[i+2] + mul3 < 256)
		      coeffi_Eq7_tmp_i[4-i] = S_i[i+2] + mul3 ;
		    else
		      coeffi_Eq7_tmp_i[4-i] = S_i[i+2] + mul3 - 255;
			else
		    if(S_i[i+3] + mul3 < 256)
		      coeffi_Eq7_tmp_i[4-i] = S_i[i+3] + mul3 ;
		    else
		      coeffi_Eq7_tmp_i[4-i] = S_i[i+3] + mul3 - 255;
    end
		if(S_i[3] > S_i[2])
		begin 
      coeffi_Eq7[3] = a[coeffi_Eq7_tmp_i[3][7:0]] ^ S4;
      coeffi_Eq7[2] = a[coeffi_Eq7_tmp_i[2][7:0]] ^ S5;
      coeffi_Eq7[1] = a[coeffi_Eq7_tmp_i[1][7:0]] ^ S6;
      coeffi_Eq7[0] = a[coeffi_Eq7_tmp_i[0][7:0]] ^ S7;
		end
		else
		begin
      coeffi_Eq7[3] = a[coeffi_Eq7_tmp_i[3][7:0]] ^ S3;
      coeffi_Eq7[2] = a[coeffi_Eq7_tmp_i[2][7:0]] ^ S4;
      coeffi_Eq7[1] = a[coeffi_Eq7_tmp_i[1][7:0]] ^ S5;
      coeffi_Eq7[0] = a[coeffi_Eq7_tmp_i[0][7:0]] ^ S6;
		end
  end
  convert_table
    convert_table_Eq7_coeffi3(
      .integer_value(coeffi_Eq7[3]), // input integer
      .an_value(coeffi_Eq7_i[3]) // an_value
    );
  convert_table
    convert_table_Eq7_coeffi2(
      .integer_value(coeffi_Eq7[2]), // input integer
      .an_value(coeffi_Eq7_i[2]) // an_value
    );
  convert_table
    convert_table_Eq7_coeffi1(
      .integer_value(coeffi_Eq7[1]), // input integer
      .an_value(coeffi_Eq7_i[1]) // an_value
    );
  convert_table
    convert_table_Eq7_coeffi0(
      .integer_value(coeffi_Eq7[0]), // input integer
      .an_value(coeffi_Eq7_i[0]) // an_value
    );

  // consider Eq5 & Eq6 to get Eq8 //
  reg [8:0] mul4;  // coeffi_Eq6_i[3] - coeffi_Eq5_i[3]
  always@*
  begin
    if(coeffi_Eq6_i[3] < coeffi_Eq5_i[3])
      mul4 = coeffi_Eq5_i[3] - coeffi_Eq6_i[3];
    else if(coeffi_Eq6_i[3] - coeffi_Eq5_i[3] < 256)
      mul4 = coeffi_Eq6_i[3] - coeffi_Eq5_i[3];
    else
      mul4 = coeffi_Eq6_i[3] - coeffi_Eq5_i[3] - 255;
  end
  // add mul4 to Eq5, and add Eq5 and Eq6 to generate Eq8,
  reg [7:0] coeffi_Eq8[0:2];
  wire [8:0] coeffi_Eq8_i[0:2];
  reg [8:0] coeffi_Eq8_tmp_i[0:2];// for Eq5's coefficient + mul1
  always@*
  begin
    for(i=0; i<3; i=i+1)
    begin
			if(coeffi_Eq6_i[3] > coeffi_Eq5_i[3])
		    if(coeffi_Eq5_i[i] + mul4 < 256)
		      coeffi_Eq8_tmp_i[i] = coeffi_Eq5_i[i] + mul4 ;
		    else
		      coeffi_Eq8_tmp_i[i] = coeffi_Eq5_i[i] + mul4 - 255;
			else
		    if(coeffi_Eq6_i[i] + mul4 < 256)
		      coeffi_Eq8_tmp_i[i] = coeffi_Eq6_i[i] + mul4 ;
		    else
		      coeffi_Eq8_tmp_i[i] = coeffi_Eq6_i[i] + mul4 - 255;				
    end
		if(coeffi_Eq6_i[3] > coeffi_Eq5_i[3])
		begin
     	coeffi_Eq8[2] = a[coeffi_Eq8_tmp_i[2][7:0]] ^ coeffi_Eq6[2];
     	coeffi_Eq8[1] = a[coeffi_Eq8_tmp_i[1][7:0]] ^ coeffi_Eq6[1];
     	coeffi_Eq8[0] = a[coeffi_Eq8_tmp_i[0][7:0]] ^ coeffi_Eq6[0];
		end
		else
		begin
     	coeffi_Eq8[2] = a[coeffi_Eq8_tmp_i[2][7:0]] ^ coeffi_Eq5[2];
     	coeffi_Eq8[1] = a[coeffi_Eq8_tmp_i[1][7:0]] ^ coeffi_Eq5[1];
     	coeffi_Eq8[0] = a[coeffi_Eq8_tmp_i[0][7:0]] ^ coeffi_Eq5[0];
		end
  end
  convert_table
    convert_table_Eq8_coeffi2(
      .integer_value(coeffi_Eq8[2]), // input integer
      .an_value(coeffi_Eq8_i[2]) // an_value
    );
  convert_table
    convert_table_Eq8_coeffi1(
      .integer_value(coeffi_Eq8[1]), // input integer
      .an_value(coeffi_Eq8_i[1]) // an_value
    );
  convert_table
    convert_table_Eq8_coeffi0(
      .integer_value(coeffi_Eq8[0]), // input integer
      .an_value(coeffi_Eq8_i[0]) // an_value
    );

  // consider Eq6 & Eq7 to get Eq9 //
  reg [8:0] mul5;  // coeffi_Eq7_i[3] - coeffi_Eq6_i[3]
  always@*
  begin
    if(coeffi_Eq7_i[3] < coeffi_Eq6_i[3])
      mul5 = coeffi_Eq6_i[3] - coeffi_Eq7_i[3];
    else if(coeffi_Eq7_i[3] - coeffi_Eq6_i[3] < 256)
      mul5 = coeffi_Eq7_i[3] - coeffi_Eq6_i[3];
    else
      mul5 = coeffi_Eq7_i[3] - coeffi_Eq6_i[3] - 255;
  end
  // add mul5 to Eq6, and add Eq6 and Eq7 to generate Eq9,
  reg [7:0] coeffi_Eq9[0:2];
  wire [8:0] coeffi_Eq9_i[0:2];
  reg [8:0] coeffi_Eq9_tmp_i[0:2];// for Eq6's coefficient + mul1
  always@*
  begin
    for(i=0; i<3; i=i+1)
    begin
			if(coeffi_Eq7_i[3] > coeffi_Eq6_i[3])
      	if(coeffi_Eq6_i[i] + mul5 < 256)
        	coeffi_Eq9_tmp_i[i] = coeffi_Eq6_i[i] + mul5 ;
      	else
        	coeffi_Eq9_tmp_i[i] = coeffi_Eq6_i[i] + mul5 - 255;
			else
      	if(coeffi_Eq7_i[i] + mul5 < 256)
        	coeffi_Eq9_tmp_i[i] = coeffi_Eq7_i[i] + mul5 ;
      	else
        	coeffi_Eq9_tmp_i[i] = coeffi_Eq7_i[i] + mul5 - 255;	
    end
		if(coeffi_Eq7_i[3] > coeffi_Eq6_i[3])
		begin
      coeffi_Eq9[2] = a[coeffi_Eq9_tmp_i[2][7:0]] ^ coeffi_Eq7[2];
      coeffi_Eq9[1] = a[coeffi_Eq9_tmp_i[1][7:0]] ^ coeffi_Eq7[1];
      coeffi_Eq9[0] = a[coeffi_Eq9_tmp_i[0][7:0]] ^ coeffi_Eq7[0];
		end
		else
		begin
      coeffi_Eq9[2] = a[coeffi_Eq9_tmp_i[2][7:0]] ^ coeffi_Eq6[2];
      coeffi_Eq9[1] = a[coeffi_Eq9_tmp_i[1][7:0]] ^ coeffi_Eq6[1];
      coeffi_Eq9[0] = a[coeffi_Eq9_tmp_i[0][7:0]] ^ coeffi_Eq6[0];
		end
  end
  convert_table
    convert_table_Eq9_coeffi2(
      .integer_value(coeffi_Eq9[2]), // input integer
      .an_value(coeffi_Eq9_i[2]) // an_value
    );
  convert_table
    convert_table_Eq9_coeffi1(
      .integer_value(coeffi_Eq9[1]), // input integer
      .an_value(coeffi_Eq9_i[1]) // an_value
    );
  convert_table
    convert_table_Eq9_coeffi0(
      .integer_value(coeffi_Eq9[0]), // input integer
      .an_value(coeffi_Eq9_i[0]) // an_value
    );

  // consider Eq8 & Eq9 to get Eq10 //
  reg [8:0] mul6;  // coeffi_Eq9_i[2] - coeffi_Eq8_i[2]
  always@*
  begin
    if(coeffi_Eq9_i[2] < coeffi_Eq8_i[2] )
      mul6 = coeffi_Eq8_i[2] - coeffi_Eq9_i[2];
    else if(coeffi_Eq9_i[2] - coeffi_Eq8_i[2] < 256)
      mul6 = coeffi_Eq9_i[2] - coeffi_Eq8_i[2];
    else
      mul6 = coeffi_Eq9_i[2] - coeffi_Eq8_i[2] - 255;
  end
  // add mul6 to Eq8, and add Eq8 and Eq9 to generate Eq10,
  reg [7:0] coeffi_Eq10[0:1];
  wire [8:0] coeffi_Eq10_i[0:1];
  reg [8:0] coeffi_Eq10_tmp_i[0:1];// for Eq8's coefficient + mul1
  always@*
  begin
    for(i=0; i<2; i=i+1)
    begin
			if(coeffi_Eq9_i[2] > coeffi_Eq8_i[2])
		    if(coeffi_Eq8_i[i] + mul6 < 256)
		      coeffi_Eq10_tmp_i[i] = coeffi_Eq8_i[i] + mul6 ;
		    else
		      coeffi_Eq10_tmp_i[i] = coeffi_Eq8_i[i] + mul6 - 255;
			else
		    if(coeffi_Eq9_i[i] + mul6 < 256)
		      coeffi_Eq10_tmp_i[i] = coeffi_Eq9_i[i] + mul6 ;
		    else
		      coeffi_Eq10_tmp_i[i] = coeffi_Eq9_i[i] + mul6 - 255;
    end
		if(coeffi_Eq9_i[2] > coeffi_Eq8_i[2])
		begin
      coeffi_Eq10[1] = a[coeffi_Eq10_tmp_i[1][7:0]] ^ coeffi_Eq9[1];
      coeffi_Eq10[0] = a[coeffi_Eq10_tmp_i[0][7:0]] ^ coeffi_Eq9[0];
		end
		else
		begin
		  coeffi_Eq10[1] = a[coeffi_Eq10_tmp_i[1][7:0]] ^ coeffi_Eq8[1];
      coeffi_Eq10[0] = a[coeffi_Eq10_tmp_i[0][7:0]] ^ coeffi_Eq8[0];
		end
  end
  convert_table
    convert_table_Eq10_coeffi1(
      .integer_value(coeffi_Eq10[1]), // input integer
      .an_value(coeffi_Eq10_i[1]) // an_value
    );
  convert_table
    convert_table_Eq10_coeffi0(
      .integer_value(coeffi_Eq10[0]), // input integer
      .an_value(coeffi_Eq10_i[0]) // an_value
    );


  // consider Eq 10 to get sigma1 //
  reg [8:0] sigma1; // an_value
  always @* begin
    if(coeffi_Eq10_i[0] < coeffi_Eq10_i[1])
      sigma1 = 255 - coeffi_Eq10_i[1] + coeffi_Eq10_i[0];
    else if(coeffi_Eq10_i[0] - coeffi_Eq10_i[1] < 256)
      sigma1 = coeffi_Eq10_i[0] - coeffi_Eq10_i[1];
    else
      sigma1 = coeffi_Eq10_i[0] - coeffi_Eq10_i[1] - 255;
  end  

  // consider Eq 12 to get sigma2 //
  reg [8:0] sigma2;
  reg [7:0] Eq12_tmp0;
  wire [8:0] Eq12_tmp1;
  reg [8:0] coeffi_Eq12_i1;
  always@* begin
    if (sigma1 + coeffi_Eq8_i[1] < 256)
      coeffi_Eq12_i1 = sigma1 + coeffi_Eq8_i[1];
    else
      coeffi_Eq12_i1 = sigma1 + coeffi_Eq8_i[1] - 255;

    Eq12_tmp0 = a[coeffi_Eq12_i1[7:0]] ^ coeffi_Eq8[0];
  end
  convert_table
    convert_table_Eq12_Eq12_tmp2(
      .integer_value(Eq12_tmp0), // input integer
      .an_value(Eq12_tmp1) // an_value
    );
  always@* begin
    if(Eq12_tmp1 < coeffi_Eq8_i[2] )
      sigma2 = 255 - coeffi_Eq8_i[2] + Eq12_tmp1;
    else if(Eq12_tmp1 - coeffi_Eq8_i[2] < 256)
      sigma2 = Eq12_tmp1 - coeffi_Eq8_i[2];
    else
      sigma2 = Eq12_tmp1 - coeffi_Eq8_i[2] - 255;
  end
  
  // consider Eq14 to get sigma3 //
  reg [8:0] sigma3;
  reg [7:0] Eq14_tmp0;
  wire[8:0] Eq14_tmp1;
  reg [8:0] coeffi_Eq14_i2;
  reg [8:0] coeffi_Eq14_i1;
  always@* begin
    if (sigma1 + coeffi_Eq5_i[1] < 256)
      coeffi_Eq14_i1 = sigma1 + coeffi_Eq5_i[1];
    else
      coeffi_Eq14_i1 = sigma1 + coeffi_Eq5_i[1] - 255;
      
    if (sigma2 + coeffi_Eq5_i[2] < 256)
      coeffi_Eq14_i2 = sigma2 + coeffi_Eq5_i[2];
    else
      coeffi_Eq14_i2 = sigma2 + coeffi_Eq5_i[2] - 255;

    Eq14_tmp0 = a[coeffi_Eq14_i1[7:0]] ^ a[coeffi_Eq14_i2[7:0]] ^ coeffi_Eq5[0];
  end
  convert_table
    convert_table_Eq14_Eq14_tmp0(
      .integer_value(Eq14_tmp0), // input integer
      .an_value(Eq14_tmp1) // an_value
    );
  always@* begin
    if(Eq14_tmp1 < coeffi_Eq5_i[3] )
      sigma3 = 255 - coeffi_Eq5_i[3] + Eq14_tmp1;
    else if(Eq14_tmp1 - coeffi_Eq5_i[3] < 256)
      sigma3 = Eq14_tmp1 - coeffi_Eq5_i[3];
    else
      sigma3 = Eq14_tmp1 - coeffi_Eq5_i[3] - 255;
  end

  // consider Eq16 to get sigma4 //
  reg [8:0] sigma4;
  reg [7:0] Eq16_tmp0;
  wire [8:0] Eq16_tmp1;
  reg [8:0] coeffi_Eq16_i3;
  reg [8:0] coeffi_Eq16_i2;
  reg [8:0] coeffi_Eq16_i1;
  always@* begin
    if (sigma1 + S_i[3] < 256)
      coeffi_Eq16_i1 = sigma1 + S_i[3];
    else
      coeffi_Eq16_i1 = sigma1 + S_i[3] - 255;
      
    if (sigma2 + S_i[2] < 256)
      coeffi_Eq16_i2 = sigma2 + S_i[2];
    else
      coeffi_Eq16_i2 = sigma2 + S_i[2] - 255;

    if (sigma3 + S_i[1] < 256)
      coeffi_Eq16_i3 = sigma3 + S_i[1];
    else
      coeffi_Eq16_i3 = sigma3 + S_i[1] - 255;

    Eq16_tmp0 = a[coeffi_Eq16_i1[7:0]] ^ a[coeffi_Eq16_i2[7:0]] ^ a[coeffi_Eq16_i3[7:0]] ^ S4;
  end
  convert_table
    convert_table_Eq16_Eq16_tmp0(
      .integer_value(Eq16_tmp0), // input integer
      .an_value(Eq16_tmp1) // an_value
    );
  always@* begin
    if(Eq16_tmp1 < S_i[0] )
      sigma4 = 255 - S_i[0] + Eq16_tmp1;
    else if(Eq16_tmp1 - S_i[0] < 256)
      sigma4 = Eq16_tmp1 - S_i[0];
    else
      sigma4 = Eq16_tmp1 - S_i[0] - 255;
  end
  //////////////////////////////////////////////////////////////////////////////////////////////////////////

  ///// calculate the error position i /////
  reg [5:0]position_i;
  always@(posedge clk)
    if(~srstn)
      position_i <= 0;
    else if(load_done & ~ECC_done)
      position_i <= position_i + 1;

  reg [8:0] coeffi_Eq17_tmp [0:2];
  reg [7:0] sigma_fuc;
  reg solution_hit;
  always@* begin
    if (sigma3 + position_i < 256)
      coeffi_Eq17_tmp[0] = sigma3 + position_i;
    else
      coeffi_Eq17_tmp[0] = sigma3 + position_i - 255; 

    if (sigma2 + 2*position_i < 256)
      coeffi_Eq17_tmp[1] = sigma2 + 2*position_i;
    else
      coeffi_Eq17_tmp[1] = sigma2 + 2*position_i - 255; 

    if (sigma1 + 3*position_i < 256)
      coeffi_Eq17_tmp[2] = sigma1 + 3*position_i;
    else
      coeffi_Eq17_tmp[2] = sigma1 + 3*position_i - 255; 

    sigma_fuc = a[sigma4[7:0]] ^ a[coeffi_Eq17_tmp[0][7:0]] ^ a[coeffi_Eq17_tmp[1][7:0]] ^ a[coeffi_Eq17_tmp[2][7:0]] ^ a[4*position_i];

    if(sigma_fuc==0)
      solution_hit = 1;
    else
      solution_hit = 0;
  end
  
  reg [7:0] i_sol [0:3];
  reg [2:0] sol_num;
  always@(posedge clk) begin
    if(~srstn)begin
      for(i=0; i<4; i=i+1)
        i_sol[i] <= 0;
      sol_num <= 0;
    end
    else if(solution_hit & load_done) begin
      sol_num <= sol_num + 1;
      i_sol[sol_num] <= position_i;
    end
  end
  always@* begin
    if(position_i==44 || sol_num==4)
      ECC_done = 1;
    else
      ECC_done = 0;
  end
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  ///// sovle the Y1, Y2, Y3, Y4 /////
  reg [8:0]ymul1; // 2*i_sol[0] - i_sol[]
  always@*
  begin
    ymul1 = 2*i_sol[0] - i_sol[0]; // must > 0
  end
  // add mul1 to Eq1, and add Eq1 and Eq2 to generate Eq5,
  reg [7:0] coeffi_yEq5[0:3];
  wire [8:0] coeffi_yEq5_i[0:3];
  reg [8:0] coeffi_yEq5_tmp_i[0:3];// for Eq1's coefficient + mul1
  always@*
  begin
    for(i=1; i<4; i=i+1)
    begin
      coeffi_yEq5_tmp_i[4-i] = i_sol[i] + ymul1 ;
    end
    coeffi_yEq5_tmp_i[0] = S_i[0] + ymul1 ;

    coeffi_yEq5[3] = a[coeffi_yEq5_tmp_i[3][7:0]] ^ a[2*i_sol[1]]; 
    coeffi_yEq5[2] = a[coeffi_yEq5_tmp_i[2][7:0]] ^ a[2*i_sol[2]];
    coeffi_yEq5[1] = a[coeffi_yEq5_tmp_i[1][7:0]] ^ a[2*i_sol[3]];
    coeffi_yEq5[0] = a[coeffi_yEq5_tmp_i[0][7:0]] ^ S1; 
	end
  convert_table
    convert_table_yEq5_coeffi3(
      .integer_value(coeffi_yEq5[3]), // input integer
      .an_value(coeffi_yEq5_i[3]) // an_value
    );
  convert_table
    convert_table_yEq5_coeffi2(
      .integer_value(coeffi_yEq5[2]), // input integer
      .an_value(coeffi_yEq5_i[2]) // an_value
    );
  convert_table
    convert_table_yEq5_coeffi1(
      .integer_value(coeffi_yEq5[1]), // input integer
      .an_value(coeffi_yEq5_i[1]) // an_value
    );
  convert_table
    convert_table_yEq5_coeffi0(
      .integer_value(coeffi_yEq5[0]), // input integer
      .an_value(coeffi_yEq5_i[0]) // an_value
    );

// consider Eq2 & Eq3 to get Eq6 //
  reg [8:0] ymul2;  // 3*i_sol[0] - 2*i_sol[0]
  always@*
  begin
    ymul2 = 3*i_sol[0] - 2*i_sol[0];
  end
  // add mul2 to Eq2, and add Eq2 and Eq3 to generate Eq6,
  reg [7:0] coeffi_yEq6[0:3];
  wire [8:0] coeffi_yEq6_i[0:3];
  reg [8:0] coeffi_yEq6_tmp_i[0:3];// for Eq2's coefficient + mul1
  always@*
  begin
    for(i=1; i<4; i=i+1)
    begin
      coeffi_yEq6_tmp_i[4-i] = 2*i_sol[i] + ymul2 ;
    end
		if(S_i[1] + ymul2 < 255)
    	coeffi_yEq6_tmp_i[0] = S_i[1] + ymul2;
		else
			coeffi_yEq6_tmp_i[0] = S_i[1] + ymul2 - 255;

    coeffi_yEq6[3] = a[coeffi_yEq6_tmp_i[3][7:0]] ^ a[3*i_sol[1]]; 
    coeffi_yEq6[2] = a[coeffi_yEq6_tmp_i[2][7:0]] ^ a[3*i_sol[2]];
    coeffi_yEq6[1] = a[coeffi_yEq6_tmp_i[1][7:0]] ^ a[3*i_sol[3]];
    coeffi_yEq6[0] = a[coeffi_yEq6_tmp_i[0][7:0]] ^ S2;
	end
  convert_table
    convert_table_yEq6_coeffi3(
      .integer_value(coeffi_yEq6[3]), // input integer
      .an_value(coeffi_yEq6_i[3]) // an_value
    );
  convert_table
    convert_table_yEq6_coeffi2(
      .integer_value(coeffi_yEq6[2]), // input integer
      .an_value(coeffi_yEq6_i[2]) // an_value
    );
  convert_table
    convert_table_yEq6_coeffi1(
      .integer_value(coeffi_yEq6[1]), // input integer
      .an_value(coeffi_yEq6_i[1]) // an_value
    );
  convert_table
    convert_table_yEq6_coeffi0(
      .integer_value(coeffi_yEq6[0]), // input integer
      .an_value(coeffi_yEq6_i[0]) // an_value
    );

  // consider Eq3 & Eq4 to get Eq7 //
  reg [8:0] ymul3;  // 4*i_sol[0] - 3*i_sol[0]
  always@*
  begin
    ymul3 = 4*i_sol[0] - 3*i_sol[0];
  end
   // add mul3 to Eq3, and add Eq3 and Eq4 to generate Eq7,
  reg [7:0] coeffi_yEq7[0:3];
  wire [8:0] coeffi_yEq7_i[0:3];
  reg [8:0] coeffi_yEq7_tmp_i[0:3];// for Eq3's coefficient + mul1
  always@*
  begin
    for(i=1; i<4; i=i+1)
    begin
      coeffi_yEq7_tmp_i[4-i] = 3*i_sol[i] + ymul3 ;
    end
		if(S_i[2] + ymul3 < 255)
    	coeffi_yEq7_tmp_i[0] = S_i[2] + ymul3 ;
		else
			coeffi_yEq7_tmp_i[0] = S_i[2] + ymul3 - 255;
			

    coeffi_yEq7[3] = a[coeffi_yEq7_tmp_i[3][7:0]] ^ a[4*i_sol[1]]; 
    coeffi_yEq7[2] = a[coeffi_yEq7_tmp_i[2][7:0]] ^ a[4*i_sol[2]];
    coeffi_yEq7[1] = a[coeffi_yEq7_tmp_i[1][7:0]] ^ a[4*i_sol[3]];
    coeffi_yEq7[0] = a[coeffi_yEq7_tmp_i[0][7:0]] ^ S3; 
	end
  convert_table
    convert_table_yEq7_coeffi3(
      .integer_value(coeffi_yEq7[3]), // input integer
      .an_value(coeffi_yEq7_i[3]) // an_value
    );
  convert_table
    convert_table_yEq7_coeffi2(
      .integer_value(coeffi_yEq7[2]), // input integer
      .an_value(coeffi_yEq7_i[2]) // an_value
    );
  convert_table
    convert_table_yEq7_coeffi1(
      .integer_value(coeffi_yEq7[1]), // input integer
      .an_value(coeffi_yEq7_i[1]) // an_value
    );
  convert_table
    convert_table_yEq7_coeffi0(
      .integer_value(coeffi_yEq7[0]), // input integer
      .an_value(coeffi_yEq7_i[0]) // an_value
    );

  // consider Eq5 & Eq6 to get Eq8 //
  reg [8:0] ymul4;
  always@*
  begin
    if(coeffi_yEq6_i[3] < coeffi_yEq5_i[3])
      ymul4 = coeffi_yEq5_i[3] - coeffi_yEq6_i[3] ;
    else
      ymul4 = coeffi_yEq6_i[3] - coeffi_yEq5_i[3];
  end
  // add mul4 to Eq5, and add Eq5 and Eq6 to generate Eq8,
  reg [7:0] coeffi_yEq8[0:2];
  wire [8:0] coeffi_yEq8_i[0:2];
  reg [8:0] coeffi_yEq8_tmp_i[0:2];// for Eq5's coefficient + mul1
  always@*
	begin
    for(i=0; i<3; i=i+1)
    begin
			if(coeffi_yEq6_i[3] > coeffi_yEq5_i[3])
		    if(coeffi_yEq5_i[i] + ymul4 < 256)
		      coeffi_yEq8_tmp_i[i] = coeffi_yEq5_i[i] + ymul4 ;
		    else
		      coeffi_yEq8_tmp_i[i] = coeffi_yEq5_i[i] + ymul4 - 255;
			else
				if(coeffi_yEq6_i[i] + ymul4 < 256)
		      coeffi_yEq8_tmp_i[i] = coeffi_yEq6_i[i] + ymul4 ;
		    else
		      coeffi_yEq8_tmp_i[i] = coeffi_yEq6_i[i] + ymul4 - 255;
		end
		if(coeffi_yEq6_i[3] > coeffi_yEq5_i[3])
		begin
      coeffi_yEq8[2] = a[coeffi_yEq8_tmp_i[2][7:0]] ^ coeffi_yEq6[2];
      coeffi_yEq8[1] = a[coeffi_yEq8_tmp_i[1][7:0]] ^ coeffi_yEq6[1];
      coeffi_yEq8[0] = a[coeffi_yEq8_tmp_i[0][7:0]] ^ coeffi_yEq6[0];
		end
		else
		begin
		  coeffi_yEq8[2] = a[coeffi_yEq8_tmp_i[2][7:0]] ^ coeffi_yEq5[2];
      coeffi_yEq8[1] = a[coeffi_yEq8_tmp_i[1][7:0]] ^ coeffi_yEq5[1];
      coeffi_yEq8[0] = a[coeffi_yEq8_tmp_i[0][7:0]] ^ coeffi_yEq5[0];
    end
	end
  convert_table
    convert_table_yEq8_coeffi2(
      .integer_value(coeffi_yEq8[2]), // input integer
      .an_value(coeffi_yEq8_i[2]) // an_value
    );
  convert_table
    convert_table_yEq8_coeffi1(
      .integer_value(coeffi_yEq8[1]), // input integer
      .an_value(coeffi_yEq8_i[1]) // an_value
    );
  convert_table
    convert_table_yEq8_coeffi0(
      .integer_value(coeffi_yEq8[0]), // input integer
      .an_value(coeffi_yEq8_i[0]) // an_value
    );

// consider Eq6 & Eq7 to get Eq9 //
  reg [8:0] ymul5;  // coeffi_Eq7_i[3] - coeffi_Eq6_i[3]
  always@*
  begin
    if(coeffi_yEq7_i[3] < coeffi_yEq6_i[3])
      ymul5 = coeffi_yEq6_i[3] - coeffi_yEq7_i[3] ;
    else
      ymul5 = coeffi_yEq7_i[3] - coeffi_yEq6_i[3];
  end
 // add mul5 to Eq6, and add Eq6 and Eq7 to generate Eq9,
  reg [7:0] coeffi_yEq9[0:2];
  wire [8:0] coeffi_yEq9_i[0:2];
  reg [8:0] coeffi_yEq9_tmp_i[0:2];// for Eq5's coefficient + mul1
  always@*
	begin
    for(i=0; i<3; i=i+1)
    begin
			if(coeffi_yEq7_i[3] > coeffi_yEq6_i[3])
		    if(coeffi_yEq6_i[i] + ymul5 < 256)
		      coeffi_yEq9_tmp_i[i] = coeffi_yEq6_i[i] + ymul5 ;
		    else
		      coeffi_yEq9_tmp_i[i] = coeffi_yEq6_i[i] + ymul5 - 255;
			else
		    if(coeffi_yEq7_i[i] + ymul5 < 256)
		      coeffi_yEq9_tmp_i[i] = coeffi_yEq7_i[i] + ymul5 ;
		    else
		      coeffi_yEq9_tmp_i[i] = coeffi_yEq7_i[i] + ymul5 - 255;
		end
		if(coeffi_yEq7_i[3] > coeffi_yEq6_i[3])
		begin
    coeffi_yEq9[2] = a[coeffi_yEq9_tmp_i[2][7:0]] ^ coeffi_yEq7[2];
    coeffi_yEq9[1] = a[coeffi_yEq9_tmp_i[1][7:0]] ^ coeffi_yEq7[1];
    coeffi_yEq9[0] = a[coeffi_yEq9_tmp_i[0][7:0]] ^ coeffi_yEq7[0];
		end
		else
		begin
		coeffi_yEq9[2] = a[coeffi_yEq9_tmp_i[2][7:0]] ^ coeffi_yEq6[2];
    coeffi_yEq9[1] = a[coeffi_yEq9_tmp_i[1][7:0]] ^ coeffi_yEq6[1];
    coeffi_yEq9[0] = a[coeffi_yEq9_tmp_i[0][7:0]] ^ coeffi_yEq6[0];
    end
	end
  convert_table
    convert_table_yEq9_coeffi2(
      .integer_value(coeffi_yEq9[2]), // input integer
      .an_value(coeffi_yEq9_i[2]) // an_value
    );
  convert_table
    convert_table_yEq9_coeffi1(
      .integer_value(coeffi_yEq9[1]), // input integer
      .an_value(coeffi_yEq9_i[1]) // an_value
    );
  convert_table
    convert_table_yEq9_coeffi0(
      .integer_value(coeffi_yEq9[0]), // input integer
      .an_value(coeffi_yEq9_i[0]) // an_value
    );

  // consider Eq8 & Eq9 to get Eq10 //
  reg [8:0] ymul6;  // coeffi_Eq9_i[2] - coeffi_Eq8_i[2]
  always@*
  begin
    if(coeffi_yEq9_i[2] < coeffi_yEq8_i[2])
      ymul6 = coeffi_yEq8_i[2] - coeffi_yEq9_i[2];
    else
      ymul6 = coeffi_yEq9_i[2] - coeffi_yEq8_i[2];
  end
  // add mul6 to Eq8, and add Eq8 and Eq9 to generate Eq10,
  reg [7:0] coeffi_yEq10[0:1];
  wire [8:0] coeffi_yEq10_i[0:1];
  reg [8:0] coeffi_yEq10_tmp_i[0:1];// for Eq8's coefficient + mul1
  always@*
	begin
    for(i=0; i<2; i=i+1)
    begin
			if(coeffi_yEq9_i[2] > coeffi_yEq8_i[2])
		    if(coeffi_yEq8_i[i] + ymul6 < 256)
		      coeffi_yEq10_tmp_i[i] = coeffi_yEq8_i[i] + ymul6 ;
		    else
		      coeffi_yEq10_tmp_i[i] = coeffi_yEq8_i[i] + ymul6 - 255;
			else
		    if(coeffi_yEq9_i[i] + ymul6 < 256)
		      coeffi_yEq10_tmp_i[i] = coeffi_yEq9_i[i] + ymul6 ;
		    else
		      coeffi_yEq10_tmp_i[i] = coeffi_yEq9_i[i] + ymul6 - 255;
		end
		if(coeffi_yEq9_i[2] > coeffi_yEq8_i[2])
		begin
      coeffi_yEq10[1] = a[coeffi_yEq10_tmp_i[1][7:0]] ^ coeffi_yEq9[1];
      coeffi_yEq10[0] = a[coeffi_yEq10_tmp_i[0][7:0]] ^ coeffi_yEq9[0]; 
    end
		else
		begin
      coeffi_yEq10[1] = a[coeffi_yEq10_tmp_i[1][7:0]] ^ coeffi_yEq8[1];
      coeffi_yEq10[0] = a[coeffi_yEq10_tmp_i[0][7:0]] ^ coeffi_yEq8[0]; 
		end
	end
  convert_table
    convert_table_yEq10_coeffi1(
      .integer_value(coeffi_yEq10[1]), // input integer
      .an_value(coeffi_yEq10_i[1]) // an_value
    );
  convert_table
    convert_table_yEq10_coeffi0(
      .integer_value(coeffi_yEq10[0]), // input integer
      .an_value(coeffi_yEq10_i[0]) // an_value
    );

  // consider Eq 10 to get Y4 //
  reg [8:0] Y4; // an_value
  always @* begin
    if(coeffi_yEq10_i[0] < coeffi_yEq10_i[1])
      Y4 = 255 - coeffi_yEq10_i[1] + coeffi_yEq10_i[0];
    else if(coeffi_yEq10_i[0] - coeffi_yEq10_i[1] < 256)
      Y4 = coeffi_yEq10_i[0] - coeffi_yEq10_i[1];
    else
      Y4 = coeffi_yEq10_i[0] - coeffi_yEq10_i[1] - 255;
  end  

  // consider Eq 12 to get Y3 //
  reg [8:0] Y3;
  reg [7:0] yEq12_tmp0;
  wire [8:0] yEq12_tmp1;
  reg [8:0] coeffi_yEq12_i1;
  always@* begin
    if (Y4 + coeffi_yEq8_i[1] < 256)
      coeffi_yEq12_i1 = Y4 + coeffi_yEq8_i[1];
    else
      coeffi_yEq12_i1 = Y4 + coeffi_yEq8_i[1] - 255;

    yEq12_tmp0 = a[coeffi_yEq12_i1[7:0]] ^ coeffi_yEq8[0];
  end
  convert_table
    convert_table_yEq12_Eq12_tmp2(
      .integer_value(yEq12_tmp0), // input integer
      .an_value(yEq12_tmp1) // an_value
    );
  always@* begin
    if(sol_num==4)
      if(yEq12_tmp1 < coeffi_yEq8_i[2])
        Y3 = 255 - coeffi_yEq8_i[2] + yEq12_tmp1;
      else if(yEq12_tmp1 - coeffi_yEq8_i[2] < 256)
        Y3 = yEq12_tmp1 - coeffi_yEq8_i[2];
      else
        Y3 = yEq12_tmp1 - coeffi_yEq8_i[2] - 255;
    else // sol_num == 3
      if(coeffi_yEq8_i[0] < coeffi_yEq8_i[2])
        Y3 = 255 - coeffi_yEq8_i[2] + coeffi_yEq8_i[0] ;
      else if(coeffi_yEq8_i[0] - coeffi_yEq8_i[2] < 256)
        Y3 = coeffi_yEq8_i[0] - coeffi_yEq8_i[2];
      else
        Y3 = coeffi_yEq8_i[0] - coeffi_yEq8_i[2] - 255;
  end

  // consider Eq14 to get Y2 //
  reg [8:0] Y2;
  reg [7:0] yEq14_tmp0;
  wire [8:0] yEq14_tmp1;
  reg [8:0] coeffi_yEq14_i2;
  reg [8:0] coeffi_yEq14_i1;
  always@* begin
    if (Y4 + coeffi_yEq5_i[1] < 256)
      coeffi_yEq14_i1 = Y4 + coeffi_yEq5_i[1];
    else
      coeffi_yEq14_i1 = Y4 + coeffi_yEq5_i[1] - 255;
      
    if (Y3 + coeffi_yEq5_i[2] < 256)
      coeffi_yEq14_i2 = Y3 + coeffi_yEq5_i[2];
    else
      coeffi_yEq14_i2 = Y3 + coeffi_yEq5_i[2] - 255;

    if(sol_num==4)
      yEq14_tmp0 = a[coeffi_yEq14_i1[7:0]] ^ a[coeffi_yEq14_i2[7:0]] ^ coeffi_yEq5[0];
    else if(sol_num==3)
      yEq14_tmp0 = a[coeffi_yEq14_i2[7:0]] ^ coeffi_yEq5[0];
		else // sol_num==2
			yEq14_tmp0 = coeffi_yEq5[0];
  end
  convert_table
    convert_table_yEq14_Eq14_tmp0(
      .integer_value(yEq14_tmp0), // input integer
      .an_value(yEq14_tmp1) // an_value
    );
  always@* begin
    if(yEq14_tmp1 < coeffi_yEq5_i[3])
      Y2 = 255 - coeffi_yEq5_i[3] + yEq14_tmp1 ;
    else if(yEq14_tmp1 - coeffi_yEq5_i[3] < 256)
      Y2 = yEq14_tmp1 - coeffi_yEq5_i[3];
    else
      Y2 = yEq14_tmp1 - coeffi_yEq5_i[3] - 255;
  end

  // consider Eq16 to get Y1 //
  reg [8:0] Y1;
  reg [7:0] yEq16_tmp0;
  wire [8:0] yEq16_tmp1;
  reg [8:0] coeffi_yEq16_i3;
  reg [8:0] coeffi_yEq16_i2;
  reg [8:0] coeffi_yEq16_i1;
  always@* begin
    if (Y4 + i_sol[3] < 256)
      coeffi_yEq16_i1 = Y4 + i_sol[3];
    else
      coeffi_yEq16_i1 = Y4 + i_sol[3] - 255;
      
    if (Y3 + i_sol[2] < 256)
      coeffi_yEq16_i2 = Y3 + i_sol[2];
    else
      coeffi_yEq16_i2 = Y3 + i_sol[2] - 255;

    if (Y2 + i_sol[1] < 256)
      coeffi_yEq16_i3 = Y2 + i_sol[1];
    else
      coeffi_yEq16_i3 = Y2 + i_sol[1] - 255;
		
		if(sol_num==4)
    	yEq16_tmp0 = a[coeffi_yEq16_i1[7:0]] ^ a[coeffi_yEq16_i2[7:0]] ^ a[coeffi_yEq16_i3[7:0]] ^ S0;
		else if(sol_num==3)
			yEq16_tmp0 = a[coeffi_yEq16_i2[7:0]] ^ a[coeffi_yEq16_i3[7:0]] ^ S0;
		else if(sol_num==2)
			yEq16_tmp0 = a[coeffi_yEq16_i3[7:0]] ^ S0;
		else
			yEq16_tmp0 = S0;
  end
  convert_table
    convert_table_yEq16_Eq16_tmp0(
      .integer_value(yEq16_tmp0), // input integer
      .an_value(yEq16_tmp1) // an_value
    );
  always@* begin
	  if(yEq16_tmp1 < i_sol[0] )
	    Y1 = 255 - i_sol[0] + yEq16_tmp1;
	  else if(yEq16_tmp1 - i_sol[0] < 256)
	    Y1 = yEq16_tmp1 - i_sol[0];
	  else
	    Y1 = yEq16_tmp1 - i_sol[0] - 255;
  end
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// calculate the offset //
	reg [7:0] offset [0:3];
	always@* begin
		if(Y1 + i_sol[0] < 256)
			offset[0] = Y1 + i_sol[0];
		else
			offset[0] = Y1  + i_sol[0] - 255;
		if(Y2 + i_sol[1] < 256)
			offset[1] = Y2 + i_sol[1];
		else
			offset[1] = Y2  + i_sol[1] - 255;
		if(Y3 + i_sol[2] < 256)
			offset[2] = Y3 + i_sol[2];
		else
			offset[2] = Y3  + i_sol[2] - 255;
		if(Y4 + i_sol[3] < 256)
			offset[3] = Y4 + i_sol[3];
		else
			offset[3] = Y4  + i_sol[3] - 255;
	end
	// calculate the correct word//
	reg[7:0] corr_word[0:3];
	always@* begin
		corr_word[0] = codeword_array[43-i_sol[0]] ^ a[offset[0]];
		corr_word[1] = codeword_array[43-i_sol[1]] ^ a[offset[1]];
		corr_word[2] = codeword_array[43-i_sol[2]] ^ a[offset[2]];
		corr_word[3] = codeword_array[43-i_sol[3]] ^ a[offset[3]];
	end
	// correct the codeword //
	always@* begin
		correct_codeword = codeword;
		if(sol_num==4) begin
			{correct_codeword[(43-i_sol[0])*8+7], correct_codeword[(43-i_sol[0])*8+6], correct_codeword[(43-i_sol[0])*8+5], correct_codeword[(43-i_sol[0])*8+4], correct_codeword[(43-i_sol[0])*8+3], correct_codeword[(43-i_sol[0])*8+2], correct_codeword[(43-i_sol[0])*8+1], correct_codeword[(43-i_sol[0])*8+0]}
			= corr_word[0];
			{correct_codeword[(43-i_sol[1])*8+7], correct_codeword[(43-i_sol[1])*8+6], correct_codeword[(43-i_sol[1])*8+5], correct_codeword[(43-i_sol[1])*8+4], correct_codeword[(43-i_sol[1])*8+3], correct_codeword[(43-i_sol[1])*8+2], correct_codeword[(43-i_sol[1])*8+1], correct_codeword[(43-i_sol[1])*8+0]}
			= corr_word[1];
			{correct_codeword[(43-i_sol[2])*8+7], correct_codeword[(43-i_sol[2])*8+6], correct_codeword[(43-i_sol[2])*8+5], correct_codeword[(43-i_sol[2])*8+4], correct_codeword[(43-i_sol[2])*8+3], correct_codeword[(43-i_sol[2])*8+2], correct_codeword[(43-i_sol[2])*8+1], correct_codeword[(43-i_sol[2])*8+0]}
			= corr_word[2];
			{correct_codeword[(43-i_sol[3])*8+7], correct_codeword[(43-i_sol[3])*8+6], correct_codeword[(43-i_sol[3])*8+5], correct_codeword[(43-i_sol[3])*8+4], correct_codeword[(43-i_sol[3])*8+3], correct_codeword[(43-i_sol[3])*8+2], correct_codeword[(43-i_sol[3])*8+1], correct_codeword[(43-i_sol[3])*8+0]}
			= corr_word[3];
		end
		else if(sol_num==3) begin
			{correct_codeword[(43-i_sol[0])*8+7], correct_codeword[(43-i_sol[0])*8+6], correct_codeword[(43-i_sol[0])*8+5], correct_codeword[(43-i_sol[0])*8+4], correct_codeword[(43-i_sol[0])*8+3], correct_codeword[(43-i_sol[0])*8+2], correct_codeword[(43-i_sol[0])*8+1], correct_codeword[(43-i_sol[0])*8+0]}
			= corr_word[0];
			{correct_codeword[(43-i_sol[1])*8+7], correct_codeword[(43-i_sol[1])*8+6], correct_codeword[(43-i_sol[1])*8+5], correct_codeword[(43-i_sol[1])*8+4], correct_codeword[(43-i_sol[1])*8+3], correct_codeword[(43-i_sol[1])*8+2], correct_codeword[(43-i_sol[1])*8+1], correct_codeword[(43-i_sol[1])*8+0]}
			= corr_word[1];
			{correct_codeword[(43-i_sol[2])*8+7], correct_codeword[(43-i_sol[2])*8+6], correct_codeword[(43-i_sol[2])*8+5], correct_codeword[(43-i_sol[2])*8+4], correct_codeword[(43-i_sol[2])*8+3], correct_codeword[(43-i_sol[2])*8+2], correct_codeword[(43-i_sol[2])*8+1], correct_codeword[(43-i_sol[2])*8+0]}
			= corr_word[2];
		end
		else if(sol_num==2) begin
			{correct_codeword[(43-i_sol[0])*8+7], correct_codeword[(43-i_sol[0])*8+6], correct_codeword[(43-i_sol[0])*8+5], correct_codeword[(43-i_sol[0])*8+4], correct_codeword[(43-i_sol[0])*8+3], correct_codeword[(43-i_sol[0])*8+2], correct_codeword[(43-i_sol[0])*8+1], correct_codeword[(43-i_sol[0])*8+0]}
			= corr_word[0];
			{correct_codeword[(43-i_sol[1])*8+7], correct_codeword[(43-i_sol[1])*8+6], correct_codeword[(43-i_sol[1])*8+5], correct_codeword[(43-i_sol[1])*8+4], correct_codeword[(43-i_sol[1])*8+3], correct_codeword[(43-i_sol[1])*8+2], correct_codeword[(43-i_sol[1])*8+1], correct_codeword[(43-i_sol[1])*8+0]}
			= corr_word[1];
		end
		else
			{correct_codeword[(43-i_sol[0])*8+7], correct_codeword[(43-i_sol[0])*8+6], correct_codeword[(43-i_sol[0])*8+5], correct_codeword[(43-i_sol[0])*8+4], correct_codeword[(43-i_sol[0])*8+3], correct_codeword[(43-i_sol[0])*8+2], correct_codeword[(43-i_sol[0])*8+1], correct_codeword[(43-i_sol[0])*8+0]}
			= corr_word[0];
	end

	



  





  

endmodule







