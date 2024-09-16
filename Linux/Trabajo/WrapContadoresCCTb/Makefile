#  Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../generics.vhd
VHDL_SOURCES += $(PWD)/../contador8bits.vhd
VHDL_SOURCES += $(PWD)/../contador.vhd
VHDL_SOURCES += $(PWD)/../contador1_12.vhd
VHDL_SOURCES += $(PWD)/../contadorCtrlRAM.vhd
VHDL_SOURCES += $(PWD)/../contadorCtrlRAMnonGeneric.vhd

# VHDL_SOURCES_lib += $(PWD)/../edc_common.vhd

GHDL_ARGS ?= --std=08

SIM_ARGS +=--wave=tb_controladorCtrlRAM.ghw

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = contadorctrlram

# MODULE is the basename of the Python test file
MODULE = tb_controladorCtrlRAM

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
