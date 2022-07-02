/*
* Module      : rop3_lut256
* Description : Implement this module using the look-up table (LUT) 
*               This module should support all the possible modes of ROP3.
* Notes       : Please remember to
*               (1) make the bit-length of {P, S, D, Result} parameterizable
*               (2) make the input/output to be a register
*/

module rop3_lut256
#(
  parameter N = 8
)
(
  input clk,
  input [N-1:0] P,
  input [N-1:0] S,
  input [N-1:0] D,
  input [7:0] Mode,
  output reg [N-1:0] Result
);

reg [N-1:0] P_tmp;
reg [N-1:0] S_tmp;
reg [N-1:0] D_tmp;
reg [7:0] Mode_tmp;
reg [N-1:0] function_out;

// input register
always@(posedge clk)begin
	P_tmp <= P;
	S_tmp <= S;
	D_tmp <= D;
	Mode_tmp <= Mode;
end

// output register
always@(posedge clk)begin
	Result <= function_out;
end

// look up table
always@*
case(Mode_tmp)
  8'd0: function_out = 8'h00;
  8'd1: function_out = ~ ( (D_tmp | (P_tmp | S_tmp) ) );
  8'd2: function_out =	D_tmp & ( ~ (P_tmp | S_tmp) );
  8'd3: function_out = ~ (P_tmp | S_tmp);
  8'd4: function_out =	S_tmp & ( ~ (D_tmp | P_tmp) );
  8'd5: function_out = ~ (D_tmp | P_tmp);
  8'd6: function_out = ~ (P_tmp | (~ (D_tmp ^ S_tmp)));
  8'd7: function_out = ~ (P_tmp | (D_tmp & S_tmp));
  8'd8: function_out =	S_tmp & (D_tmp & (~ P_tmp));
  8'd9: function_out = ~ (P_tmp | (D_tmp ^ S_tmp));
  8'd10: function_out = D_tmp & (~ P_tmp);
  8'd11: function_out =	~ (P_tmp | (S_tmp & (~ D_tmp)));
  8'd12: function_out =	S_tmp & (~ P_tmp);
  8'd13: function_out = ~ (P_tmp | (D_tmp & (~ S_tmp)));
  8'd14: function_out = ~ (P_tmp | (~(D_tmp | S_tmp)));
  8'd15: function_out = ~ P_tmp;
  8'd16: function_out =	P_tmp & (~ (D_tmp | S_tmp));
  8'd17: function_out =	~ (D_tmp | S_tmp);
  8'd18: function_out =	~ (S_tmp | (~ (D_tmp ^ P_tmp)));
  8'd19: function_out =	~ (S_tmp | (D_tmp & P_tmp));
  8'd20: function_out =	~ (D_tmp | (~ (P_tmp ^ S_tmp)));
  8'd21: function_out =	~ (D_tmp | (P_tmp & S_tmp));
  8'd22: function_out =	P_tmp ^ (S_tmp ^ (D_tmp & (~ (P_tmp & S_tmp))));
  8'd23: function_out =	~ (S_tmp ^ ((S_tmp ^ P_tmp) & (D_tmp ^ S_tmp)));
  8'd24: function_out =	(S_tmp ^ P_tmp) & (P_tmp ^ D_tmp);
  8'd25: function_out =	~ (S_tmp ^ (D_tmp & (~ (P_tmp & S_tmp))));
  8'd26: function_out =	P_tmp ^ (D_tmp | (S_tmp & P_tmp));
  8'd27: function_out =	~ (S_tmp ^ (D_tmp & (P_tmp ^ S_tmp))); 
  8'd28: function_out =	P_tmp ^ (S_tmp | (D_tmp & P_tmp));
  8'd29: function_out =	~ (D_tmp ^ (S_tmp & (P_tmp ^ D_tmp)));
  8'd30: function_out =	P_tmp ^ (D_tmp | S_tmp);
  8'd31: function_out =	~ (P_tmp & (D_tmp | S_tmp));
  8'd32: function_out =	D_tmp & (P_tmp & (~S_tmp));
  8'd33: function_out =	~ (S_tmp | (D_tmp ^ P_tmp));
  8'd34: function_out =	D_tmp & (~S_tmp);
  8'd35: function_out =	~ (S_tmp | (P_tmp & (~D_tmp)));
  8'd36: function_out =	(S_tmp ^ P_tmp) & (D_tmp ^ S_tmp);
  8'd37: function_out =	~ (P_tmp ^ (D_tmp & (~ (S_tmp & P_tmp))));
  8'd38: function_out =	S_tmp ^ (D_tmp | (P_tmp & S_tmp));
  8'd39: function_out =	S_tmp ^ (D_tmp | (~ (P_tmp ^ S_tmp)));
  8'd40: function_out = D_tmp & (P_tmp ^ S_tmp); //0x28
  8'd41: function_out = ~ (P_tmp ^ (S_tmp ^ (D_tmp | (P_tmp & S_tmp))));
  8'd42: function_out =	D_tmp & (~ (P_tmp & S_tmp));
  8'd43: function_out =	~ (S_tmp ^ ((S_tmp ^ P_tmp) & (P_tmp ^ D_tmp)));
  8'd44: function_out =	S_tmp ^ (P_tmp & (D_tmp | S_tmp));
  8'd45: function_out =	P_tmp ^ (S_tmp | (~D_tmp));
  8'd46: function_out =	P_tmp ^ (S_tmp | (D_tmp ^ P_tmp));
  8'd47: function_out =	~ (P_tmp & (S_tmp | (~D_tmp)));
  8'd48: function_out =	P_tmp & (~ S_tmp);
  8'd49: function_out =	~ (S_tmp | (D_tmp & (~P_tmp)));
  8'd50: function_out = S_tmp ^ (D_tmp | (P_tmp | S_tmp));
  8'd51: function_out =	~S_tmp;
  8'd52: function_out =	S_tmp ^ (P_tmp | (D_tmp & S_tmp));
  8'd53: function_out =	S_tmp ^ (P_tmp | (~ (D_tmp ^ S_tmp)));
  8'd54: function_out =	S_tmp ^ (D_tmp | P_tmp);
  8'd55: function_out =	~ (S_tmp & (D_tmp | P_tmp));
  8'd56: function_out =	P_tmp ^ (S_tmp & (D_tmp | P_tmp));
  8'd57: function_out =	S_tmp ^ (P_tmp | (~ D_tmp));
  8'd58: function_out =	S_tmp ^ (P_tmp | (D_tmp ^ S_tmp));
  8'd59: function_out =	~ (S_tmp & (P_tmp | (~ D_tmp)));
  8'd60: function_out = P_tmp ^ S_tmp; // 0x3c
  8'd61: function_out =	S_tmp ^ (P_tmp | (~ (D_tmp | S_tmp)));
  8'd62: function_out =	S_tmp ^ (P_tmp | (D_tmp & (~ S_tmp)));
  8'd63: function_out =	~ (P_tmp & S_tmp);
  8'd64: function_out =	P_tmp & (S_tmp & (~ D_tmp)); // 0x40
  8'd65: function_out =	(~P_tmp & ~S_tmp & ~D_tmp) | (P_tmp & S_tmp & ~D_tmp);
  8'd66: function_out =	(S_tmp ^ D_tmp) & (P_tmp ^ D_tmp);
  8'd67: function_out =	~ (S_tmp ^ (P_tmp & (~ (D_tmp & S_tmp))));
  8'd68: function_out =	S_tmp & (~ D_tmp);
  8'd69: function_out =	~ (D_tmp | (P_tmp & (~ S_tmp)));
  8'd70: function_out = D_tmp ^ (S_tmp | (P_tmp & D_tmp));
  8'd71: function_out =	~ P_tmp ^ (S_tmp & (D_tmp ^ P_tmp));
  8'd72: function_out =	S_tmp & (D_tmp ^ P_tmp);
  8'd73: function_out =	~ (P_tmp ^ (D_tmp ^ (S_tmp | (P_tmp & D_tmp))));
  8'd74: function_out =	D_tmp ^ (P_tmp & (S_tmp | D_tmp));
  8'd75: function_out =	P_tmp ^ (D_tmp | (~ S_tmp));
  8'd76: function_out =	S_tmp & (~ (D_tmp & P_tmp));
  8'd77: function_out =	~ (S_tmp ^ ((S_tmp ^ P_tmp) | (D_tmp ^ S_tmp)));
  8'd78: function_out =	P_tmp ^ (D_tmp | (S_tmp ^ P_tmp));
  8'd79: function_out =	~ (P_tmp & (D_tmp | (~S_tmp)));
  8'd80: function_out = (~ D_tmp) & P_tmp;
  8'd81: function_out =	~ (D_tmp | (S_tmp & (~P_tmp)));
  8'd82: function_out =	D_tmp ^ (P_tmp | (S_tmp & D_tmp));
  8'd83: function_out =	~ (S_tmp ^ (P_tmp & (D_tmp ^ S_tmp)));
  8'd84: function_out =	~ (D_tmp | (~ (P_tmp | S_tmp)));
  8'd85: function_out =	~ D_tmp;
  8'd86: function_out =	D_tmp ^ (P_tmp | S_tmp);
  8'd87: function_out =	~ (D_tmp & (P_tmp | S_tmp));
  8'd88: function_out =	P_tmp ^ (D_tmp & (S_tmp | P_tmp));
  8'd89: function_out =	D_tmp ^ (P_tmp | (~ S_tmp));
  8'd90: function_out = D_tmp ^ P_tmp; //ox5A
  8'd91: function_out =	D_tmp ^ (P_tmp | (~ (S_tmp | D_tmp)));
  8'd92: function_out =	D_tmp ^ (P_tmp | (S_tmp ^ D_tmp));
  8'd93: function_out =	~ (D_tmp & (P_tmp | (~ S_tmp)));
  8'd94: function_out =	D_tmp ^ (P_tmp | (S_tmp & (~ D_tmp)));
  8'd95: function_out =	~ (D_tmp & P_tmp);
  8'd96: function_out =	P_tmp & (D_tmp ^ S_tmp);
  8'd97: function_out =	~ (D_tmp ^ (S_tmp ^ (P_tmp | (D_tmp & S_tmp))));
  8'd98: function_out =	D_tmp ^ (S_tmp & (P_tmp | D_tmp));
  8'd99: function_out =	S_tmp ^ (D_tmp | (~ P_tmp));
  8'd100: function_out = S_tmp ^ (D_tmp & (P_tmp | S_tmp)); // 0x64
  8'd101: function_out = D_tmp ^ (S_tmp | (~ P_tmp));
  8'd102: function_out = D_tmp ^ S_tmp;
  8'd103: function_out = S_tmp ^ (D_tmp | (~ (P_tmp | S_tmp)));
  8'd104: function_out = ~ (D_tmp ^ (S_tmp ^ (P_tmp | (~ (D_tmp | S_tmp)))));
  8'd105: function_out = ~ (P_tmp ^ (D_tmp ^ S_tmp));
  8'd106: function_out = D_tmp ^ (P_tmp & S_tmp);
  8'd107: function_out = ~ (P_tmp ^ (S_tmp ^ (D_tmp & (P_tmp | S_tmp))));
  8'd108: function_out = S_tmp ^ (D_tmp & P_tmp);
  8'd109: function_out = ~ (P_tmp ^ (D_tmp ^ (S_tmp & (P_tmp | D_tmp))));
  8'd110: function_out = S_tmp ^ (D_tmp & (P_tmp | (~ S_tmp)));
  8'd111: function_out = ~ (P_tmp & (~ (D_tmp ^ S_tmp)));
  8'd112: function_out = P_tmp & (~ (D_tmp & S_tmp));
  8'd113: function_out = ~ (S_tmp ^ ((S_tmp ^ D_tmp) & (P_tmp ^ D_tmp)));
  8'd114: function_out = S_tmp ^ (D_tmp | (P_tmp ^ S_tmp));
  8'd115: function_out = ~ (S_tmp & (D_tmp | (~P_tmp)));
  8'd116: function_out = D_tmp ^ (S_tmp | (P_tmp ^ D_tmp));
  8'd117: function_out = ~ (D_tmp & (S_tmp | (~ P_tmp)));
  8'd118: function_out = S_tmp ^ (D_tmp | (P_tmp & (~ S_tmp)));
  8'd119: function_out = ~ (D_tmp & S_tmp);
  8'd120: function_out = P_tmp ^ (D_tmp & S_tmp);
  8'd121: function_out = ~ (D_tmp ^ (S_tmp ^ (P_tmp & (D_tmp | S_tmp))));
  8'd122: function_out = D_tmp ^ (P_tmp & (S_tmp | (~ D_tmp)));
  8'd123: function_out = ~ (S_tmp & (~ (D_tmp ^ P_tmp)));
  8'd124: function_out = S_tmp ^ (P_tmp & (D_tmp | (~ S_tmp)));
  8'd125: function_out = ~ (D_tmp & (~ (P_tmp ^ S_tmp)));
  8'd126: function_out = (S_tmp ^ P_tmp) | (D_tmp ^ S_tmp);
  8'd127: function_out = ~ (D_tmp & (P_tmp & S_tmp));
  8'd128: function_out = D_tmp & (P_tmp & S_tmp);
  8'd129: function_out = ~ ((P_tmp ^ S_tmp) | (D_tmp ^ S_tmp));
  8'd130: function_out = D_tmp & (~ (P_tmp ^ S_tmp)); // 0X82
  8'd131: function_out = ~ (S_tmp ^ (P_tmp & (D_tmp | (~ S_tmp))));
  8'd132: function_out = S_tmp & (~ (D_tmp ^ P_tmp));
  8'd133: function_out = ~ (P_tmp ^ (D_tmp & (S_tmp | (~ P_tmp))));
  8'd134: function_out = D_tmp ^ (S_tmp ^ (P_tmp & (D_tmp | S_tmp)));
  8'd135: function_out = ~ (P_tmp ^ (D_tmp & S_tmp));
  8'd136: function_out = D_tmp & S_tmp;
  8'd137: function_out = ~ (S_tmp ^ (D_tmp | (P_tmp & (~ S_tmp))));
  8'd138: function_out = D_tmp & (S_tmp | (~ P_tmp));
  8'd139: function_out = (~P_tmp & ~S_tmp) | (S_tmp & D_tmp);
  8'd140: function_out = S_tmp & (D_tmp | (~ P_tmp));
  8'd141: function_out = ~ (S_tmp ^ (D_tmp | (P_tmp ^ S_tmp)));
  8'd142: function_out = S_tmp ^ ((S_tmp ^ D_tmp) & (P_tmp ^ D_tmp));
  8'd143: function_out = ~ (P_tmp & (~ (D_tmp & S_tmp)));
  8'd144: function_out = P_tmp & (~ (D_tmp ^ S_tmp));
  8'd145: function_out = ~ (S_tmp ^ (D_tmp & (P_tmp | (~ S_tmp))));
  8'd146: function_out = D_tmp ^ (P_tmp ^ (S_tmp & (D_tmp | P_tmp)));
  8'd147: function_out = ~ (S_tmp ^ (P_tmp & D_tmp));
  8'd148: function_out = P_tmp ^ (S_tmp ^ (D_tmp & (P_tmp | S_tmp)));
  8'd149: function_out = ~ (D_tmp ^ (P_tmp & S_tmp));
  8'd150: function_out = D_tmp ^ (P_tmp ^ S_tmp);
  8'd151: function_out = P_tmp ^ (S_tmp ^ (D_tmp | (~ (P_tmp | S_tmp))));
  8'd152: function_out = ~ (S_tmp ^ (D_tmp | (~ (P_tmp | S_tmp))));
  8'd153: function_out = ~ (D_tmp ^ S_tmp);
  8'd154: function_out = D_tmp ^ (P_tmp & (~ S_tmp));
  8'd155: function_out = ~ (S_tmp ^ (D_tmp & (P_tmp | S_tmp)));
  8'd156: function_out = S_tmp ^ (P_tmp & (~ D_tmp));
  8'd157: function_out = ~ (D_tmp ^ (S_tmp & (P_tmp | D_tmp)));
  8'd158: function_out = D_tmp ^ (S_tmp ^ (P_tmp | (D_tmp & S_tmp)));
  8'd159: function_out = ~ (P_tmp & (D_tmp ^ S_tmp));
  8'd160: function_out = (D_tmp & P_tmp);
  8'd161: function_out = 	~ (P_tmp ^ (D_tmp | (S_tmp & (~ P_tmp))));
  8'd162: function_out = D_tmp & (P_tmp | (~ S_tmp));
  8'd163: function_out = ~ (D_tmp ^ (P_tmp | (S_tmp ^ D_tmp)));
  8'd164: function_out = ~ (P_tmp ^ (D_tmp | (~ (S_tmp | P_tmp))));
  8'd165: function_out = ~ (P_tmp ^ D_tmp);
  8'd166: function_out = D_tmp ^ (S_tmp & (~ P_tmp));
  8'd167: function_out = ~ (P_tmp ^ (D_tmp & (S_tmp | P_tmp)));
  8'd168: function_out = D_tmp & (P_tmp | S_tmp);
  8'd169: function_out = ~ (D_tmp ^ (P_tmp | S_tmp));
  8'd170: function_out = D_tmp; // 0xAA
  8'd171: function_out = D_tmp | (~ (P_tmp | S_tmp));
  8'd172: function_out = S_tmp ^ (P_tmp & (D_tmp ^ S_tmp));
  8'd173: function_out = ~ (D_tmp ^ (P_tmp | (S_tmp & D_tmp)));
  8'd174: function_out = D_tmp | (S_tmp & (~ P_tmp));
  8'd175: function_out = D_tmp | (~ P_tmp);
  8'd176: function_out = P_tmp & (D_tmp | (~ S_tmp));
  8'd177: function_out = ~ (P_tmp ^ (D_tmp | (S_tmp ^ P_tmp)));
  8'd178: function_out = S_tmp ^ ((S_tmp ^ P_tmp) | (D_tmp ^ S_tmp));
  8'd179: function_out = ~ (S_tmp & (~ (D_tmp & P_tmp)));
  8'd180: function_out = 	P_tmp ^ (S_tmp & (~ D_tmp));
  8'd181: function_out = 	~ (D_tmp ^ (P_tmp & (S_tmp | D_tmp)));
  8'd182: function_out = D_tmp ^ (P_tmp ^ (S_tmp | (D_tmp & P_tmp)));
  8'd183: function_out = ~ (S_tmp & (D_tmp ^ P_tmp));
  8'd184: function_out = P_tmp ^ (S_tmp & (D_tmp ^ P_tmp));
  8'd185: function_out = ~ (D_tmp ^ (S_tmp | (P_tmp & D_tmp)));
  8'd186: function_out = D_tmp | (P_tmp & (~ S_tmp));
  8'd187: function_out = D_tmp | (~ S_tmp);
  8'd188: function_out = S_tmp ^ (P_tmp & (~ (D_tmp & S_tmp)));
  8'd189: function_out = ~ ((S_tmp ^ D_tmp) & (P_tmp ^ D_tmp));
  8'd190: function_out = D_tmp | (P_tmp ^ S_tmp); // 0xBE
  8'd191: function_out = D_tmp | (~ (P_tmp & S_tmp));
  8'd192: function_out = P_tmp & S_tmp;
  8'd193: function_out = ~ (S_tmp ^ (P_tmp | (D_tmp & (~ S_tmp))));
  8'd194: function_out = ~ (S_tmp ^ (P_tmp | (~ (D_tmp | S_tmp))));
  8'd195: function_out = ~ (P_tmp ^ S_tmp);
  8'd196: function_out = S_tmp & (P_tmp | (~ D_tmp));
  8'd197: function_out = ~ (S_tmp ^ (P_tmp | (D_tmp ^ S_tmp)));
  8'd198: function_out = S_tmp ^ (D_tmp & (~ P_tmp));
  8'd199: function_out = ~ (P_tmp ^ (S_tmp & (D_tmp | P_tmp)));
  8'd200: function_out = S_tmp & (D_tmp | P_tmp);
  8'd201: function_out = ~ (S_tmp ^ (P_tmp | D_tmp));
  8'd202: function_out = D_tmp ^ (P_tmp & (S_tmp ^ D_tmp));
  8'd203: function_out = ~ (S_tmp ^ (P_tmp | (D_tmp & S_tmp)));
  8'd204: function_out = S_tmp;
  8'd205: function_out = S_tmp | (~ (D_tmp | P_tmp));
  8'd206: function_out = S_tmp | (D_tmp & (~ P_tmp));
  8'd207: function_out = S_tmp | (~ P_tmp);
  8'd208: function_out = P_tmp & (S_tmp | (~ D_tmp));
  8'd209: function_out = ~ (P_tmp ^ (S_tmp | (D_tmp ^ P_tmp)));
  8'd210: function_out = P_tmp ^ (D_tmp & (~ S_tmp));
  8'd211: function_out = ~ (S_tmp ^ (P_tmp & (D_tmp | S_tmp)));
  8'd212: function_out = S_tmp ^ ((S_tmp ^ P_tmp) & (P_tmp ^ D_tmp));
  8'd213: function_out = ~ (D_tmp & (~ (P_tmp & S_tmp)));
  8'd214: function_out = P_tmp ^ (S_tmp ^ (D_tmp | (P_tmp & S_tmp)));
  8'd215: function_out = ~ (D_tmp & (P_tmp ^ S_tmp));
  8'd216: function_out = P_tmp ^ (D_tmp & (S_tmp ^ P_tmp));
  8'd217: function_out = ~ (S_tmp ^ (D_tmp | (P_tmp & S_tmp)));
  8'd218: function_out = D_tmp ^ (P_tmp & (~ (S_tmp & D_tmp)));
  8'd219: function_out = ~ ((S_tmp ^ P_tmp) & (D_tmp ^ S_tmp));
  8'd220: function_out = S_tmp | (P_tmp & (~ D_tmp)); // 0XD_tmpC
  8'd221: function_out = S_tmp | (~ D_tmp);
  8'd222: function_out = S_tmp | (D_tmp ^ P_tmp);
  8'd223: function_out = S_tmp | (~ (D_tmp & P_tmp));
  8'd224: function_out = P_tmp & (D_tmp | S_tmp);
  8'd225: function_out = ~ (P_tmp ^ (D_tmp | S_tmp));
  8'd226: function_out = D_tmp ^ (S_tmp & (P_tmp ^ D_tmp));
  8'd227: function_out = ~ (P_tmp ^ (S_tmp | (D_tmp & P_tmp)));
  8'd228: function_out = S_tmp ^ (D_tmp & (P_tmp ^ S_tmp));
  8'd229: function_out = ~ (P_tmp ^ (D_tmp | (S_tmp & P_tmp)));
  8'd230: function_out = S_tmp ^ (D_tmp & (~ (P_tmp & S_tmp)));
  8'd231: function_out = ~ ((S_tmp ^ P_tmp) & (D_tmp ^ P_tmp));
  8'd232: function_out = S_tmp ^ ((S_tmp ^ P_tmp) & (D_tmp ^ S_tmp));
  8'd233: function_out = ~ (D_tmp ^ (S_tmp ^ (P_tmp & (~ (D_tmp & S_tmp)))));
  8'd234: function_out = D_tmp | (P_tmp & S_tmp);
  8'd235: function_out = D_tmp | (~ (P_tmp ^ S_tmp));
  8'd236: function_out = S_tmp | (D_tmp & P_tmp);
  8'd237: function_out = S_tmp | (~ (D_tmp ^ P_tmp));
  8'd238: function_out = D_tmp | S_tmp;
  8'd239: function_out = S_tmp | (D_tmp | (~ P_tmp));
  8'd240: function_out = P_tmp;
  8'd241: function_out = P_tmp | (~ (D_tmp | S_tmp));
  8'd242: function_out = P_tmp | (D_tmp & (~ S_tmp));
  8'd243: function_out = P_tmp | (~ S_tmp);
  8'd244: function_out = P_tmp | (S_tmp & (~ D_tmp));
  8'd245: function_out = P_tmp | (~ D_tmp);
  8'd246: function_out = P_tmp | (D_tmp ^ S_tmp);
  8'd247: function_out = P_tmp | (~ (D_tmp & S_tmp));
  8'd248: function_out = P_tmp | (D_tmp & S_tmp);
  8'd249: function_out = P_tmp | (~ (D_tmp ^ S_tmp));
  8'd250: function_out = D_tmp | P_tmp;
  8'd251: function_out = D_tmp | (P_tmp | (~ S_tmp));
  8'd252: function_out = P_tmp | S_tmp;
  8'd253: function_out = P_tmp | (S_tmp | (~ D_tmp));
  8'd254: function_out = D_tmp | (P_tmp | S_tmp);
  8'd255: function_out = 8'hFF;
  default: function_out = 8'hxx;
  
endcase

endmodule