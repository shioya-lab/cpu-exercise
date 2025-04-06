
# Top-level module to be simulated
TOPLEVEL_MODULE = MainSim 

# Specify source files
SOURCES = \
	BasicTypes.sv \
	Types.sv \
	ALU.sv \
	Branch.sv \
	ClockDivider.sv \
	CPU.sv \
	Decoder.sv \
	DMem.sv \
	IMem.sv \
	IOCtrl.sv \
	Main.sv \
	MainSim.sv \
	PC.sv \
	RegFile.sv \

SOURCE_ROOT = $(CPU_EXERCISE_ROOT)/tutorial/processor/
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
	rm -rf obj_dir $(VIVADOSIM_PROJECT_WORK) wave.vcd *.log *.jou


# Vivado sim may require the following additonal components:
# sudo apt install libncurses5 libtinfo5

VIVADOSIM_PROJECT_WORK = VivadoSim

# Simulation tools
XVLOG = $(VIVADO_BIN)/xvlog
XELAB = $(VIVADO_BIN)/xelab
XSIM  = $(VIVADO_BIN)/xsim

XVLOG_OPTIONS = \
	-d VIVADO_SIMULATION \

vivado-compile: $(SOURCES)
	mkdir $(VIVADOSIM_PROJECT_WORK) -p
	# compile
	cd $(VIVADOSIM_PROJECT_WORK) && $(XVLOG) -sv $(XVLOG_OPTIONS) -i $(SOURCE_ROOT) $(DEPS_RTL) 
	# elaboration
	cd $(VIVADOSIM_PROJECT_WORK) && $(XELAB) --debug all -relax $(TOPLEVEL_MODULE)

vivado-sim: vivado-compile
	cd $(VIVADOSIM_PROJECT_WORK) && $(XSIM) -runall $(XSIM_OPTIONS) $(TOPLEVEL_MODULE)

vivado-sim-gui: vivado-compile
	cd $(VIVADOSIM_PROJECT_WORK) && $(XSIM) -gui $(XSIM_OPTIONS) $(TOPLEVEL_MODULE)

VIVADO_PROJECT_WORK = vivado_project

vivado: $(VIVADO_PROJECT_WORK)/vivado_project/vivado_project.xpr
	cd $(VIVADO_PROJECT_WORK) && vivado vivado_project/vivado_project.xpr &

$(VIVADO_PROJECT_WORK)/vivado_project/vivado_project.xpr:
	mkdir -p $(VIVADO_PROJECT_WORK)
	cd $(VIVADO_PROJECT_WORK) && vivado -mode batch -source ../script/vivado_project.tcl

vivado-clean:
	rm -rf $(VIVADO_PROJECT_WORK)