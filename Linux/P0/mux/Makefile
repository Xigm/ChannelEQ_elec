# Syntax of a Makefile target:
#
# target: dependency1 dependency2 ...
#	process (command to generate target from dependencies)

# If no targets are specified when calling make, it will build the first target
# in the file. The first target is usually calmux 'all'
all: tb_mux.ghw mux.bin

# Phony targets are always executed, even if a file with the same name exists
# These are typically short names for other recipes
.PHONY: all prog clean

##################
### Simulation ###
##################

# Analyze vhdl sources for simulation
mux.o: mux.vhd
	ghdl -a mux.vhd

tb_mux.o: tb_mux.vhd
	ghdl -a tb_mux.vhd

# Generate simulation executable
tb_mux: tb_mux.o mux.o
	ghdl -e tb_mux

# Generate simulation waveform
tb_mux.ghw: tb_mux
	./tb_mux --wave=tb_mux.ghw

# Open gtkwave
view: tb_mux.ghw
	gtkwave tb_mux.ghw

######################
### Implementation ###
######################

# Synthesize
mux.json: mux.vhd
	yosys -m ghdl -p 'ghdl mux.vhd -e mux; synth_ice40 -json mux.json'

# Place and route
mux.asc: mux.json
	nextpnr-ice40 --up5k --package sg48 --pcf mux.pcf --json mux.json --asc mux.asc

# Bitstream generation
mux.bin: mux.asc
	icepack mux.asc mux.bin

# Configure the FPGA
prog: mux.bin
	iceprog mux.bin

###############
### Cleanup ###
###############

# Clean:
clean:
	rm -f *.o *.ghw work-obj??.cf tb_mux
	rm -f *.json *.asc *.bin

