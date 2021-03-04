H3_CYGWIN_MODELSIM_PATH = /mnt/f/fpga/modelsim_ase/win32aloem

VLOG = $(H3_CYGWIN_MODELSIM_PATH)/vlog.exe
VLIB = $(H3_CYGWIN_MODELSIM_PATH)/vlib.exe
VSIM = $(H3_CYGWIN_MODELSIM_PATH)/vsim.exe -c
MODELSIM = $(H3_CYGWIN_MODELSIM_PATH)/modelsim.exe

PROJECT_WORK = ModelSim
LIBRARY_WORK = $(PROJECT_WORK)/$(LIBRARY_NAME)


# Library name and top-level module to be simulated
LIBRARY_NAME    = H3_Modules
TOPLEVEL_MODULE = H3_RegAdderSim 

# Specify source files
SOURCES = \
	RegFile.v \
	RegAdder.v \
	Adder.v \
	RegAdderSim.v \




DEPS = \
	$(SOURCES) \

#	+incdir+../../Src 

OPTIONS = \
	-lint \
	-pedanticerrors \
	+librescan \
	-sv -nocovercells \
	-work $(LIBRARY_WORK) \
	#-incr \



all: $(DEPS) $(LIBRARY_WORK)
	$(VLOG) $(OPTIONS) $(SOURCES)


# vlib LIBRARY
clean:
	mkdir $(PROJECT_WORK) -p
	rm -f -r $(LIBRARY_WORK)
	( cd $(PROJECT_WORK); $(VLIB) $(LIBRARY_NAME); )

lib: clean

$(LIBRARY_WORK): Makefile
	make clean


# simulation
# vsim LIBRARY -do "run -all"
sim: 
	( cd $(PROJECT_WORK); $(VSIM) $(LIBRARY_NAME).$(TOPLEVEL_MODULE) -do "run -all"; )

# GUI simulation
# Read wave format by executing "do wave.do"
sim-gui: 
	( cd $(PROJECT_WORK); $(MODELSIM) $(LIBRARY_NAME).$(TOPLEVEL_MODULE) -do "do wave.do;";  )




#	( cd $(WORK); $(VLOG) $(OPTIONS) $(DEPS); )


