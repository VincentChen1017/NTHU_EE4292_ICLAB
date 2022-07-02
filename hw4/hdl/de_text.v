module de_text(
    input clk,
    input srstn,
    input [351:0]codeword,
    input de_text_valid,
    output reg decode_valid,                 //decoded code is valid
    output reg [7:0] decode_jis8_code,       //decoded JIS8 code
    output reg qr_decode_finish 
);
reg [7:0] text_len;
reg [7:0] cnt, ncnt;
reg [7:0] ndecode_jis8_code;
reg ndecode_valid;

always@*begin
    if(de_text_valid) begin
        text_len = {codeword[3], codeword[2], codeword[1], codeword[0], codeword[15], codeword[14], codeword[13], codeword[12]};
        ndecode_valid = 1;
    end
    else begin
        text_len = 8'b0; 
        ndecode_valid = 0;
    end
end

always@* begin
    if(de_text_valid)
        ncnt = cnt + 1;
    else
        ncnt = cnt;
    if(de_text_valid && cnt==text_len)
        qr_decode_finish = 1;
    else
        qr_decode_finish = 0;
end
    
always@* begin
    ndecode_jis8_code = {codeword[11+cnt*8], codeword[10+cnt*8], codeword[9+cnt*8], codeword[8+cnt*8], codeword[23+cnt*8], codeword[22+cnt*8], codeword[21+cnt*8], codeword[20+cnt*8]};
end

always@(posedge clk)begin
    if(~srstn) begin
        cnt <= 0;
        decode_valid <= 0;
    end
    else begin
        cnt <= ncnt;
        decode_valid <= ndecode_valid;
        decode_jis8_code <= ndecode_jis8_code;
    end
end



endmodule