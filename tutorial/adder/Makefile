H3_CYGWIN_MODELSIM_PATH = $(shell cygpath -u "$$H3_MODELSIM_PATH")

VERILATOR = verilator
VIVADO=$(HOME)/opt/cad/xilinx/Vivado/2019.2/bin

VLOG = $(H3_CYGWIN_MODELSIM_PATH)/vlog.exe
VLIB = $(H3_CYGWIN_MODELSIM_PATH)/vlib.exe
VSIM = $(H3_CYGWIN_MODELSIM_PATH)/vsim.exe -c
MODELSIM = $(H3_CYGWIN_MODELSIM_PATH)/modelsim.exe

PROJECT_WORK = VivadoSim
LIBRARY_WORK = $(PROJECT_WORK)/$(LIBRARY_NAME)
TEST_BENCH_MODULE = AdderSim

# Simulation tools
XVLOG = $(VIVADO)/xvlog
XELAB = $(VIVADO)/xelab
XSIM  = $(VIVADO)/xsim

# Library name and top-level module to be simulated
LIBRARY_NAME    = AdderSim
TOPLEVEL_MODULE = AdderSim 

TOP = AdderSim.sv
SOURCE_ROOT = /work/cpu-exercise/tutorial/adder/

# Specify source files
SOURCES = \
	Types.sv \
	Adder.sv \
	AdderSim.sv \

DEPS_RTL = \
	$(SOURCES:%=$(SOURCE_ROOT)%)

OPTIONS = \
	--binary \
	-sv \
	--top-module $(TOPLEVEL_MODULE) \
	-j 0 \
	-Wall \
	--trace \
	+define+VERILATOR_SIMULATION \
	-Wno-IMPORTSTAR \

all: obj_dir/VAdderSim

obj_dir/VAdderSim: $(SOURCES)
	$(VERILATOR) $(OPTIONS) $(SOURCES)

run: obj_dir/VAdderSim
	obj_dir/VAdderSim

# vlib LIBRARY
clean:
	rm -rf obj_dir $(PROJECT_WORK) wave.vcd

lib: clean

$(LIBRARY_WORK): Makefile
	make clean

# XSIM_OPTIONS = -debug all

# Vivado sim may require the following additonal components:
# sudo apt install libncurses5 libtinfo5
vivado-compile: $(SOURCES)
	mkdir $(PROJECT_WORK) -p
	# compile
	cd $(PROJECT_WORK) && $(XVLOG) -sv $(XVLOG_OPTIONS) -i $(SOURCE_ROOT) $(DEPS_RTL) 
	# elaboration
	cd $(PROJECT_WORK) && $(XELAB) --debug all -relax $(TEST_BENCH_MODULE)

vivado-sim: vivado-compile
	cd $(PROJECT_WORK) && $(XSIM) -runall $(XSIM_OPTIONS) $(TEST_BENCH_MODULE)

vivado-sim-gui: vivado-compile
	cd $(PROJECT_WORK) && $(XSIM) -gui $(XSIM_OPTIONS) $(TEST_BENCH_MODULE)
