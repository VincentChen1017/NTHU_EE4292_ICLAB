INCLIST = ../hdl/$(basename $@).f
NETLIST = ../syn/netlist/fir1_syn.v
GATE = /usr/cad/synopsys/SAED32_EDK/lib/stdcell_hvt/verilog/saed32nm_hvt.tv
TEST_DEFINE_FILE = $(basename $@)_test_define.v
# DEFINE_FILE = ../hdl/define.v
TESTBENCH = $(basename $@)_test.v
LIB = -v /usr/cad/synopsys/SAED32_EDK/synthesis/vG-2012.06-SP5/dw/dw02/src_ver/DW02_prod_sum1.v
OPT = +notimingcheck
%.verdi :
	cd verdi; \
	verdi -autoalias -logfile ./verdi_compiler.log \
	+incdir + $(INCDIR) $(TEST_DEFINE_FILE) \
	$(DEFINE_FILE) $(LIB) $(TESTBENCH) &
# %.vcs :
# 	make clean
# 	vcs -R -full64 + v2k $(OPT) +define + $(DEFINE_FILE) +incdir + $(INCDIR) $(TEST_DEFINE_FILE)\
# 	$(DEFINE_FILE) $(LIB) $(TESTBENCH) \
# 	-l vcs.log -debug_pp +vcs_d + vpi + memcbk -P
%.lint :
	mkdir lint; \
	nLint -2001 -beauty -rs ~ee4292/iclab.rs -F $(INCLIST) -out $(basename $@).rep;\
	mv *.rep lint
%.com :
	ncverilog -c $(DEFINE_FILE) $(TESTBENCH) -F $(INCLIST)
%.sim :
	make clean; \
	mkdir simu; \
	ncverilog $(DEFINE_FILE) $(TESTBENCH) $(LIB) -F $(INCLIST) +access+r
	mv INCA_libs simu; \
	mv *.log simu
%.posim :
	make clean; \
	mkdir simu; \
	ncverilog $(DEFINE_FILE) $(TESTBENCH) $(LIB) +vg $(GATE) $(NETLIST) +define+SDF +access+r
	mv INCA_libs simu; \
	mv *.log simu
	mv *.X simu
clean :
	rm -rf simu
