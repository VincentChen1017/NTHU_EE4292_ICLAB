module de_mask(
    input clk,
    input srstn,
    input [624:0]qr_array,
    input de_mask_valid,
    output reg [624:0]de_array,
    output reg MASK_done
);
reg [2:0] pat_ID;
reg [624:0] mask;
reg [624:0] nde_array;
integer i,j; // j=x, i=y


always@* begin
    pat_ID = {qr_array[25*8+2], qr_array[25*8+3], qr_array[25*8 +4]} ^ 3'b101;
    
    case(pat_ID)
    3'b000: 
    for(i=0; i<25; i=i+1)
        for(j=0; j<25; j=j+1)begin
            if( (i+j)%2==0 )
                mask[i*25+j] = 1;
            else
                mask[i*25+j] = 0;
        end
    3'b001: 
    for(i=0; i<25; i=i+1)
        for(j=0; j<25; j=j+1)begin
            if( i%2==0 )
                mask[i*25+j] = 1;
            else
                mask[i*25+j] = 0;
        end
    3'b010: 
    for(i=0; i<25; i=i+1)
        for(j=0; j<25; j=j+1)begin
            if( j%3==0 )
                mask[i*25+j] = 1;
            else
                mask[i*25+j] = 0;
        end
    3'b011: 
    for(i=0; i<25; i=i+1)
        for(j=0; j<25; j=j+1)begin
            if( (i+j)%3==0 )
                mask[i*25+j] = 1;
            else
                mask[i*25+j] = 0;
        end
    3'b100: 
    for(i=0; i<25; i=i+1)
        for(j=0; j<25; j=j+1)begin
            if( ((i/2)+(j/3))%2==0 )
                mask[i*25+j] = 1;
            else
                mask[i*25+j] = 0;
        end
    3'b101: 
    for(i=0; i<25; i=i+1)
        for(j=0; j<25; j=j+1)begin
            if( ((i*j)%2+(i*j)%3)==0 )
                mask[i*25+j] = 1;
            else
                mask[i*25+j] = 0;
        end
    3'b110: 
    for(i=0; i<25; i=i+1)
        for(j=0; j<25; j=j+1)begin
            if( ((i*j)%2+(i*j)%3)%2==0  )
                mask[i*25+j] = 1;
            else
                mask[i*25+j] = 0;
        end
    default: 
    for(i=0; i<25; i=i+1)
        for(j=0; j<25; j=j+1)begin
            if( ((i*j)%3+(i+j)%2)%2==0 )
                mask[i*25+j] = 1;
            else
                mask[i*25+j] = 0;
        end
    endcase  
    
    
    if(de_mask_valid)begin
        nde_array = qr_array ^ mask;
        MASK_done = 1;
    end
    else begin
        nde_array = 625'b0;
        MASK_done = 0;
    end    
end

always@(posedge clk)
    if(MASK_done)
        de_array <= nde_array;
    
endmodule