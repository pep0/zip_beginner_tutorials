PROJ := helloworld
ADD_SRC = txuart/txuart.v

ADD_CLEAN_FOLDER = txuart_cvr txuart_prf helloworld

PIN_DEF = ../icebreaker/icebreaker.pcf
DEVICE = up5k
PACKAGE = sg48 

# Verilator related


TOPMOD := helloworld
VLOGFILE := $(TOPMOD).v
VCDFILE := $(TOPMOD).vcd
SIMPROG := $(TOPMOD)_tb
SIMFILE := $(SIMPROG).cpp
VDIRFB := ./obj_dir
COSIMS := uartsim.cpp

SIM_ADD_SRC = $(ADD_SRC)

ADD_CLEAN = $(VCDFILE)



all: $(PROJ).rpt $(PROJ).bin $(VCDFILE)


%.json: %.v $(ADD_SRC) $(ADD_DEPS)
	yosys -ql $*.log $(if $(USE_ARACHNEPNR),-DUSE_ARACHNEPNR) -p 'synth_ice40 -json $@' $< $(ADD_SRC)

%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --$(DEVICE) $(if $(PACKAGE),--package $(PACKAGE)) $(if $(FREQ),--freq $(FREQ)) --json $(filter-out $<,$^) --pcf $< --asc $@

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime $(if $(FREQ),-c $(FREQ)) -d $(DEVICE) -mtr $@ $<
# iVerilog test bench
%_tb: %_tb.v %.v
	iverilog -g2012 -o $@ $^

%_tb.vcd: %_tb
	vvp -N $< +vcd=$@


# Verilator related


# check verion in the path! this is not very pretty.
#VERILATOR_PATH_I = /usr/local/Cellar/verilator/4.108/share/verilator/include/
GCC := clang++
VINC = $(VERILATOR_ROOT)/include
CFLAGS = -g -std=c++11 -Wall -I $(VINC) -I $(VDIRFB)
ADD_SIM_FLAGS = -O3 -MMD -Wno-lint
VERILATOR=verilator
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e "s/^.*=\s*//"')


$(VDIRFB)/V$(TOPMOD).cpp: $(VLOGFILE) 
	verilator --trace -Wall $(ADD_SIM_FLAGS) -cc $(VLOGFILE) $(SIM_ADD_SRC)

$(VDIRFB)/V$(TOPMOD)__ALL.a: $(VDIRFB)/V$(TOPMOD).cpp
	make --no-print-directory -C $(VDIRFB) -f V$(TOPMOD).mk

$(SIMPROG): $(SIMFILE) $(VDIRFB)/V$(TOPMOD)__ALL.a $(COSIMS)
	@echo "Building a Verilator-based simulation of $(SIMPROG)"
	$(GCC) $(CFLAGS) $(VINC)/verilated.cpp \
	$(VINC)/verilated_vcd_c.cpp $(SIMFILE) $(COSIMS) \
	$(VDIRFB)/V$(TOPMOD)__ALL.a -o $(SIMPROG)


sim: $(VCDFILE)

$(VCDFILE): $(SIMPROG)
	./$(SIMPROG)


# Fromal Verification

formal: 
	sby $(TOPMOD).sby -f


# Programming
prog: $(PROJ).bin
	iceprog $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprog $<
# Cleaning
clean:
	rm -f $(PROJ).asc $(PROJ).rpt $(PROJ).bin $(PROJ).json $(PROJ).log $(ADD_CLEAN) 
	rm -f $(SIM_MODULE).log
	rm -f $(SIM_MODULE)trace.vcd $(SIM_MODULE).vcd
	rm -f -r obj_dir
	rm -f -r $(SIM_MODULE)
	rm -f -r $(ADD_CLEAN_FOLDER)
	rm -f $(SIM_MODULE)

.SECONDARY:
.PHONY: all prog formal clean


