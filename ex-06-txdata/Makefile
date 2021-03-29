################################################################################
##
## Filename: 	Makefile
##
## Project:	Verilog Tutorial Example file
##
## Purpose:	Builds the Verilator design that counts key presses.
##
## Targets:
##
##	The (default) or all target will build a verilator simulation for the
##	serial transmitter.
##
##	clean	Removes all build products
##
## Creator:	Dan Gisselquist, Ph.D.
##		Gisselquist Technology, LLC
##
################################################################################
##
## Written and distributed by Gisselquist Technology, LLC
##
## This program is hereby granted to the public domain.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
## FITNESS FOR A PARTICULAR PURPOSE.
##
################################################################################
##
##

# added for HW 

PROJ = thedesign

ADD_SRC = txdata.v txuart.v counter.v chgdetector.v

PIN_DEF = ../icebreaker/icebreaker.pcf
DEVICE = up5k
PACKAGE = sg48


all: $(PROJ).rpt $(PROJ).bin


thedesign.json: thedesign.v $(ADD_SRC) $(ADD_DEPS)
	yosys -ql $*.log $(if $(USE_ARACHNEPNR),-DUSE_ARACHNEPNR) -p 'synth_ice40 -json thedesign.json' thedesign.v $(ADD_SRC)

%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --$(DEVICE) $(if $(PACKAGE),--package $(PACKAGE)) $(if $(FREQ),--freq $(FREQ)) --json $(filter-out $<,$^) --pcf $< --asc $@

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime $(if $(FREQ),-c $(FREQ)) -d $(DEVICE) -mtr $@ $<

# Programming
prog: $(PROJ).bin
	iceprog $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprog $<

## Verilator sim
.DELETE_ON_ERROR:
TOPMOD  := thedesign
VLOGFIL := $(TOPMOD).v
VCDFILE := $(TOPMOD).vcd
SIMPROG := $(TOPMOD)_tb
SIMFILE := $(SIMPROG).cpp
VDIRFB  := ./obj_dir
COSIMS  := uartsim.cpp
#

GCC := clang++
CFLAGS = -g -std=c++11 -Wall -I $(VINC) -I $(VDIRFB)


VERILATOR=verilator
VFLAGS := -O3 -MMD --trace -Wall
VDEFS  := $(shell ./vversion.sh)

VERILATOR_ROOT ?= $(shell bash -c '$(VERILATOR) -V|grep VERILATOR_ROOT | head -1 | sed -e "s/^.*=\s*//"')
VINC := $(VERILATOR_ROOT)/include

$(VDIRFB)/V$(TOPMOD).cpp: $(VLOGFIL)
	$(VERILATOR) $(VFLAGS) -cc $(VLOGFIL)

$(VDIRFB)/V$(TOPMOD)__ALL.a: $(VDIRFB)/V$(TOPMOD).cpp
	make --no-print-directory -C $(VDIRFB) -f V$(TOPMOD).mk

$(SIMPROG): $(SIMFILE) $(VDIRFB)/V$(TOPMOD)__ALL.a $(COSIMS)
	$(GCC) $(CFLAGS) $(VDEFS) $(VINC)/verilated.cpp			\
		$(VINC)/verilated_vcd_c.cpp $(SIMFILE) $(COSIMS)	\
		$(VDIRFB)/V$(TOPMOD)__ALL.a -lncurses -o $(SIMPROG)

test: $(VCDFILE)

$(VCDFILE): $(SIMPROG)
	./$(SIMPROG)


.PHONY: clean
clean:
	rm -rf $(VDIRFB)/ $(SIMPROG) $(VCDFILE) txdata/ chgdetector/ 
	rm -f $(TOPMOD).json $(TOPMOD).bin
##
## Find all of the Verilog dependencies and submodules
##
DEPS := $(wildcard $(VDIRFB)/*.d)

## Include any of these submodules in the Makefile
## ... but only if we are not building the "clean" target
## which would (oops) try to build those dependencies again
##
ifneq ($(MAKECMDGOALS),clean)
ifneq ($(DEPS),)
include $(DEPS)
endif
endif
