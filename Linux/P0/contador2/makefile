SHELL := /bin/bash
# Syntax of a Makefile target:
#
# target: dependency1 dependency2 ...
#	process (command to generate target from dependencies)

# If no targets are specified when calling make, it will build the first target
# in the file. The first target is usually called 'all'
all: env tb_contadorLeds.ghw contadorLeds.bin

# Phony targets are always executed, even if a file with the same name exists
# These are typically short names for other recipes
.PHONY: all prog clean

##################
### Simulation ###
##################

# Analyze vhdl sources for simulation
contadorLeds.o: contadorLeds.vhd
	ghdl -a contadorLeds.vhd

contadorbyme.o: contadorbyme.vhd
	ghdl -a contadorbyme.vhd

tb_contadorLeds.o: tb_contadorLeds.vhd
	ghdl -a tb_contadorLeds.vhd

# Generate simulation executable
tb_contadorLeds: tb_contadorLeds.o contadorbyme.o contadorLeds.o 
	ghdl -e tb_contadorLeds

# Generate simulation waveform
tb_contadorLeds.ghw: tb_contadorLeds
	./tb_contadorleds --wave=tb_contadorLeds.ghw

# Open gtkwave
view: tb_contadorLeds.ghw
	gtkwave tb_contadorLeds.ghw

######################
### Implementation ###
######################

# Synthesize
contadorLeds.json: contadorLeds.vhd
	yosys -m ghdl -p 'ghdl contadorLeds.vhd -e contadorLeds; synth_ice40 -json contadorLeds.json'

# Place and route
contadorLeds.asc: contadorLeds.json
	nextpnr-ice40 --up5k --package sg48 --pcf contadorLeds.pcf --json contadorLeds.json --asc contadorLeds.asc

# Bitstream generation
contadorLeds.bin: contadorLeds.asc
	icepack contadorLeds.asc contadorLeds.bin

# Configure the FPGA
prog: contadorLeds.bin
	iceprog contadorLeds.bin

###############
### Cleanup ###
###############

# Clean:
clean:
	rm -f *.o *.ghw work-obj??.cf tb_contadorLeds
	rm -f *.json *.asc *.bin *.gwh

###############
### Entorno ###
###############

# Entorno:
env:
	source ~/fosshdl/env.rc
