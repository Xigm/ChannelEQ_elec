#  Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../interpolator.vhd
VHDL_SOURCES += $(PWD)/../PRBS.vhd
VHDL_SOURCES += $(PWD)/../delayer.vhd
VHDL_SOURCES += $(PWD)/../interpolatorMig.vhd
VHDL_SOURCES += $(PWD)/../contador1_12.vhd
VHDL_SOURCES += $(PWD)/../contadorCtrlRAM.vhd
VHDL_SOURCES += $(PWD)/../FSM.vhd
VHDL_SOURCES += $(PWD)/../channelEstimator.vhd

# use VHDL_SOURCES for VHDL files

# VHDL_SOURCES_lib += $(PWD)/../edc_common.vhd

GHDL_ARGS ?= --std=08

SIM_ARGS +=--wave=tb_channelestimator.ghw

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = channelestimator

# MODULE is the basename of the Python test file
MODULE = tb_estimador

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

