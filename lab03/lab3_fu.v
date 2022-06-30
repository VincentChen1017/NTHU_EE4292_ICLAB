module lab3_fu
#(
  parameter  DATA_WIDTH = 16,
  parameter  INS_WIDTH = 5
)
(
  input clk,
  input rst_n,
  input signed [DATA_WIDTH-1:0] A,
  input signed [DATA_WIDTH-1:0] B,
  input [INS_WIDTH-1:0] instruction,
  output reg signed [DATA_WIDTH-1:0] F_o
);

reg signed [DATA_WIDTH-1:0] F;
reg signed [DATA_WIDTH-1:0] B_ro_r;
reg signed [DATA_WIDTH-1:0] B_ro_l;

// rotate operation
always@(*) begin
	B_ro_r = {B[0],B[15],B[14],B[13],B[12],B[11],B[10],B[9],B[8],B[7],B[6],B[5],B[4],B[3],B[2],B[1]};
	B_ro_l = {B[14],B[13],B[12],B[11],B[10],B[9],B[8],B[7],B[6],B[5],B[4],B[3],B[2],B[1],B[0],B[15]};
end


always@(*) begin // instruction table
  case(instruction)
    5'b00000 : begin F = A; end
    5'b00001 : begin F = A+1;  end
    5'b00010 : begin F = A+(~B); end
    5'b00011 : begin F = A+(~B)+1;  end
    5'b00100 : begin F = A+B;    end 
    5'b00101 : begin F = A+B+1;  end
    5'b00110 : begin F = B;      end 
    5'b00111 : begin F = A-1;    end
    5'b01000 : begin F = A&B;    end
    5'b01001 : begin F = A|B;    end
    5'b01010 : begin F = A^B;    end
    5'b01011 : begin F = ~A;     end
    5'b10000 : begin F = B>>1;   end
    5'b10001 : begin F = B<<1;   end
		5'b10010 : begin F = B_ro_r;	end
		5'b10011 : begin F = B_ro_l;	end
    default  : begin F = 0;      end
  endcase
end

always@(posedge clk) begin
  if(~rst_n) begin
    F_o <= 0;
  end
  else begin
    F_o <= F;
  end
end

endmodule
