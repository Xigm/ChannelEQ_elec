SHELL := /bin/bash
# Syntax of a Makefile target:
#
# target: dependency1 dependency2 ...
#	process (command to generate target from dependencies)

# If no targets are specified when calling make, it will build the first target
# in the file. The first target is usually called 'all'
all: env tb_contadorbyme.ghw contadorbyme.bin

# Phony targets are always executed, even if a file with the same name exists
# These are typically short names for other recipes
.PHONY: all prog clean

##################
### Simulation ###
##################

# Analyze vhdl sources for simulation
contadorbyme.o: contadorbyme.vhd
	ghdl -a contadorbyme.vhd

tb_contadorbyme.o: tb_contadorbyme.vhd
	ghdl -a tb_contadorbyme.vhd

# Generate simulation executable
tb_contadorbyme: tb_contadorbyme.o contadorbyme.o
	ghdl -e tb_contadorbyme

# Generate simulation waveform
tb_contadorbyme.ghw: tb_contadorbyme
	./tb_contadorbyme --wave=tb_contadorbyme.ghw

# Open gtkwave
view: tb_contadorbyme.ghw
	gtkwave tb_contadorbyme.ghw

######################
### Implementation ###
######################

# Synthesize
contadorbyme.json: contadorbyme.vhd
	yosys -m ghdl -p 'ghdl contadorbyme.vhd -e contadorbyme; synth_ice40 -json contadorbyme.json'

# Place and route
contadorbyme.asc: contadorbyme.json
	nextpnr-ice40 --up5k --package sg48 --pcf contadorbyme.pcf --json contadorbyme.json --asc contadorbyme.asc

# Bitstream generation
contadorbyme.bin: contadorbyme.asc
	icepack contadorbyme.asc contadorbyme.bin

# Configure the FPGA
prog: contadorbyme.bin
	iceprog contadorbyme.bin

###############
### Cleanup ###
###############

# Clean:
clean:
	rm -f *.o *.ghw work-obj??.cf tb_contadorbyme
	rm -f *.json *.asc *.bin

###############
### Entorno ###
###############

# Entorno:
env:
	source ~/fosshdl/env.rc
