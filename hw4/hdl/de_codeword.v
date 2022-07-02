module de_codeword(
    input clk,
    input srstn,
    input [624:0]de_array,
    input de_codeword_valid,
    output reg CODE_done,
    output [351:0] codeword
);


always@(posedge clk)
    if(~srstn)
        CODE_done <= 0;
    else if(de_codeword_valid)
        CODE_done <= 1;

////////0//////////
assign codeword[0] = de_array[21*25+23];
assign codeword[1] = de_array[21*25+24];
assign codeword[2] = de_array[22*25+23];
assign codeword[3] = de_array[22*25+24];
assign codeword[4] = de_array[23*25+23];
assign codeword[5] = de_array[23*25+24];
assign codeword[6] = de_array[24*25+23];
assign codeword[7] = de_array[24*25+24];
////////1//////////
assign codeword[8] = de_array[17*25+23];
assign codeword[9] = de_array[17*25+24];
assign codeword[10] = de_array[18*25+23];
assign codeword[11] = de_array[18*25+24];
assign codeword[12] = de_array[19*25+23];
assign codeword[13] = de_array[19*25+24];
assign codeword[14] = de_array[20*25+23];
assign codeword[15] = de_array[20*25+24];
////////2//////////
assign codeword[16] = de_array[13*25+23];
assign codeword[17] = de_array[13*25+24];
assign codeword[18] = de_array[14*25+23];
assign codeword[19] = de_array[14*25+24];
assign codeword[20] = de_array[15*25+23];
assign codeword[21] = de_array[15*25+24];
assign codeword[22] = de_array[16*25+23];
assign codeword[23] = de_array[16*25+24];
////////3//////////
assign codeword[24] = de_array[9*25+23];
assign codeword[25] = de_array[9*25+24];
assign codeword[26] = de_array[10*25+23];
assign codeword[27] = de_array[10*25+24];
assign codeword[28] = de_array[11*25+23];
assign codeword[29] = de_array[11*25+24];
assign codeword[30] = de_array[12*25+23];
assign codeword[31] = de_array[12*25+24];
////////4//////////
assign codeword[32] = de_array[12*25+21];
assign codeword[33] = de_array[12*25+22];
assign codeword[34] = de_array[11*25+21];
assign codeword[35] = de_array[11*25+22];
assign codeword[36] = de_array[10*25+21];
assign codeword[37] = de_array[10*25+22];
assign codeword[38] = de_array[9*25+21];
assign codeword[39] = de_array[9*25+22];
////////5//////////
assign codeword[40] = de_array[16*25+21];
assign codeword[41] = de_array[16*25+22];
assign codeword[42] = de_array[15*25+21];
assign codeword[43] = de_array[15*25+22];
assign codeword[44] = de_array[14*25+21];
assign codeword[45] = de_array[14*25+22];
assign codeword[46] = de_array[13*25+21];
assign codeword[47] = de_array[13*25+22];
////////6//////////
assign codeword[48] = de_array[20*25+21];
assign codeword[49] = de_array[20*25+22];
assign codeword[50] = de_array[19*25+21];
assign codeword[51] = de_array[19*25+22];
assign codeword[52] = de_array[18*25+21];
assign codeword[53] = de_array[18*25+22];
assign codeword[54] = de_array[17*25+21];
assign codeword[55] = de_array[17*25+22];
////////7//////////
assign codeword[56] = de_array[24*25+21];
assign codeword[57] = de_array[24*25+22];
assign codeword[58] = de_array[23*25+21];
assign codeword[59] = de_array[23*25+22];
assign codeword[60] = de_array[22*25+21];
assign codeword[61] = de_array[22*25+22];
assign codeword[62] = de_array[21*25+21];
assign codeword[63] = de_array[21*25+22];
////////8//////////
assign codeword[64] = de_array[21*25+19];
assign codeword[65] = de_array[21*25+20];
assign codeword[66] = de_array[22*25+19];
assign codeword[67] = de_array[22*25+20];
assign codeword[68] = de_array[23*25+19];
assign codeword[69] = de_array[23*25+20];
assign codeword[70] = de_array[24*25+19];
assign codeword[71] = de_array[24*25+20];
////////9//////////
assign codeword[72] = de_array[12*25+19];
assign codeword[73] = de_array[12*25+20];
assign codeword[74] = de_array[13*25+19];
assign codeword[75] = de_array[13*25+20];
assign codeword[76] = de_array[14*25+19];
assign codeword[77] = de_array[14*25+20];
assign codeword[78] = de_array[15*25+19];
assign codeword[79] = de_array[15*25+20];
////////10//////////
assign codeword[80] = de_array[9*25+17];
assign codeword[81] = de_array[9*25+18];
assign codeword[82] = de_array[9*25+19];
assign codeword[83] = de_array[9*25+20];
assign codeword[84] = de_array[10*25+19];
assign codeword[85] = de_array[10*25+20];
assign codeword[86] = de_array[11*25+19];
assign codeword[87] = de_array[11*25+20];
////////11//////////
assign codeword[88] = de_array[13*25+17];
assign codeword[89] = de_array[13*25+18];
assign codeword[90] = de_array[12*25+17];
assign codeword[91] = de_array[12*25+18];
assign codeword[92] = de_array[11*25+17];
assign codeword[93] = de_array[11*25+18];
assign codeword[94] = de_array[10*25+17];
assign codeword[95] = de_array[10*25+18];
////////12//////////
assign codeword[96] = de_array[22*25+17];
assign codeword[97] = de_array[22*25+18];
assign codeword[98] = de_array[21*25+17];
assign codeword[99] = de_array[21*25+18];
assign codeword[100] = de_array[15*25+17];
assign codeword[101] = de_array[15*25+18];
assign codeword[102] = de_array[14*25+17];
assign codeword[103] = de_array[14*25+18];
////////13//////////
assign codeword[104] = de_array[23*25+15];
assign codeword[105] = de_array[23*25+16];
assign codeword[106] = de_array[24*25+15];
assign codeword[107] = de_array[24*25+16];
assign codeword[108] = de_array[24*25+17];
assign codeword[109] = de_array[24*25+18];
assign codeword[110] = de_array[23*25+17];
assign codeword[111] = de_array[23*25+18];
////////14//////////
assign codeword[112] = de_array[17*25+15];
assign codeword[113] = de_array[18*25+15];
assign codeword[114] = de_array[19*25+15];
assign codeword[115] = de_array[20*25+15];
assign codeword[116] = de_array[21*25+15];
assign codeword[117] = de_array[21*25+16];
assign codeword[118] = de_array[22*25+15];
assign codeword[119] = de_array[22*25+16];
////////15//////////
assign codeword[120] = de_array[12*25+16];
assign codeword[121] = de_array[13*25+15];
assign codeword[122] = de_array[13*25+16];
assign codeword[123] = de_array[14*25+15];
assign codeword[124] = de_array[14*25+16];
assign codeword[125] = de_array[15*25+15];
assign codeword[126] = de_array[15*25+16];
assign codeword[127] = de_array[16*25+15];
////////16//////////
assign codeword[128] = de_array[8*25+16];
assign codeword[129] = de_array[9*25+15];
assign codeword[130] = de_array[9*25+16];
assign codeword[131] = de_array[10*25+15];
assign codeword[132] = de_array[10*25+16];
assign codeword[133] = de_array[11*25+15];
assign codeword[134] = de_array[11*25+16];
assign codeword[135] = de_array[12*25+15];
////////17//////////
assign codeword[136] = de_array[3*25+16];
assign codeword[137] = de_array[4*25+15];
assign codeword[138] = de_array[4*25+16];
assign codeword[139] = de_array[5*25+15];
assign codeword[140] = de_array[5*25+16];
assign codeword[141] = de_array[7*25+15];
assign codeword[142] = de_array[7*25+16];
assign codeword[143] = de_array[8*25+15];
////////18//////////
assign codeword[144] = de_array[0*25+14];
assign codeword[145] = de_array[0*25+15];
assign codeword[146] = de_array[0*25+16];
assign codeword[147] = de_array[1*25+15];
assign codeword[148] = de_array[1*25+16];
assign codeword[149] = de_array[2*25+15];
assign codeword[150] = de_array[2*25+16];
assign codeword[151] = de_array[3*25+15];
////////19//////////
assign codeword[152] = de_array[4*25+14];
assign codeword[153] = de_array[3*25+13];
assign codeword[154] = de_array[3*25+14];
assign codeword[155] = de_array[2*25+13];
assign codeword[156] = de_array[2*25+14];
assign codeword[157] = de_array[1*25+13];
assign codeword[158] = de_array[1*25+14];
assign codeword[159] = de_array[0*25+13];
////////20//////////
assign codeword[160] = de_array[9*25+14];
assign codeword[161] = de_array[8*25+13];
assign codeword[162] = de_array[8*25+14];
assign codeword[163] = de_array[7*25+13];
assign codeword[164] = de_array[7*25+14];
assign codeword[165] = de_array[5*25+13];
assign codeword[166] = de_array[5*25+14];
assign codeword[167] = de_array[4*25+13];
////////21//////////
assign codeword[168] = de_array[13*25+14];
assign codeword[169] = de_array[12*25+13];
assign codeword[170] = de_array[12*25+14];
assign codeword[171] = de_array[11*25+13];
assign codeword[172] = de_array[11*25+14];
assign codeword[173] = de_array[10*25+13];
assign codeword[174] = de_array[10*25+14];
assign codeword[175] = de_array[9*25+13];
////////22//////////
assign codeword[176] = de_array[17*25+14];
assign codeword[177] = de_array[16*25+13];
assign codeword[178] = de_array[16*25+14];
assign codeword[179] = de_array[15*25+13];
assign codeword[180] = de_array[15*25+14];
assign codeword[181] = de_array[14*25+13];
assign codeword[182] = de_array[14*25+14];
assign codeword[183] = de_array[13*25+13];
////////23//////////
assign codeword[184] = de_array[21*25+14];
assign codeword[185] = de_array[20*25+13];
assign codeword[186] = de_array[20*25+14];
assign codeword[187] = de_array[19*25+13];
assign codeword[188] = de_array[19*25+14];
assign codeword[189] = de_array[18*25+13];
assign codeword[190] = de_array[18*25+14];
assign codeword[191] = de_array[17*25+13];
////////24//////////
assign codeword[192] = de_array[24*25+12];
assign codeword[193] = de_array[24*25+13];
assign codeword[194] = de_array[24*25+14];
assign codeword[195] = de_array[23*25+13];
assign codeword[196] = de_array[23*25+14];
assign codeword[197] = de_array[22*25+13];
assign codeword[198] = de_array[22*25+14];
assign codeword[199] = de_array[21*25+13];
////////25//////////
assign codeword[200] = de_array[20*25+12];
assign codeword[201] = de_array[21*25+11];
assign codeword[202] = de_array[21*25+12];
assign codeword[203] = de_array[22*25+11];
assign codeword[204] = de_array[22*25+12];
assign codeword[205] = de_array[23*25+11];
assign codeword[206] = de_array[23*25+12];
assign codeword[207] = de_array[24*25+11];
////////26//////////
assign codeword[208] = de_array[16*25+12];
assign codeword[209] = de_array[17*25+11];
assign codeword[210] = de_array[17*25+12];
assign codeword[211] = de_array[18*25+11];
assign codeword[212] = de_array[18*25+12];
assign codeword[213] = de_array[19*25+11];
assign codeword[214] = de_array[19*25+12];
assign codeword[215] = de_array[20*25+11];
////////27//////////
assign codeword[216] = de_array[12*25+12];
assign codeword[217] = de_array[13*25+11];
assign codeword[218] = de_array[13*25+12];
assign codeword[219] = de_array[14*25+11];
assign codeword[220] = de_array[14*25+12];
assign codeword[221] = de_array[15*25+11];
assign codeword[222] = de_array[15*25+12];
assign codeword[223] = de_array[16*25+11];
////////28//////////
assign codeword[224] = de_array[8*25+12];
assign codeword[225] = de_array[9*25+11];
assign codeword[226] = de_array[9*25+12];
assign codeword[227] = de_array[10*25+11];
assign codeword[228] = de_array[10*25+12];
assign codeword[229] = de_array[11*25+11];
assign codeword[230] = de_array[11*25+12];
assign codeword[231] = de_array[12*25+11];
////////29//////////
assign codeword[232] = de_array[3*25+12];
assign codeword[233] = de_array[4*25+11];
assign codeword[234] = de_array[4*25+12];
assign codeword[235] = de_array[5*25+11];
assign codeword[236] = de_array[5*25+12];
assign codeword[237] = de_array[7*25+11];
assign codeword[238] = de_array[7*25+12];
assign codeword[239] = de_array[8*25+11];
////////30//////////
assign codeword[240] = de_array[0*25+10];
assign codeword[241] = de_array[0*25+11];
assign codeword[242] = de_array[0*25+12];
assign codeword[243] = de_array[1*25+11];
assign codeword[244] = de_array[1*25+12];
assign codeword[245] = de_array[2*25+11];
assign codeword[246] = de_array[2*25+12];
assign codeword[247] = de_array[3*25+11];
////////31//////////
assign codeword[248] = de_array[4*25+10];
assign codeword[249] = de_array[3*25+9];
assign codeword[250] = de_array[3*25+10];
assign codeword[251] = de_array[2*25+9];
assign codeword[252] = de_array[2*25+10];
assign codeword[253] = de_array[1*25+9];
assign codeword[254] = de_array[1*25+10];
assign codeword[255] = de_array[0*25+9];
////////32//////////
assign codeword[256] = de_array[9*25+10];
assign codeword[257] = de_array[8*25+9];
assign codeword[258] = de_array[8*25+10];
assign codeword[259] = de_array[7*25+9];
assign codeword[260] = de_array[7*25+10];
assign codeword[261] = de_array[5*25+9];
assign codeword[262] = de_array[5*25+10];
assign codeword[263] = de_array[4*25+9];
////////33//////////
assign codeword[264] = de_array[13*25+10];
assign codeword[265] = de_array[12*25+9];
assign codeword[266] = de_array[12*25+10];
assign codeword[267] = de_array[11*25+9];
assign codeword[268] = de_array[11*25+10];
assign codeword[269] = de_array[10*25+9];
assign codeword[270] = de_array[10*25+10];
assign codeword[271] = de_array[9*25+9];
////////34//////////
assign codeword[272] = de_array[17*25+10];
assign codeword[273] = de_array[16*25+9];
assign codeword[274] = de_array[16*25+10];
assign codeword[275] = de_array[15*25+9];
assign codeword[276] = de_array[15*25+10];
assign codeword[277] = de_array[14*25+9];
assign codeword[278] = de_array[14*25+10];
assign codeword[279] = de_array[13*25+9];
////////35//////////
assign codeword[280] = de_array[21*25+10];
assign codeword[281] = de_array[20*25+9];
assign codeword[282] = de_array[20*25+10];
assign codeword[283] = de_array[19*25+9];
assign codeword[284] = de_array[19*25+10];
assign codeword[285] = de_array[18*25+9];
assign codeword[286] = de_array[18*25+10];
assign codeword[287] = de_array[17*25+9];
////////36//////////
assign codeword[288] = de_array[16*25+8];
assign codeword[289] = de_array[24*25+9];
assign codeword[290] = de_array[24*25+10];
assign codeword[291] = de_array[23*25+9];
assign codeword[292] = de_array[23*25+10];
assign codeword[293] = de_array[22*25+9];
assign codeword[294] = de_array[22*25+10];
assign codeword[295] = de_array[21*25+9];
////////37//////////
assign codeword[296] = de_array[12*25+8];
assign codeword[297] = de_array[13*25+7];
assign codeword[298] = de_array[13*25+8];
assign codeword[299] = de_array[14*25+7];
assign codeword[300] = de_array[14*25+8];
assign codeword[301] = de_array[15*25+7];
assign codeword[302] = de_array[15*25+8];
assign codeword[303] = de_array[16*25+7];
////////38//////////
assign codeword[304] = de_array[9*25+5];
assign codeword[305] = de_array[9*25+7];
assign codeword[306] = de_array[9*25+8];
assign codeword[307] = de_array[10*25+7];
assign codeword[308] = de_array[10*25+8];
assign codeword[309] = de_array[11*25+7];
assign codeword[310] = de_array[11*25+8];
assign codeword[311] = de_array[12*25+7];
////////39//////////
assign codeword[312] = de_array[13*25+5];
assign codeword[313] = de_array[12*25+4];
assign codeword[314] = de_array[12*25+5];
assign codeword[315] = de_array[11*25+4];
assign codeword[316] = de_array[11*25+5];
assign codeword[317] = de_array[10*25+4];
assign codeword[318] = de_array[10*25+5];
assign codeword[319] = de_array[9*25+4];
////////40//////////
assign codeword[320] = de_array[16*25+3];
assign codeword[321] = de_array[16*25+4];
assign codeword[322] = de_array[16*25+5];
assign codeword[323] = de_array[15*25+4];
assign codeword[324] = de_array[15*25+5];
assign codeword[325] = de_array[14*25+4];
assign codeword[326] = de_array[14*25+5];
assign codeword[327] = de_array[13*25+4];
////////41//////////
assign codeword[328] = de_array[12*25+3];
assign codeword[329] = de_array[13*25+2];
assign codeword[330] = de_array[13*25+3];
assign codeword[331] = de_array[14*25+2];
assign codeword[332] = de_array[14*25+3];
assign codeword[333] = de_array[15*25+2];
assign codeword[334] = de_array[15*25+3];
assign codeword[335] = de_array[16*25+2];
////////42//////////
assign codeword[336] = de_array[9*25+1];
assign codeword[337] = de_array[9*25+2];
assign codeword[338] = de_array[9*25+3];
assign codeword[339] = de_array[10*25+2];
assign codeword[340] = de_array[10*25+3];
assign codeword[341] = de_array[11*25+2];
assign codeword[342] = de_array[11*25+3];
assign codeword[343] = de_array[12*25+2];
////////43//////////
assign codeword[344] = de_array[13*25+1];
assign codeword[345] = de_array[12*25+0];
assign codeword[346] = de_array[12*25+1];
assign codeword[347] = de_array[11*25+0];
assign codeword[348] = de_array[11*25+1];
assign codeword[349] = de_array[10*25+0];
assign codeword[350] = de_array[10*25+1];
assign codeword[351] = de_array[9*25+0];

endmodule