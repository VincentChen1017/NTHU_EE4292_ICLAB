module fir1
  #(parameter N=32)
   (
     input      clk,
     input      rst_n,
     input      enable,
     input      [N-1:0]x,
     output reg busy, // represent doing calculate
     output reg valid,
     output reg [N-1:0]y
   );
  localparam IDLE = 0,
             LOAD = 1,
             CAL = 2;

  integer i,j,k;
  reg [N-1:0] previous_sum;
  reg [N-1:0]current_data;
  reg signed[N-1:0]a[0:15];
  reg [4:0]cnt_load, cnt_load_n;
  reg [3:0]cnt_cal, cnt_cal_n;
  reg [2:0] state, nstate;
  reg valid_n;
  reg [N-1:0] data[0:15];
  reg signed[N-1:0]p_sum;
  reg signed[N-1:0]c_sum;

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
    busy = 0;
    valid_n = 0;
    case(state)
      IDLE:
      begin
        busy = 0;
        valid_n = 0;
        if(enable)
          nstate = LOAD;
        else
          nstate = IDLE;
      end
      LOAD:
      begin
        busy = 0;
        valid_n = 0;
        if(cnt_load==16)
          nstate = CAL;
        else
          nstate = LOAD;
      end
      CAL:
      begin
        busy = 1;
        valid_n = 0;
        if(cnt_cal==15)
        begin
          nstate = LOAD;
          valid_n = 1;
        end
        else
          nstate = CAL;
      end
    endcase
  end

  always@(posedge clk)
  begin
    if(~rst_n)
      state <= IDLE;
    else
      state <= nstate;
  end
  ////////////////////

  ///// cnt_load /////
  always@*
    if(enable && cnt_load!=16)
      cnt_load_n = cnt_load + 1;
    else
      cnt_load_n = cnt_load;
  always@(posedge clk)
    if(~rst_n)
      cnt_load <= 0;
    else
      cnt_load <= cnt_load_n;
  ////////////////////////////

  ///// cnt_cal /////
  always@*
    if(busy)
      cnt_cal_n = cnt_cal + 1;
    else
      cnt_cal_n = 0;
  always@(posedge clk)
    if(~rst_n)
      cnt_cal <= 0;
    else
      cnt_cal <= cnt_cal_n;
  ////////////////////////

  ///// input data /////
  always@(posedge clk)
    if(~rst_n)
      for(i=0; i<16; i=i+1)
        data[i] <= 0;
    else if(state==LOAD)
    begin
      data[0] <= x;
      for(j=0; j<15; j=j+1)
        data[j+1] <= data[j];
    end
    else
      for(k=0; k<16; k=k+1)
        data[k] <= data[k];
  /////////////////////////

  ///// calculation /////
  always@*
    if(busy)
    begin
      c_sum = a[cnt_cal]*data[cnt_cal] + p_sum;
    end
    else
    begin
      c_sum = 0;
    end

  always@(posedge clk)
    if(~rst_n)
      p_sum <= 0;
    else if(busy)
      p_sum <= c_sum;
    else
      p_sum <= 0;

  always@(posedge clk)
    if(~rst_n)
    begin
      valid <= 0;
      y <= 0;
    end
    else
    begin
      valid <= valid_n;
      y <= (c_sum)>>16;
    end
  //////////////////////




endmodule
