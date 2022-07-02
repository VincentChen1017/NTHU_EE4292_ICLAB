# Setting Design and I/O Environment
# 設定操作環境 SS corner 0.95V 125C
set_operating_conditions -library saed32hvt_ss0p95v125c ss0p95v125c

# Setting wireload model
# 設定線的 wire load model
set auto_wire_load_selection area_reselect
# 用 enclosed 的方式來決定 sub blocks 間的 wire
set_wire_load_mode enclosed
# 以面積做為選擇 group 的判斷
set_wire_load_selection_group predcaps

# Setting Timing Constraints
# 創建名為 clk 的 clock,週期是 $TEST_CYCLE 並連接到所有 clk 的 ports 上
create_clock -name clk -period $TEST_CYCLE [get_ports clk]
# ideal_network 忽略訊號 driving 能力問題
set_ideal_network
[get_ports clk]
# 在這條路徑上不因時間考量而加入 buffer
set_dont_touch_network [all_clocks]

# I/O delay should depend on the real enironment. Here only shows an example of setting
# 設定 I/O 兩端所連接電路的 delay
# I/O delay should depend on the real environment
# 針對除了 clk 外的所有 primary I/O
set_input_delay [expr $TEST_CYCLE/2.0] -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay [expr $TEST_CYCLE/2.0] -clock clk [all_outputs]

# Setting DRC Constraint
# Defensive setting: smallest fanout_load 0.041 and WLM max fanout # 20 =>
0.041*20 = 0.82
# 依據一些假設設定最大 fanout load (WLM 最多有 20 個 fanout)
# max_transition and max_capacitance are given in the cell library
set_max_fanout 0.82 $TOPLEVEL
# Area Constraint
# 面積盡量小
set_max_area 0
