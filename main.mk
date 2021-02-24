
all: $(PROJ).rpt $(PROJ).bin


%.json: %.v $(ADD_SRC) $(ADD_DEPS)
	yosys -ql $*.log $(if $(USE_ARACHNEPNR),-DUSE_ARACHNEPNR) -p 'synth_ice40 -top top -json $@' $< $(ADD_SRC)

%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --$(DEVICE) $(if $(PACKAGE),--package $(PACKAGE)) $(if $(FREQ),--freq $(FREQ)) --json $(filter-out $<,$^) --pcf $< --asc $@

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime $(if $(FREQ),-c $(FREQ)) -d $(DEVICE) -mtr $@ $<

%_tb: %_tb.v %.v
	iverilog -g2012 -o $@ $^

%_tb.vcd: %_tb
	vvp -N $< +vcd=$@


prog: $(PROJ).bin
	iceprog $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprog $<

clean:
	rm -f $(PROJ).asc $(PROJ).rpt $(PROJ).bin $(PROJ).json $(PROJ).log $(ADD_CLEAN)

.SECONDARY:
.PHONY: all prog clean
