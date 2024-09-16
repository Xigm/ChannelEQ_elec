SHELL := /bin/bash
# Syntax of a Makefile target:
#
# target: dependency1 dependency2 ...
#	process (command to generate target from dependencies)

# If no targets are specified when calling make, it will build the first target
# in the file. The first target is usually called 'all'
all: env tb_contador.ghw contador.bin

# Phony targets are always executed, even if a file with the same name exists
# These are typically short names for other recipes
.PHONY: all prog clean

##################
### Simulation ###
##################

# Analyze vhdl sources for simulation
contador.o: contador.vhd
	ghdl -a contador.vhd

tb_contador.o: tb_contador.vhd
	ghdl -a tb_contador.vhd

# Generate simulation executable
tb_contador: tb_contador.o contador.o
	ghdl -e tb_contador

# Generate simulation waveform
tb_contador.ghw: tb_contador
	./tb_contador --wave=tb_contador.ghw

# Open gtkwave
view: tb_contador.ghw
	gtkwave tb_contador.ghw

######################
### Implementation ###
######################

# Synthesize
contador.json: contador.vhd
	yosys -m ghdl -p 'ghdl contador.vhd -e contador; synth_ice40 -json contador.json'

# Place and route
contador.asc: contador.json
	nextpnr-ice40 --up5k --package sg48 --pcf contador.pcf --json contador.json --asc contador.asc

# Bitstream generation
contador.bin: contador.asc
	icepack contador.asc contador.bin

# Configure the FPGA
prog: contador.bin
	iceprog contador.bin

###############
### Cleanup ###
###############

# Clean:
clean:
	rm -f *.o *.ghw work-obj??.cf tb_contador
	rm -f *.json *.asc *.bin

###############
### Entorno ###
###############

# Entorno:
env:
	source ~/fosshdl/env.rc
