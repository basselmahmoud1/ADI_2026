SIM = icarus
TOPLEVEL_LANG = verilog

VERILOG_SOURCES = $(PWD)/ALU_pkg.sv $(PWD)/ALU.sv $(PWD)/dump.v

TOPLEVEL = ALU
COCOTB_TEST_MODULES = test

# This tells Icarus to also elaborate the dump module alongside ALU
COMPILE_ARGS = -s dump

include $(shell cocotb-config --makefiles)/Makefile.sim