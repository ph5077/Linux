***** VAR *****
SOURCES_SV := \
    ../SRC/adder.sv \
    ../SRC/subtractor.sv \
    ../SRC/tb.sv \

COMP_OPTS_SV := \
    --incr \
    --relax \

DEFINES_SV := -d SUBTRACTOR_VHDL
SOURCES_VHDL := ../SRC/subtractor.vhdl
COMP_OPTS_VHDL := --incr --relax

***** TARGET *****
target_name : dependency_1 dependency_2 dependency_3
    bash_command_that_generates_the_target <parameters>
    
first_target : some_dependency
<-TAB-> some_bash_command
<-TAB-> another_bash_command

another_target : first_target some_other_dependency
<-TAB-> yet_another_bash_command

***** EX WAVE *****
TB_TOP := adder_tb
.PHONY: waves
waves : $(TB_TOP)_snapshot.wdb
    @echo "### OPENING WAVES ###"
    xsim --gui $(TB_TOP)_snapshot.wdb
    
## Declaring a target as phony tells make that
## this target name does not correspond to a generated file name
## “@” character before echo prevents printout of the actual echo command.
## If you don’t prepend “@” before a recipe command, make will show the command 
## that it’s executing as well as the command’s output. 
## If you do prepend “@”, it will only show the output.

***** EX SIM *****
$(TB_TOP)_snapshot.wdb : .elab.timestamp
	@echo
	@echo "### RUNNING SIMULATION ###"
	xsim $(TB_TOP)_snapshot --tclbatch xsim_cfg.tc

***** EX ELABORATION *****
.elab.timestamp : .comp_sv.timestamp .comp_v.timestamp .comp_vhdl.timestamp
    @echo
    @echo "### ELABORATING ###"
    xelab -debug all -top $(TB_TOP) -snapshot $(TB_TOP)_snapshot
    touch .elab.timestamp
    
***** EX COMPILATION *****
## SystemVerilog
.comp_sv.timestamp : $(SOURCES_SV)
	xvlog --sv $(COMP_OPTS_SV) $(DEFINES_SV) $(SOURCES_SV)
	touch .comp_sv.timestamp

## Verilog
.comp_v.timestamp : $(SOURCES_V)
	xvlog $(COMP_OPTS_V) $(DEFINES_V) $(SOURCES_V)
	touch .comp_v.timestamp

## VHDL
.comp_vhdl.timestamp : $(SOURCES_VHDL)
	xvhdl $(COMP_OPTS_VHDL) $(SOURCES_VHDL)
	touch .comp_vhdl.timestamp
  
***** CHECK IF SOURCE FILE EMPTY *****
ifeq ($(SOURCES_SV),)
.comp_sv.timestamp :
    @echo
    @echo "### NO SYSTEMVERILOG SOURCES GIVEN ###"
    @echo "### SKIPPED SYSTEMVERILOG COMPILATION ###"
    touch .comp_sv.timestamp
else
.comp_sv.timestamp : $(SOURCES_SV)
    @echo
    @echo "### COMPILING SYSTEMVERILOG ###"
    xvlog --sv $(COMP_OPTS_SV) $(DEFINES_SV) $(SOURCES_SV)
    touch .comp_sv.timestamp
endif

***** CLEAN UP *****
.PHONY : clean
clean :
    rm -rf *.jou *.log *.pb *.wdb xsim.dir      # This deletes all files generated by Vivado
    rm -rf .*.timestamp                         # This deletes all our timestamps
    
***** COMPILE *****
PHONY : compile
compile : .comp_sv.timestamp .comp_v.timestamp .comp_vhdl.timestamp

.PHONY : elaborate
elaborate : .elab.timestamp

.PHONY : simulate
simulate : $(TB_TOP)_snapshot.wdb
