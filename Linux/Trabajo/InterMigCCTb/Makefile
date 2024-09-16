#  Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../interpolatorMig.vhd

# VHDL_SOURCES_lib += $(PWD)/../edc_common.vhd

GHDL_ARGS ?= --std=08

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = interpolatormig

# Get GTKWAVE files 
SIM_ARGS +=--wave=tb_intermig.ghw

# MODULE is the basename of the Python test file
MODULE = tb_interMig

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
