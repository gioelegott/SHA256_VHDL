
VHDLDIR=VHDL
WORKDIR=WORK
VCDDIR=VCD
VECDIR=OUTVECS
MAIN=testBench
TIME="1000ns"

GHDL=ghdl
GHDLFLAGS=#--ieee=synopsys --std=93
GHDLRUNFLAGS=--vcd=$(MAIN).vcd --stop-time=$(TIME)

all : run

run : elaboration
	$(GHDL) -c $(GHDLFLAGS) -r $(MAIN) $(GHDLRUNFLAGS)
	mv $(MAIN).vcd VCD
	mv *.cf $(WORKDIR)

elaboration : analysis
	$(GHDL) -c $(GHDLFLAGS) -e $(MAIN)

analysis: clean
	$(GHDL) -a $(GHDLFLAGS) $(VHDLDIR)/extender.vhd
	$(GHDL) -a $(GHDLFLAGS) $(VHDLDIR)/compressor.vhd
	$(GHDL) -a $(GHDLFLAGS) $(VHDLDIR)/SHA256.vhd
	$(GHDL) -a $(GHDLFLAGS) $(VHDLDIR)/vectorGenerator.vhd
	$(GHDL) -a $(GHDLFLAGS) $(VHDLDIR)/$(MAIN).vhd

clean: force
	@rm -f $(WORKDIR)/*.cf $(VCDDIR)/*.vcd *.cf *.vcd

force:

# make:
# 	ghdl -a extender.vhd
# 	ghdl -a compressor.vhd
# 	ghdl -a SHA256.vhd
# 	ghdl -a vectorGenerator.vhd
# 	ghdl -a testBench.vhd
# 	ghdl -e testBench
# 	ghdl -r testBench --vcd=testBench.vcd
