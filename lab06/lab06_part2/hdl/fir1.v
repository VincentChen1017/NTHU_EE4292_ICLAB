module fir1
  #(parameter N=32)
   (
     input      clk,
     input      rst_n,
     input      enable,
     input      [N-1:0]x,
     output reg busy,
     output reg valid,
     output reg [N-1:0]y
   );
  localparam IDLE = 0,
             EVA  = 1;

  reg [N-1:0] y_n;

  reg [5:0] state, state_n;
  reg [5:0] cnt, cnt_n;
  reg valid_n;
  reg busy_n;

  reg [N-1:0] data_a[0:14]; // x[n-1] to x[n-15]
  reg signed[N-1:0] a[0:15]; // a0, a1, a2....., a15
	reg [N-1:0] x_tmp;
  integer i,j,k;

  // coefficient assign
	always@(posedge clk)
	begin
		if(~rst_n)
			for(k=0; k<16; k=k+1)
				a[k] <= 0;
		else
		begin
		  a[0] <= -157;
		  a[1] <= 380;
		  a[2] <= -399;
		  a[3] <= -838;
		  a[4] <= 3466;
		  a[5] <= -4548;
		  a[6] <= -1987;
		  a[7] <= 36857;
		  a[8] <= 36857;
		  a[9] <= -1987;
		  a[10] <= -4548;
		  a[11] <= 3466;
		  a[12] <=  -838;
		  a[13] <= -399;
		  a[14] <= 380;
		  a[15] <= -157;
		end
	end


  always@(posedge clk)
  begin
    if(~rst_n)
    begin
      state <= IDLE;
      cnt   <= 0;
      valid <= 0;
      busy  <= 0;
      y     <= 1534;
    end
    else
    begin
      state <= state_n;
      cnt   <= cnt_n;
      valid <= valid_n;
      busy  <= busy_n;
      y     <= y_n;
    end
  end

  always@*
  begin
    case(state)
      IDLE :
        state_n = enable ? EVA : IDLE;
      EVA  :
        state_n = enable ? EVA : IDLE;
      default :
        state_n = IDLE;
    endcase
  end

  always@*
  begin
    if(state == EVA)
      if(cnt == 16)
        cnt_n = cnt;
      else
        cnt_n = cnt + 1;
    else
      cnt_n = 0;
  end

  always@*
  begin
    if((state == EVA) & (cnt == 16))
      valid_n = 1;
    else
      valid_n = 0;
  end

  always@*
  begin
    if(state == EVA)
      busy_n = 0;
    else
      busy_n = 0;
  end

  // input data propogation
  always@(posedge clk)
  begin
    if(~rst_n) begin
			x_tmp <= 0;
      for(j=0; j<15; j=j+1)
        data_a[j] <= 0;
		end
    else
    begin
			x_tmp <= x;
      data_a[0]<=x_tmp; // x[n] to x[n-1]
      for(i=0; i<14; i=i+1)
        data_a[i+1]<=data_a[i];
    end
  end

  // computation
  always@*
  begin
    	y_n = (x_tmp*a[0] + data_a[0]*a[1] + data_a[1]*a[2] + data_a[2]*a[3] + data_a[3]*a[4] +
      	  data_a[4]*a[5] + data_a[5]*a[6] + data_a[6]*a[7] +data_a[7]*a[8] +data_a[8]*a[9]+
      	  data_a[9]*a[10] + data_a[10]*a[11] + data_a[11]*a[12] +data_a[12]*a[13] +data_a[13]*a[14]+
      	  data_a[14]*a[15])>>16;
  end


endmodule
