module enigma_part1
#(
  parameter IDLE = 0, 
  parameter LOAD = 1, 
  parameter READY = 2
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
reg [6-1:0] ref_o;
reg [6-1:0] rotA_o;
reg [6-1:0] code_out_tmp;
reg code_valid_tmp;
reg rotorA_en;
reg rotorA_en_tmp;
reg [6-1:0]code_in_tmp;

// flip flop input
always@(posedge clk) begin
	if(~srstn)
		code_in_tmp <= 0;
	else
		code_in_tmp <= code_in;
end

// FSM for state change
always@* begin
  nstate = IDLE;
  case(state)
    IDLE: begin
      if(load)
        nstate = LOAD;
      else
        nstate = IDLE;
    end
    LOAD: begin
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

// rotorA table shift detection
always@(posedge clk)
	if(~srstn)
		rotorA_en <= 0;
	else
		rotorA_en <= rotorA_en_tmp;
always@* begin
	if(encrypt)
		rotorA_en_tmp = 1;
	else
		rotorA_en_tmp = rotorA_en;
end

// rotorA register
always@(posedge clk) begin
  if(~srstn) begin
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
  else if(load) begin
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
  else if(rotorA_en) begin
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
  else begin
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
always@* begin
  rotA_o = rotorA_table[code_in_tmp];
end

// reflector lut
always@* begin
ref_o = 6'd00;
  case(rotA_o)
    6'd0: ref_o = 6'd63;
    6'd1: ref_o = 6'd62;
    6'd2: ref_o = 6'd61;
    6'd3: ref_o = 6'd60;
    6'd4: ref_o = 6'd59;
    6'd5: ref_o = 6'd58;
    6'd6: ref_o = 6'd57;
    6'd7: ref_o = 6'd56;
    6'd8: ref_o = 6'd55;
    6'd9: ref_o = 6'd54;
    6'd10: ref_o = 6'd53;
    6'd11: ref_o = 6'd52;
    6'd12: ref_o = 6'd51;
    6'd13: ref_o = 6'd50;
    6'd14: ref_o = 6'd49;
    6'd15: ref_o = 6'd48;
    6'd16: ref_o = 6'd47;
    6'd17: ref_o = 6'd46;
    6'd18: ref_o = 6'd45;
    6'd19: ref_o = 6'd44;
    6'd20: ref_o = 6'd43;
    6'd21: ref_o = 6'd42;
    6'd22: ref_o = 6'd41;
    6'd23: ref_o = 6'd40;
    6'd24: ref_o = 6'd39;
    6'd25: ref_o = 6'd38;
    6'd26: ref_o = 6'd37;
    6'd27: ref_o = 6'd36;
    6'd28: ref_o = 6'd35;
    6'd29: ref_o = 6'd34;
    6'd30: ref_o = 6'd33;
    6'd31: ref_o = 6'd32;
    6'd32: ref_o = 6'd31;
    6'd33: ref_o = 6'd30;
    6'd34: ref_o = 6'd29;
    6'd35: ref_o = 6'd28;
    6'd36: ref_o = 6'd27;
    6'd37: ref_o = 6'd26;
    6'd38: ref_o = 6'd25;
    6'd39: ref_o = 6'd24;
    6'd40: ref_o = 6'd23;
    6'd41: ref_o = 6'd22;
    6'd42: ref_o = 6'd21;
    6'd43: ref_o = 6'd20;
    6'd44: ref_o = 6'd19;
    6'd45: ref_o = 6'd18;
    6'd46: ref_o = 6'd17;
    6'd47: ref_o = 6'd16;
    6'd48: ref_o = 6'd15;
    6'd49: ref_o = 6'd14;
    6'd50: ref_o = 6'd13;
    6'd51: ref_o = 6'd12;
    6'd52: ref_o = 6'd11;
    6'd53: ref_o = 6'd10;
    6'd54: ref_o = 6'd9;
    6'd55: ref_o = 6'd8;
    6'd56: ref_o = 6'd7;
    6'd57: ref_o = 6'd6;
    6'd58: ref_o = 6'd5;
    6'd59: ref_o = 6'd4;
    6'd60: ref_o = 6'd3;
    6'd61: ref_o = 6'd2;
    6'd62: ref_o = 6'd1;
    6'd63: ref_o = 6'd0;
  endcase
end
 
// Inverse output
always@*
	if(rotorA_en)
		if(ref_o==rotorA_table[0])begin
		  code_out_tmp = 0;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[2])begin
		  code_out_tmp = 2;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[3])begin
		  code_out_tmp = 3;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[4])begin
		  code_out_tmp = 4;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[5])begin
		  code_out_tmp = 5;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[6])begin
		  code_out_tmp = 6;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[7])begin
		  code_out_tmp = 7;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[8])begin
		  code_out_tmp = 8;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[9])begin
		  code_out_tmp = 9;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[10])begin
		  code_out_tmp = 10;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[11])begin
		  code_out_tmp = 11;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[12])begin
		  code_out_tmp = 12;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[13])begin
		  code_out_tmp = 13;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[14])begin
		  code_out_tmp = 14;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[15])begin
		  code_out_tmp = 15;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[16])begin
		  code_out_tmp = 16;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[17])begin
		  code_out_tmp = 17;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[18])begin
		  code_out_tmp = 18;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[19])begin
		  code_out_tmp = 19;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[20])begin
		  code_out_tmp = 20;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[11])begin
		  code_out_tmp = 11;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[12])begin
		  code_out_tmp = 12;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[13])begin
		  code_out_tmp = 13;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[14])begin
		  code_out_tmp = 14;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[15])begin
		  code_out_tmp = 15;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[16])begin
		  code_out_tmp = 16;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[17])begin
		  code_out_tmp = 17;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[18])begin
		  code_out_tmp = 18;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[19])begin
		  code_out_tmp = 19;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[20])begin
		  code_out_tmp = 20;
		  code_valid_tmp = 1;
		end  
		else if(ref_o==rotorA_table[21])begin
		  code_out_tmp = 21;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[22])begin
		  code_out_tmp = 22;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[23])begin
		  code_out_tmp = 23;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[24])begin
		  code_out_tmp = 24;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[25])begin
		  code_out_tmp = 25;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[26])begin
		  code_out_tmp = 26;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[27])begin
		  code_out_tmp = 27;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[28])begin
		  code_out_tmp = 28;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[29])begin
		  code_out_tmp = 29;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[30])begin
		  code_out_tmp = 30;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[31])begin
		  code_out_tmp = 31;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[32])begin
		  code_out_tmp = 32;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[33])begin
		  code_out_tmp = 33;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[34])begin
		  code_out_tmp = 34;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[35])begin
		  code_out_tmp = 35;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[36])begin
		  code_out_tmp = 36;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[37])begin
		  code_out_tmp = 37;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[38])begin
		  code_out_tmp = 38;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[39])begin
		  code_out_tmp = 39;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[40])begin
		  code_out_tmp = 40;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[41])begin
		  code_out_tmp = 41;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[42])begin
		  code_out_tmp = 42;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[43])begin
		  code_out_tmp = 43;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[44])begin
		  code_out_tmp = 44;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[45])begin
		  code_out_tmp = 45;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[46])begin
		  code_out_tmp = 46;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[47])begin
		  code_out_tmp = 47;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[48])begin
		  code_out_tmp = 48;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[49])begin
		  code_out_tmp = 49;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[50])begin
		  code_out_tmp = 50;
		  code_valid_tmp = 1;
		end

		else if(ref_o==rotorA_table[51])begin
		  code_out_tmp = 51;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[52])begin
		  code_out_tmp = 52;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[53])begin
		  code_out_tmp = 53;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[54])begin
		  code_out_tmp = 54;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[55])begin
		  code_out_tmp = 55;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[56])begin
		  code_out_tmp = 56;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[57])begin
		  code_out_tmp = 57;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[58])begin
		  code_out_tmp = 58;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[59])begin
		  code_out_tmp = 59;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[60])begin
		  code_out_tmp = 60;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[61])begin
		  code_out_tmp = 61;
		  code_valid_tmp = 1;
		end
		else if(ref_o==rotorA_table[62])begin
		  code_out_tmp = 62;
		  code_valid_tmp = 1;
		end
		else begin
		  code_out_tmp = 63;
		  code_valid_tmp = 1;
		end
	else begin
			code_out_tmp = 0;
		  code_valid_tmp = 0;
	end	

// flip-flop output
always@(posedge clk)
  if(~srstn) begin
    code_out <= 0;
    code_valid <=0;
  end
  else begin
    code_out <= code_out_tmp;
    code_valid <= code_valid_tmp;
  end
    
  
endmodule
    

