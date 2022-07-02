module unshuffle #(
parameter CH_NUM = 4,
parameter ACT_PER_ADDR = 4,
parameter BW_PER_ACT = 12
)
(
input clk,                          
input rst_n,  // synchronous reset (active low)
input enable, // start sending image from testbanch
output reg busy,  // control signal for stopping loading input image
output reg valid, // output valid for testbench to check answers in corresponding SRAM groups
input [BW_PER_ACT-1:0] input_data, // input image data
     
// write enable for SRAM group A 
output reg sram_wen_a0,
output reg sram_wen_a1,
output reg sram_wen_a2,
output reg sram_wen_a3,
// wordmask for SRAM group A 
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a,
// write addrress to SRAM group A 
output reg [5:0] sram_waddr_a,
// write data to SRAM group A 
output reg signed [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a
);

localparam IDLE = 0,
					 UNSFL = 1,
					 DONE = 2;

integer i;
reg UNSFL_done;
reg [1:0] state, nstate;
reg [BW_PER_ACT-1:0] ninput_data;
reg nenable;


// ====== FSM ===== //
always@* begin
	case(state)
		IDLE: begin
			busy = 1;
			valid = 0;
			if(nenable)
				nstate = UNSFL;
			else
				nstate = IDLE;
		end
		
		UNSFL: begin
			busy = 0;
			valid = 0;
			if(UNSFL_done)
				nstate = DONE;
			else
				nstate = UNSFL;
		end

		DONE: begin
			busy = 1;
			valid = 1;
			nstate = DONE;
		end

		default: begin
			busy = 1;
			valid = 0;
			nstate = IDLE;
		end

	endcase
end

always@(posedge clk)
	if(~rst_n)
		state <= IDLE;
	else
		state <= nstate;

// ===== input signal DFF ===== //
always@(posedge clk) begin
	ninput_data <= input_data;
	nenable <= enable;
end


// load_map position //
reg [27:0] height, nheight, width, nwidth;
reg load_enable;
always@(posedge clk)
	if(~rst_n)
		load_enable <= 0;
	else if(~busy) 
		load_enable <= 1; // because of the input dff delay, addr_cnt must be delay one cycle to start to count. 
	else
		load_enable <= 0;

always@(posedge clk)
	if(~rst_n) begin
		height <= 0;
		width <= 0;
	end
	else begin
		height <= nheight;
		width <= nwidth;
	end

always@* begin
	if(~busy && load_enable) begin
		if(width==27) begin
			nheight = height + 1;
			nwidth = 0;
		end
		else begin
			nheight = height;
			nwidth = width + 1;
		end
	end
	else begin
		nheight = 0;
		nwidth = 0;
	end

	if(height==27 && width==27)
		UNSFL_done = 1;
	else
		UNSFL_done = 0;	

end

// ===== word_mask ===== //
reg [1:0] height_mod, width_mod;  // To locate the ch position
always@* begin
	height_mod = height[1:0];  // height_mod = height % 4
	width_mod = width[1:0]; // width_mod = width % 4
	sram_wordmask_a = 16'b1111111111111111;
	sram_wdata_a = 0;
	case(height_mod)
		0: begin
			case(width_mod)
				0: begin
					sram_wordmask_a[15] = 0;
					sram_wdata_a[191:180] =  ninput_data;
				end
				1: begin
					sram_wordmask_a[11] = 0;
					sram_wdata_a[143:132] =  ninput_data;
				end
				2: begin
					sram_wordmask_a[14] = 0;
					sram_wdata_a[179:168] =  ninput_data;
				end
				3: begin 
					sram_wordmask_a[10] = 0;		
					sram_wdata_a[131:120] =  ninput_data;
				end
			endcase
		end

		1: begin
			case(width_mod)
				0: begin
					sram_wordmask_a[7] = 0;
					sram_wdata_a[95:84] =  ninput_data;
				end
				1: begin
					sram_wordmask_a[3] = 0;
					sram_wdata_a[47:36] =  ninput_data;
				end
				2: begin
					sram_wordmask_a[6] = 0;
					sram_wdata_a[83:72] =  ninput_data;
				end
				3: begin
					sram_wordmask_a[2] = 0;	
					sram_wdata_a[35:24] =  ninput_data;
				end
			endcase	
		end

		2: begin
			case(width_mod)
				0: begin
					sram_wordmask_a[13] = 0;
					sram_wdata_a[167:156] =  ninput_data;
				end			
				1: begin
					sram_wordmask_a[9] = 0;
					sram_wdata_a[119:108] =  ninput_data;
				end
				2: begin
					sram_wordmask_a[12] = 0;
					sram_wdata_a[155:144] =  ninput_data;
				end
				3: begin
					sram_wordmask_a[8] = 0;	
					sram_wdata_a[107:96] =  ninput_data;
				end							
			endcase	
		end

		3: begin
			case(width_mod)
				0: begin
					sram_wordmask_a[5] = 0;
					sram_wdata_a[71:60] =  ninput_data;
				end
				1: begin
					sram_wordmask_a[1] = 0;
					sram_wdata_a[23:12] =  ninput_data;
				end				
				2: begin
					sram_wordmask_a[4] = 0;
					sram_wdata_a[59:48] =  ninput_data;
				end
				3: begin 
					sram_wordmask_a[0] = 0;	
					sram_wdata_a[11:0] =  ninput_data;
				end			
			endcase
		end
	endcase
end

// ===== SRAM addr ===== //
reg [5:0] nsram_waddr_a;
always@(posedge clk)
	if(~rst_n)
		sram_waddr_a <= 0;
	else
		sram_waddr_a <= nsram_waddr_a;

always@* begin
	if(~busy && load_enable)
		if((width+1)%8==0)
			nsram_waddr_a = sram_waddr_a + 1;
		else if(width==27)
			if((height+1)%8==0)
				nsram_waddr_a = sram_waddr_a + 3;
			else
				nsram_waddr_a = sram_waddr_a - 3;
		else
			nsram_waddr_a = sram_waddr_a;
	else
		nsram_waddr_a = 0;
end

// ===== SRAM en ===== //
reg [2:0] height_mod2, width_mod2; // To decide which the bank the input should store into.
always@* begin
	height_mod2 = height[2:0]; // height_mod2 = height % 8
	width_mod2 = width[2:0]; // width_mod2 = width % 8
	{sram_wen_a0, sram_wen_a1, sram_wen_a2, sram_wen_a3} = 4'b1111;
	if(height_mod2<4)
		if(width_mod2<4)
			sram_wen_a0 = 0;
		else
			sram_wen_a1 = 0;
	else
		if(width_mod2<4)
			sram_wen_a2 = 0;
		else
			sram_wen_a3 = 0;
end
	
endmodule



