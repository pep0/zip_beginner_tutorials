
all: $(PROJ).rpt $(PROJ).bin


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

# Verilator related targets

# check verion in the path! this is not very pretty.
#VERILATOR_PATH_I = /usr/local/Cellar/verilator/4.108/share/verilator/include/

VERILATOR=verilator
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e "s/^.*=\s*//"')
VINC := $(VERILATOR_ROOT)/include

obj_dir/V%.cpp: %.v
	verilator --trace -Wall -cc $^

obj_dir/V%__ALL.a: obj_dir/V%.cpp
	make --no-print-directory -C obj_dir -f V$*.mk

sim: $(SIM_MODULE).cpp obj_dir/V$(SIM_MODULE)__ALL.a
	@echo "Building a Verilator-based simulation of $(SIM_MODULE)"
	g++ -std=c++11 \
	-I obj_dir \
	-I $(VINC) \
	$(VINC)/verilated.cpp \
	$(VINC)/verilated_vcd_c.cpp \
	$(SIM_MODULE).cpp obj_dir/V$(SIM_MODULE)__ALL.a -o $(SIM_MODULE)

# Fromal Verification

formal: 
	sby $(SIM_MODULE).sby -f


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
