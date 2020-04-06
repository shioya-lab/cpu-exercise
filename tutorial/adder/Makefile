H3_CYGWIN_MODELSIM_PATH = $(shell cygpath -u "$$H3_MODELSIM_PATH")

VLOG = $(H3_CYGWIN_MODELSIM_PATH)/vlog.exe
VLIB = $(H3_CYGWIN_MODELSIM_PATH)/vlib.exe
VSIM = $(H3_CYGWIN_MODELSIM_PATH)/vsim.exe
MODELSIM = $(H3_CYGWIN_MODELSIM_PATH)/modelsim.exe

PROJECT_WORK = ModelSim
LIBRARY_WORK = $(PROJECT_WORK)/$(LIBRARY_NAME)


# ライブラリ名とトップレベルモジュール（シミュレーション対象）
LIBRARY_NAME    = H3_Modules
TOPLEVEL_MODULE = H3_Simulator 

# コンパイル対象のファイル
SOURCES = \
	Adder.v \
	AdderSim.v \



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
	rm -f -r $(LIBRARY_WORK)
	( cd $(PROJECT_WORK); $(VLIB) $(LIBRARY_NAME); )

lib: clean

$(LIBRARY_WORK): Makefile
	make clean


# simulation
# vsim LIBRARY -do "run -all"
sim: 
	( cd $(PROJECT_WORK); $(VSIM) $(LIBRARY_NAME).$(TOPLEVEL_MODULE) -do "run -all"; )

# do wave.do で 波形フォーマットを読み込んだ後，
# 50ns 走らせる．
sim-gui: 
	( cd $(PROJECT_WORK); $(MODELSIM) $(LIBRARY_NAME).$(TOPLEVEL_MODULE) -do "do wave.do; run 50ns"; )




#	( cd $(WORK); $(VLOG) $(OPTIONS) $(DEPS); )


