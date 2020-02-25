CC         = gcc
CFLAGS     = -O3 -Wall
CCZ80      = sdcc
CZ80FLAGS  = -mz80 -no-std-crt0
ASZ80      = sdasz80
ASZ80FLAGS =
LDZ80      = sdldz80
LDZ80FLAGS = -nw
MKBIN      = makebin
BIN2BAS    = ./tools/bin2bas
PBM2ASM    = ./tools/pbm2asm
MKBAS      = zmakebas
MKWAV      = tape2wav
loader_basic_entry = loadb-0.b.long
#loader_basic_entry = loadb-0.b.short
TMPS       =

tmp         = temp.tmp
LoaderStart = 28800

.PHONY: empty clean

empty:
	@echo 'Usage:'; \
	echo '  make [ all | clean ]'

all: tools/revbits test.tap test.wav

tools/revbits: tools/revbits.mk
	make -C $(<D) -f $(<F) all

test.tap: loadb.bas
	$(MKBAS) -n "Test" -a 1 -o $@ $<
TMPS += test.tap

test.wav: test.tap
	$(MKWAV) $< $@
TMPS += test.wav

##############################
# Parts of BASIC loader stub #
##############################

loadb-0.bas: $(loader_basic_entry)
	cp $< "$(tmp)"
	echo "" >> "$(tmp)"
	mv "$(tmp)" $@
TMPS += loadb-0.bas

loadb-0.bin: loadb-0.bas
	$(MKBAS) -a 1 -r -o $@ $<
TMPS += loadb-0.bin

loadb-2.bas: loadb-0.bin loadb-2.b
	sed -r \
		-e "s/\{LoaderStart\}/$(LoaderStart)/g" \
		-e "s/\{SkipOffset\}/`stat -c "%s" loadb-0.bin`/g" \
		loadb-2.b > $@
TMPS += loadb-2.bas

###############################
# The whole BASIC loader stub #
###############################

loadb: loadb.bas

loadb.bas: $(loader_basic_entry) stub.bin loadb-2.bas
	cp $< $@
	$(BIN2BAS) stub.bin >> $@
	cat loadb-2.bas >> $@
TMPS += loadb.bas

##################
# Loader's title #
##################

loadtitle.s: loadtitle.pbm tools/revbits
	$(PBM2ASM) $< > $@
TMPS += loadtitle.s

###############
# Main loader #
###############

loader: loader.bin

loader.bin: loader.ihx
	$(MKBIN) -p -s 65536 $< | dd ibs=1 skip=$(LoaderStart) of=$@ 2>/dev/null
TMPS += loader.bin

loader.ihx: loader.rel
	$(LDZ80) $(LDZ80FLAGS) -b _CODE=$(LoaderStart) -i $<
TMPS += loader.ihx

loader.rel: loader.s loadtitle.s
	$(ASZ80) $(ASZ80FLAGS) -ol $<
TMPS += loader.rel loader.lst

########################
# Stub for main loader #
########################

stub: stub.bin

stub.bin: loader.bin stub.ihx
	$(MKBIN) -p stub.ihx > "$(tmp)"
	cat "$(tmp)" loader.bin > $@
	$(RM) "$(tmp)"
TMPS += stub.bin

stub.ihx: stub.rel
	$(LDZ80) $(LDZ80FLAGS) -b _CODE=0 -i $<
TMPS += stub.ihx

stub.rel: stub.s
	$(ASZ80) $(ASZ80FLAGS) -ol $<
TMPS += stub.rel stub.lst

stub.s: stub-0.s loadb-0.bin loader.bin
	sed -r \
		-e "s/\{SkipOffset\}/`stat -c "%s" loadb-0.bin`-1/g" \
		-e "s/\{LoaderStart\}/$(LoaderStart)/g" \
		-e "s/\{LoaderSize\}/`stat -c "%s" loader.bin`/g" \
		 $< > $@
TMPS += stub.s

clean:
	$(RM) $(TMPS)
	make -C tools -f revbits.mk clean
