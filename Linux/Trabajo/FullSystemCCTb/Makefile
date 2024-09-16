#  Makefile

# defaults
# if regression is ised instead of sim only rebuilds needed
SIM ?= ghdl
# REGRESSION ?= ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../interpolatorMig.vhd
VHDL_SOURCES += $(PWD)/../PRBS.vhd
VHDL_SOURCES += $(PWD)/../delayer.vhd
VHDL_SOURCES += $(PWD)/../contador1_12.vhd
VHDL_SOURCES += $(PWD)/../FSM.vhd
VHDL_SOURCES += $(PWD)/../toplevel.vhd
VHDL_SOURCES += $(PWD)/../eq.vhd
VHDL_SOURCES += $(PWD)/../registro.vhd
VHDL_SOURCES += $(PWD)/../fullsystem.vhd


COVERAGE = True
# VHDL_SOURCES_lib += $(PWD)/../edc_common.vhd

GHDL_ARGS ?= --std=08

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = fullsystem

SIM_ARGS +=--wave=tb_full.ghw

# MODULE is the basename of the Python test file
MODULE = tb_full

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
