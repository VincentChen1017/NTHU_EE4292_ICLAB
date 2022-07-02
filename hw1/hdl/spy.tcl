# read file
read_file -type verilog rop3_smart.v

# goal setup (lint_rtl)
current_goal lint/lint_rtl -alltop
# run goal
run_goal
# create a report file and write reoprt message to the file
capture rop3_smart.rpt {write_report moresimple}

# setup another goal
current_goal lint/lint_turbo_rtl -alltop
# run goal
run_goal
# append the report message to the same file created above
capture -append rop3_smart.rpt {write_report moresimple}

current_goal lint/lint_functional_rtl -alltop
run_goal
capture -append rop3_smart.rpt {write_report moresimple}

current_goal lint/lint_abstract - alltop
run_goal
capture -append rop3_smart.rpt {write_report moresimple}
