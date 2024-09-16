#  Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../interpolatorMig.vhd
VHDL_SOURCES += $(PWD)/../PRBS.vhd
VHDL_SOURCES += $(PWD)/../delayer.vhd
VHDL_SOURCES += $(PWD)/../contador1_12.vhd
VHDL_SOURCES += $(PWD)/../FSM.vhd
VHDL_SOURCES += $(PWD)/../toplevel.vhd
VHDL_SOURCES += $(PWD)/../eq.vhd
# VHDL_SOURCES += $(PWD)/../complete.vhd


# VHDL_SOURCES_lib += $(PWD)/../edc_common.vhd

GHDL_ARGS ?= --std=08

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = eq

SIM_ARGS +=--wave=tb_eq.ghw

# MODULE is the basename of the Python test file
MODULE = tb_eq

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
