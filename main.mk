
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

obj_dir/V%.cpp: %.v
	verilator -Wall -cc %.v

obj_dir/V%__ALL.a: obj_dir/V%.cpp
	make -C obj_dir -f V$*.mk

sim: $(PROJ).cpp obj_dir/V$(PROJ)__ALL.a
	@echo "Building a Verilator-based simulation of $(PROJ)"
	g++ -std=c++11 -I /usr/local/Cellar/verilator/4.108/share/verilator/include/ \
	-I obj_dir /usr/local/Cellar/verilator/4.108/share/verilator/include/verilated.cpp \
	$(PROJ).cpp obj_dir/V$(PROJ)__ALL.a -o %

# Programming
prog: $(PROJ).bin
	iceprog $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprog $<
# Cleaning
clean:
	rm -f $(PROJ).asc $(PROJ).rpt $(PROJ).bin $(PROJ).json $(PROJ).log $(ADD_CLEAN)

.SECONDARY:
.PHONY: all prog clean
