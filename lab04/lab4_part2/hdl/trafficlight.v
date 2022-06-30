module trafficlight
#(parameter RED_TIME=4'd3, GREEN_TIME=4'd2, YELLOW_TIME=4'd1)
(
  // input
  input clk,
  input rst_n,  // synchronous negative reset
  input enable,
  // output
  output reg [1:0] out_state
);
// FSM _ Moore Machine
localparam IDLE=2'd0, RED=2'd1, GREEN=2'd2, YELLOW=2'd3;
reg [1:0] next_state;
reg change_bit;

//cycle counter
reg [3:0] count;
reg [3:0] count_tmp;
wire [3:0] cycle_cmp;
always@*
  if(~change_bit)
    count_tmp = count + 1;
  else
    count_tmp = 0;
always@(posedge clk)
  if(~rst_n)
    count <= 0 ;
  else
    count <= count_tmp;
assign cycle_cmp = count + 1;

// Stage register
always@*
begin
next_state = IDLE;
change_bit = 0;
  case(out_state)
    IDLE:
      if(enable) begin
        next_state = RED;
        change_bit = 1;
      end
      else begin
        next_state = IDLE;
        change_bit = 0;
      end
        
    RED:
      if(~enable) begin
        next_state = IDLE;
        change_bit = 0;
      end
      else if(cycle_cmp==RED_TIME) begin
        next_state = GREEN;
        change_bit = 1;
      end
      else begin
        next_state = RED;
        change_bit = 0;
      end

    GREEN:
      if(~enable) begin
        next_state = IDLE;
        change_bit = 0;
      end
      else if(cycle_cmp==GREEN_TIME) begin
        next_state = YELLOW;
        change_bit = 1;
      end
      else begin
        next_state = GREEN;
        change_bit = 0;       
      end
        
    YELLOW:
      if(~enable) begin
        next_state = IDLE;
        change_bit = 0;
      end
      else if(cycle_cmp==YELLOW_TIME) begin
        next_state = RED;
        change_bit = 1;
      end
      else begin
        next_state = YELLOW;  
        change_bit = 0;     
      end  
        
  endcase
end

// Output logic
always@(posedge clk)
  if(~rst_n)
    out_state <= IDLE;
  else
    out_state <= next_state;
  


endmodule
