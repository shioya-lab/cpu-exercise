
# Top-level module to be simulated
TOPLEVEL_MODULE = SubSim 

# Specify source files
SOURCES = \
	Types.sv \
	Sub.sv \
	SubSim.sv \

SOURCE_ROOT = $(CPU_EXERCISE_ROOT)/tutorial/adder/
DEPS_RTL = \
	$(SOURCES:%=$(SOURCE_ROOT)%)

VERILATOR_OPTIONS = \
	--binary \
	-sv \
	--top-module $(TOPLEVEL_MODULE) \
	-j 0 \
	--trace \
	--trace-structs \
	+define+VERILATOR_SIMULATION \


all: obj_dir/V$(TOPLEVEL_MODULE)

obj_dir/V$(TOPLEVEL_MODULE): $(SOURCES)
	$(VERILATOR) $(VERILATOR_OPTIONS) $(DEPS_RTL)

sim: obj_dir/V$(TOPLEVEL_MODULE)
	$<

view: wave.vcd
	gtkwave $<&

wave.vcd: obj_dir/V$(TOPLEVEL_MODULE)
	$(MAKE) sim


clean:
	rm -rf obj_dir $(VIVADO_PROJECT_WORK) wave.vcd


# Vivado sim may require the following additonal components:
# sudo apt install libncurses5 libtinfo5

VIVADO_PROJECT_WORK = VivadoSim

# Simulation tools
XVLOG = $(VIVADO_BIN)/xvlog
XELAB = $(VIVADO_BIN)/xelab
XSIM  = $(VIVADO_BIN)/xsim

vivado-compile: $(SOURCES)
	mkdir $(VIVADO_PROJECT_WORK) -p
	# compile
	cd $(VIVADO_PROJECT_WORK) && $(XVLOG) -sv $(XVLOG_OPTIONS) -i $(SOURCE_ROOT) $(DEPS_RTL) 
	# elaboration
	cd $(VIVADO_PROJECT_WORK) && $(XELAB) --debug all -relax $(TOPLEVEL_MODULE)

vivado-sim: vivado-compile
	cd $(VIVADO_PROJECT_WORK) && $(XSIM) -runall $(XSIM_OPTIONS) $(TOPLEVEL_MODULE)

vivado-sim-gui: vivado-compile
	cd $(VIVADO_PROJECT_WORK) && $(XSIM) -gui $(XSIM_OPTIONS) $(TOPLEVEL_MODULE)
