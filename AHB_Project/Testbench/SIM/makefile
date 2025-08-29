#makefile

################################################################################
 
INCL      = +incdir+../TOP/  +incdir+../config/ +incdir+../ENV/ +incdir+../AHB_Master/ +incdir+../AHB_Slave/ +incdir+../TEST/
 
################################################################################
 
################################################################################
 
BASE_PKG      = ../include/ahb_pkg.sv ../TOP/ahb_top.sv
 
TESTNAME = ahb_random_burst_transfer_test 
################################################################################
UVM = -debug_pp +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv ${UVM_HOME}/src/dpi/uvm_dpi.cc -CFLAGS -DVCS 
#Synopsis VCS OPTIONS 
VCS_RUN_OPTS  = -l $(TESTNAME)/$(TESTNAME)_$(SEED).log
VCS_COMP_OPTS = -lca -sverilog -l compile.log -debug_access+all $(UVM) $(INCL) $(BASE_PKG) -kdb +define+WAVES_FSDB +define+WAVES="fsdb" -cm line+cond+fsm+tgl+branch


RUN_CMD = ./simv $(VCS_RUN_OPTS)
COMPILE_CMD = vcs $(VCS_COMP_OPTS)

SEED      = 1
#Default Verbosity is set to UMV_LOW
VERBOSITY = UVM_LOW
 
#Default TIMEOUT
TIMEOUT		= 500000
UVM_CLI_SWITCH = +ntb_random_seed=$(SEED) +UVM_TESTNAME=$(TESTNAME) +testname=$(TESTNAME)/$(TESTNAME)_$(SEED) +UVM_TIMEOUT=$(TIMEOUT) +clk_freq=250 +init_rst

#Compilation Command 
comp: 
	$(COMPILE_CMD) \
		-debug_all ../TOP/ahb_top.sv
     		
 
#Run Command 
run: comp
	@echo "Compiling.................."
	  $(RUN_CMD) \
	     $(UVM_CLI_SWITCH)

#Regression Command
ITERATIONS = 1 # Default Iteration 
DIFF_SEED = $(shell (shuf -i 1-10000 -n $(ITERATIONS)))

tests := ahb_in_bw_rst_test ahb_sanity_test ahb_single_burst_test ahb_incr_burst_test ahb_wrap4_burst_test ahb_incr4_burst_test ahb_wrap8_burst_test ahb_incr8_burst_test ahb_wrap16_burst_test ahb_incr16_burst_test ahb_narrow_transfer_test

regress: comp
	@mkdir -p $(tests)
	@for testname in $(tests); do \
		for seed in $(DIFF_SEED); do \
			echo "Running test: $$testname with seed $$seed"; \
			./simv -assert -l $${testname}/$${testname}_$${seed}.log \
				+ntb_random_seed=$$seed +UVM_TESTNAME=$$testname -cm_name $$testname +clk_freq=250 +init_rst \
				+test_name=$${testname}/$${testname}_$${seed} \
				+UVM_VERBOSITY=$(VERBOSITY) +UVM_TIMEOUT=$(TIMEOUT); \
		done; \
	done
