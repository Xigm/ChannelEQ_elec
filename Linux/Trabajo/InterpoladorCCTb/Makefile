#  Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

# VHDL_SOURCES += $(PWD)/../edc_common.vhd
# VHDL_SOURCES += $(PWD)/../complexBundle.vhd
VHDL_SOURCES += $(PWD)/../interpolator.vhd
# VHDL_SOURCES += $(PWD)/../interpolatorOriginal.vhd
# VHDL_SOURCES += $(PWD)/../interpolatorPoli.vhd
# use VHDL_SOURCES for VHDL files

# VHDL_SOURCES_lib += $(PWD)/../edc_common.vhd

GHDL_ARGS ?= --std=08

SIM_ARGS +=--wave=tb_interpolador.ghw

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = interpolator

# MODULE is the basename of the Python test file
MODULE = tb_interpolator

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
