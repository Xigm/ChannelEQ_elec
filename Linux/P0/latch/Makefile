# Syntax of a Makefile target:
#
# target: dependency1 dependency2 ...
#	process (command to generate target from dependencies)

# If no targets are specified when calling make, it will build the first target
# in the file. The first target is usually called 'all'
all: leds.bin

# Phony targets are always executed, even if a file with the same name exists.
# These are typically short names for other recipes
.PHONY: all prog clean

######################
### Implementation ###
######################

# Synthesize
leds.json: leds.vhd
	yosys -m ghdl -p 'ghdl leds.vhd -e leds; select -assert-none t:$_DLATCH* t:$dlatch*t t:sr; synth_ice40 -json leds.json'

# Place and route
leds.asc: leds.json
	nextpnr-ice40 --up5k --package sg48 --pcf leds.pcf --json leds.json --asc leds.asc

# Bitstream generation
leds.bin: leds.asc
	icepack leds.asc leds.bin

# Configure the FPGA
prog: leds.bin
	iceprog leds.bin

###############
### Cleanup ###
###############

# Clean:
clean:
	rm -f *.json *.asc *.bin

