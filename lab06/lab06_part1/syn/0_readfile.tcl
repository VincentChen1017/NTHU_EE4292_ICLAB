set TOP_DIR $TOPLEVEL
set RPT_DIR report
set NET_DIR netlist

sh rm -rf ./$TOP_DIR
sh rm -rf ./$RPT_DIR
sh rm -rf ./$NET_DIR
sh mkdir ./$TOP_DIR
sh mkdir ./$RPT_DIR
sh mkdir ./$NET_DIR

# define a lib path here
define_design_lib $TOPLEVEL -path ./$TOPLEVEL
 
# Read Design File (add your files here)
# put all your HDL here
set HDL_DIR "../source"
analyze -library $TOPLEVEL -format verilog "/home/u107/u107061272/ICLAB/lab06/lab06_part1/source/alu.v" 
analyze -library $TOPLEVEL -format verilog "/home/u107/u107061272/ICLAB/lab06/lab06_part1/source/controller.v" 
analyze -library $TOPLEVEL -format verilog "/home/u107/u107061272/ICLAB/lab06/lab06_part1/source/CPU_define.v" 
analyze -library $TOPLEVEL -format verilog "/home/u107/u107061272/ICLAB/lab06/lab06_part1/source/dsram.v" 
analyze -library $TOPLEVEL -format verilog "/home/u107/u107061272/ICLAB/lab06/lab06_part1/source/EXE_stage.v" 
analyze -library $TOPLEVEL -format verilog "/home/u107/u107061272/ICLAB/lab06/lab06_part1/source/ID_EXE.v" 
analyze -library $TOPLEVEL -format verilog "/home/u107/u107061272/ICLAB/lab06/lab06_part1/source/ID_stage.v" 
analyze -library $TOPLEVEL -format verilog "/home/u107/u107061272/ICLAB/lab06/lab06_part1/source/IF_ID.v" 
analyze -library $TOPLEVEL -format verilog "/home/u107/u107061272/ICLAB/lab06/lab06_part1/source/IF_stage.v" 
analyze -library $TOPLEVEL -format verilog "/home/u107/u107061272/ICLAB/lab06/lab06_part1/source/PC.v" 
analyze -library $TOPLEVEL -format verilog "/home/u107/u107061272/ICLAB/lab06/lab06_part1/source/regfile.v" 
analyze -library $TOPLEVEL -format verilog "/home/u107/u107061272/ICLAB/lab06/lab06_part1/source/top.v" 
analyze -library $TOPLEVEL -format verilog "/home/u107/u107061272/ICLAB/lab06/lab06_part1/source/top_pipe.v" 


# elaborate your design
elaborate $TOPLEVEL -architecture verilog -library $TOPLEVEL

# Solve Multiple Instance
set uniquify_naming_style "%s_mydesign_%d"
uniquify

# link the design
# 指定要處理的 design 下一步要設定整個電路的 constrain,所以要在 top 做
current_design $TOPLEVEL
# 連結 design 跟 library
link
