# Syntax of a Makefile target:
#
# target: dependency1 dependency2 ...
#	process (command to generate target from dependencies)

# If no targets are specified to make, it will build the first target in the
# file. By convention, the first target is typically called 'all'
all: sim top.bin

# If no targets are specified when calling make, it will build the first target
# in the file. The first target is usually called 'all'
.PHONY: all prog clean

##################
### Simulation ###
##################

# Typing 'make sim' is easier than typing 'make tb_vgadriver.ghw'
sim: tb_vgadriver.ghw

# Analyze vhdl sources
#
# This is a generic rule
#
# %, $@, $^, $< are explained in: https://web.mit.edu/gnu/doc/html/make_10.html#SEC94
# %.o is a pattern, corresponds to a file that we want to generate, for example
#     top.o matches with %.o
# $< is the first dependency
# $@ is the target
# $^ is the dependency list (all dependenciaes)
%.o: %.vhd
	ghdl -a $<

# Generate simulation executable
tb_vgadriver: contador.o comparador.o dibuja.o vgadriver.o tb_vgadriver.o
	ghdl -e tb_vgadriver

# Generate simulation waveform
tb_vgadriver.ghw: tb_vgadriver
	./tb_vgadriver --wave=tb_vgadriver.ghw

# Open gtkwave
view: tb_vgadriver.ghw
	gtkwave tb_vgadriver.ghw

######################
### Implementation ###
######################

# Synthesize
top.json: top.vhd contador.vhd comparador.vhd dibuja.vhd vgadriver.vhd
	yosys -m ghdl -p 'ghdl contador.vhd comparador.vhd dibuja.vhd vgadriver.vhd top.vhd -e top; synth_ice40 -json top.json'

# Place and route
top.asc: top.json top.pcf
	nextpnr-ice40 --up5k --package sg48 --freq 25 --pcf top.pcf --json top.json --asc top.asc

# Bitstream generation
top.bin: top.asc
	icepack top.asc top.bin

# An example of how we can make a rule generic:
#
#%.bin: %.asc
#	icepack $< $@

# Configure the FPGA
prog: top.bin
	iceprog top.bin

###############
### Cleanup ###
###############

# Clean:
clean:
	rm -f *.o *.ghw work-obj??.cf tb_vgadriver
	rm -f *.json *.asc *.bin

