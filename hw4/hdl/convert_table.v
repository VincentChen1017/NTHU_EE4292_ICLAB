module convert_table(
    input [7:0] integer_value, // input integer
    output reg [8:0] an_value // an_value

  );
  wire [7:0] a[0:255];
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

  always@*
  begin
    case(integer_value)
      a[0]:
        an_value = 0;
      a[1]:
        an_value = 1;
      a[2]:
        an_value = 2;
      a[3]:
        an_value = 3;
      a[4]:
        an_value = 4;
      a[5]:
        an_value = 5;
      a[6]:
        an_value = 6;
      a[7]:
        an_value = 7;
      a[8]:
        an_value = 8;
      a[9]:
        an_value = 9;
      a[10]:
        an_value = 10;
      a[11]:
        an_value = 11;
      a[12]:
        an_value = 12;
      a[13]:
        an_value = 13;
      a[14]:
        an_value = 14;
      a[15]:
        an_value = 15;
      a[16]:
        an_value = 16;
      a[17]:
        an_value = 17;
      a[18]:
        an_value = 18;
      a[19]:
        an_value = 19;
      a[20]:
        an_value = 20;
      a[21]:
        an_value = 21;
      a[22]:
        an_value = 22;
      a[23]:
        an_value = 23;
      a[24]:
        an_value = 24;
      a[25]:
        an_value = 25;
      a[26]:
        an_value = 26;
      a[27]:
        an_value = 27;
      a[28]:
        an_value = 28;
      a[29]:
        an_value = 29;
      a[30]:
        an_value = 30;
      a[31]:
        an_value = 31;
      a[32]:
        an_value = 32;
      a[33]:
        an_value = 33;
      a[34]:
        an_value = 34;
      a[35]:
        an_value = 35;
      a[36]:
        an_value = 36;
      a[37]:
        an_value = 37;
      a[38]:
        an_value = 38;
      a[39]:
        an_value = 39;
      a[40]:
        an_value = 40;
      a[41]:
        an_value = 41;
      a[42]:
        an_value = 42;
      a[43]:
        an_value = 43;
      a[44]:
        an_value = 44;
      a[45]:
        an_value = 45;
      a[46]:
        an_value = 46;
      a[47]:
        an_value = 47;
      a[48]:
        an_value = 48;
      a[49]:
        an_value = 49;
      a[50]:
        an_value = 50;
      a[51]:
        an_value = 51;
      a[52]:
        an_value = 52;
      a[53]:
        an_value = 53;
      a[54]:
        an_value = 54;
      a[55]:
        an_value = 55;
      a[56]:
        an_value = 56;
      a[57]:
        an_value = 57;
      a[58]:
        an_value = 58;
      a[59]:
        an_value = 59;
      a[60]:
        an_value = 60;
      a[61]:
        an_value = 61;
      a[62]:
        an_value = 62;
      a[63]:
        an_value = 63;
      a[64]:
        an_value = 64;
      a[65]:
        an_value = 65;
      a[66]:
        an_value = 66;
      a[67]:
        an_value = 67;
      a[68]:
        an_value = 68;
      a[69]:
        an_value = 69;
      a[70]:
        an_value = 70;
      a[71]:
        an_value = 71;
      a[72]:
        an_value = 72;
      a[73]:
        an_value = 73;
      a[74]:
        an_value = 74;
      a[75]:
        an_value = 75;
      a[76]:
        an_value = 76;
      a[77]:
        an_value = 77;
      a[78]:
        an_value = 78;
      a[79]:
        an_value = 79;
      a[80]:
        an_value = 80;
      a[81]:
        an_value = 81;
      a[82]:
        an_value = 82;
      a[83]:
        an_value = 83;
      a[84]:
        an_value = 84;
      a[85]:
        an_value = 85;
      a[86]:
        an_value = 86;
      a[87]:
        an_value = 87;
      a[88]:
        an_value = 88;
      a[89]:
        an_value = 89;
      a[90]:
        an_value = 90;
      a[91]:
        an_value = 91;
      a[92]:
        an_value = 92;
      a[93]:
        an_value = 93;
      a[94]:
        an_value = 94;
      a[95]:
        an_value = 95;
      a[96]:
        an_value = 96;
      a[97]:
        an_value = 97;
      a[98]:
        an_value = 98;
      a[99]:
        an_value = 99;
      a[100]:
        an_value = 100;
      a[101]:
        an_value = 101;
      a[102]:
        an_value = 102;
      a[103]:
        an_value = 103;
      a[104]:
        an_value = 104;
      a[105]:
        an_value = 105;
      a[106]:
        an_value = 106;
      a[107]:
        an_value = 107;
      a[108]:
        an_value = 108;
      a[109]:
        an_value = 109;
      a[110]:
        an_value = 110;
      a[111]:
        an_value = 111;
      a[112]:
        an_value = 112;
      a[113]:
        an_value = 113;
      a[114]:
        an_value = 114;
      a[115]:
        an_value = 115;
      a[116]:
        an_value = 116;
      a[117]:
        an_value = 117;
      a[118]:
        an_value = 118;
      a[119]:
        an_value = 119;
      a[120]:
        an_value = 120;
      a[121]:
        an_value = 121;
      a[122]:
        an_value = 122;
      a[123]:
        an_value = 123;
      a[124]:
        an_value = 124;
      a[125]:
        an_value = 125;
      a[126]:
        an_value = 126;
      a[127]:
        an_value = 127;
      a[128]:
        an_value = 128;
      a[129]:
        an_value = 129;
      a[130]:
        an_value = 130;
      a[131]:
        an_value = 131;
      a[132]:
        an_value = 132;
      a[133]:
        an_value = 133;
      a[134]:
        an_value = 134;
      a[135]:
        an_value = 135;
      a[136]:
        an_value = 136;
      a[137]:
        an_value = 137;
      a[138]:
        an_value = 138;
      a[139]:
        an_value = 139;
      a[140]:
        an_value = 140;
      a[141]:
        an_value = 141;
      a[142]:
        an_value = 142;
      a[143]:
        an_value = 143;
      a[144]:
        an_value = 144;
      a[145]:
        an_value = 145;
      a[146]:
        an_value = 146;
      a[147]:
        an_value = 147;
      a[148]:
        an_value = 148;
      a[149]:
        an_value = 149;
      a[150]:
        an_value = 150;
      a[151]:
        an_value = 151;
      a[152]:
        an_value = 152;
      a[153]:
        an_value = 153;
      a[154]:
        an_value = 154;
      a[155]:
        an_value = 155;
      a[156]:
        an_value = 156;
      a[157]:
        an_value = 157;
      a[158]:
        an_value = 158;
      a[159]:
        an_value = 159;
      a[160]:
        an_value = 160;
      a[161]:
        an_value = 161;
      a[162]:
        an_value = 162;
      a[163]:
        an_value = 163;
      a[164]:
        an_value = 164;
      a[165]:
        an_value = 165;
      a[166]:
        an_value = 166;
      a[167]:
        an_value = 167;
      a[168]:
        an_value = 168;
      a[169]:
        an_value = 169;
      a[170]:
        an_value = 170;
      a[171]:
        an_value = 171;
      a[172]:
        an_value = 172;
      a[173]:
        an_value = 173;
      a[174]:
        an_value = 174;
      a[175]:
        an_value = 175;
      a[176]:
        an_value = 176;
      a[177]:
        an_value = 177;
      a[178]:
        an_value = 178;
      a[179]:
        an_value = 179;
      a[180]:
        an_value = 180;
      a[181]:
        an_value = 181;
      a[182]:
        an_value = 182;
      a[183]:
        an_value = 183;
      a[184]:
        an_value = 184;
      a[185]:
        an_value = 185;
      a[186]:
        an_value = 186;
      a[187]:
        an_value = 187;
      a[188]:
        an_value = 188;
      a[189]:
        an_value = 189;
      a[190]:
        an_value = 190;
      a[191]:
        an_value = 191;
      a[192]:
        an_value = 192;
      a[193]:
        an_value = 193;
      a[194]:
        an_value = 194;
      a[195]:
        an_value = 195;
      a[196]:
        an_value = 196;
      a[197]:
        an_value = 197;
      a[198]:
        an_value = 198;
      a[199]:
        an_value = 199;
      a[200]:
        an_value = 200;
      a[201]:
        an_value = 201;
      a[202]:
        an_value = 202;
      a[203]:
        an_value = 203;
      a[204]:
        an_value = 204;
      a[205]:
        an_value = 205;
      a[206]:
        an_value = 206;
      a[207]:
        an_value = 207;
      a[208]:
        an_value = 208;
      a[209]:
        an_value = 209;
      a[210]:
        an_value = 210;
      a[211]:
        an_value = 211;
      a[212]:
        an_value = 212;
      a[213]:
        an_value = 213;
      a[214]:
        an_value = 214;
      a[215]:
        an_value = 215;
      a[216]:
        an_value = 216;
      a[217]:
        an_value = 217;
      a[218]:
        an_value = 218;
      a[219]:
        an_value = 219;
      a[220]:
        an_value = 220;
      a[221]:
        an_value = 221;
      a[222]:
        an_value = 222;
      a[223]:
        an_value = 223;
      a[224]:
        an_value = 224;
      a[225]:
        an_value = 225;
      a[226]:
        an_value = 226;
      a[227]:
        an_value = 227;
      a[228]:
        an_value = 228;
      a[229]:
        an_value = 229;
      a[230]:
        an_value = 230;
      a[231]:
        an_value = 231;
      a[232]:
        an_value = 232;
      a[233]:
        an_value = 233;
      a[234]:
        an_value = 234;
      a[235]:
        an_value = 235;
      a[236]:
        an_value = 236;
      a[237]:
        an_value = 237;
      a[238]:
        an_value = 238;
      a[239]:
        an_value = 239;
      a[240]:
        an_value = 240;
      a[241]:
        an_value = 241;
      a[242]:
        an_value = 242;
      a[243]:
        an_value = 243;
      a[244]:
        an_value = 244;
      a[245]:
        an_value = 245;
      a[246]:
        an_value = 246;
      a[247]:
        an_value = 247;
      a[248]:
        an_value = 248;
      a[249]:
        an_value = 249;
      a[250]:
        an_value = 250;
      a[251]:
        an_value = 251;
      a[252]:
        an_value = 252;
      a[253]:
        an_value = 253;
      a[254]:
        an_value = 254;
      a[255]:
        an_value = 255;
		default :
				an_value = 0;
    endcase
  end
endmodule
