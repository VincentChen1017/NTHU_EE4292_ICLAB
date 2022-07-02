module fir1_parallel
  #(parameter N=32)
   (
     input      clk,
     input      rst_n,
     input      enable,
     input      [N-1:0]x0,
     input      [N-1:0]x1,
     output reg busy,
     output reg valid,
     output reg [N-1:0]y0,
     output reg [N-1:0]y1
   );
  localparam IDLE = 0,
             EVA  = 1;
  integer i;
  reg [N-1:0] y_2n, y_2n1, y_2n1_n;
  reg [5:0] state, nstate;
  reg [5:0] cnt, cnt_n;
  reg valid_n;
  reg busy_n;
  reg [N-1:0] data0[0:7];
  reg [N-1:0] data1[0:8];
  reg signed[N-1:0] a [0:15];
  reg cal;

  // coefficient assign
  always@(posedge clk)
  begin
    if(~rst_n)
      for(i=0; i<16; i=i+1)
        a[i] <= 0;
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

  ///// FSM /////
  always@*
  begin
    nstate = IDLE;
    cal = 0;
    case(state)
      IDLE:
      begin
        cal = 0;
        if(enable)
          nstate = EVA;
        else
          nstate = IDLE;
      end
      EVA:
      begin
        cal = 1;
        if(~enable)
          nstate = IDLE;
        else
          nstate = EVA;
      end
    endcase
  end
  ////////////////////////

  always@*
  begin
    if(state == EVA)
      if(cnt == 8)
        cnt_n = cnt;
      else
        cnt_n = cnt + 1;
    else
      cnt_n = 0;
  end

  always@*
  begin
    if((state == EVA) & (cnt == 8))
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

  /////////////////////////

  ///// data propagation /////
  always@(posedge clk)
    if(~rst_n)
      for(i=0; i<8; i=i+1)
        data0[i] <= 0;
    else
    begin
      data0[0]<=x0;
      for(i=0; i<7; i=i+1)
        data0[i+1] <= data0[i];
    end

  always@(posedge clk)
    if(~rst_n)
      for(i=0; i<9; i=i+1)
        data1[i] <= 0;
    else
    begin
      data1[0]<=x1;
      for(i=0; i<8; i=i+1)
        data1[i+1] <= data1[i];
    end
  ///////////////////////////////

  ///// CAL /////
  always@*
  begin
    y_2n = (data0[0]*a[0] + data1[1]*a[1] + data0[1]*a[2] + data1[2]*a[3] + data0[2]*a[4] +
            data1[3]*a[5] + data0[3]*a[6] + data1[4]*a[7] + data0[4]*a[8] + data1[5]*a[9] +
            data0[5]*a[10] + data1[6]*a[11] + data0[6]*a[12] + data1[7]*a[13] + data0[7]*a[14] + data1[8]*a[15])>>16;

    y_2n1 = (data1[0]*a[0] + data0[0]*a[1] + data1[1]*a[2] + data0[1]*a[3] + data1[2]*a[4] +
             data0[2]*a[5] + data1[3]*a[6] + data0[3]*a[7] + data1[4]*a[8] + data0[4]*a[9] +
             data1[5]*a[10] + data0[5]*a[11] + data1[6]*a[12] + data0[6]*a[13] + data1[7]*a[14] + data0[7]*a[15])>>16;
  end

  always@(posedge clk)
  begin
    if(~rst_n)
    begin
      state <= IDLE;
      cnt   <= 0;
      valid <= 0;
      busy  <= 0;
      y0     <= 1534;
      y1     <= 1534;
    end
    else
    begin
      state <= nstate;
      cnt   <= cnt_n;
      valid <= valid_n;
      busy  <= busy_n;
      if(cal)
      begin
        //y_2n1  <= y_2n1_n;
        y1     <= y_2n;
        y0     <= y_2n1;
      end
    end
  end

endmodule
