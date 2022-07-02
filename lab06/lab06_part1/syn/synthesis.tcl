# 重要的參數在外面設定,讓腳本可以盡量重複使用
set TOPLEVEL "top_pipe"
set TEST_CYCLE 3.2
# 把全部的腳本依照功能分階段管理
source -echo -verbose 0_readfile.tcl
# 我們會在後面依序完成
source -echo -verbose 1_setting.tcl 
source -echo -verbose 2_compile.tcl
source -echo -verbose 3_report.tcl
exit
