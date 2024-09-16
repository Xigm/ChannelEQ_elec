from vunit import VUnit

# Create VUnit instance by parsing command-line arguments
vu = VUnit.from_argv()

# Create library 'src_lib', where our files will be compiled
lib = vu.add_library("src_lib")

# Add all files ending in .vhd in current working directory to our library 'src_lib'
lib.add_source_files("*.vhd")

# Run vunit function
vu.main()