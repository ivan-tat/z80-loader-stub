CC         = gcc
CFLAGS     = -O3 -Wall
CCZ80      = sdcc
CZ80FLAGS  = -mz80 -no-std-crt0
ASZ80      = sdasz80
ASZ80FLAGS = -l
LDZ80      = sdldz80
LDZ80FLAGS =
MKBIN      = makebin
BIN2BAS    = ./tools/bin2bas
PBM2ASM    = ./tools/pbm2asm
MKBAS      = zmakebas
MKWAV      = tape2wav
loader_basic_entry = loadb-0.b.long
#loader_basic_entry = loadb-0.b.short
TMPFILES   = \
 loadb-0.bas \
 loadb-0.bin \
 loadb-2.bas \
 loadb.bas \
 loader.bin \
 loader.ihx \
 loader.lst \
 loader.rel \
 loadtitle.s \
 stub.bin \
 stub.ihx \
 stub.lst \
 stub.rel \
 stub.s \
 test.bas \
 test.tap \
 test.wav

tmp         = temp.tmp
LoaderStart = 28800

.PHONY: empty clean

empty:
	@echo 'Usage:'
	@echo '  make [ all | clean ]'

all: tools/revbits test.tap test.wav

tools/revbits:
	make -C tools -f revbits.mk all

test.tap: loadb.bas
	$(MKBAS) -n "Test" -a 1 -o $@ $<

test.wav: test.tap
	$(MKWAV) $< $@

##############################
# Parts of BASIC loader stub #
##############################

loadb-0.bas: $(loader_basic_entry)
	cp $< "$(tmp)"
	echo "" >> "$(tmp)"
	mv "$(tmp)" $@

loadb-0.bin: loadb-0.bas
	$(MKBAS) -a 1 -r -o $@ $<

loadb-2.bas: loadb-0.bin loadb-2.b
	sed -r \
		-e "s/\{LoaderStart\}/$(LoaderStart)/g" \
		-e "s/\{SkipOffset\}/`stat -c "%s" loadb-0.bin`/g" \
		loadb-2.b > $@

###############################
# The whole BASIC loader stub #
###############################

loadb: loadb.bas

loadb.bas: $(loader_basic_entry) stub.bin loadb-2.bas
	cp $(loader_basic_entry) $@
	$(BIN2BAS) stub.bin >> $@
	cat loadb-2.bas >> $@

##################
# Loader's title #
##################

loadtitle.s: loadtitle.pbm tools/revbits
	$(PBM2ASM) loadtitle.pbm > $@

###############
# Main loader #
###############

loader: loader.bin

loader.bin: loader.ihx
	$(MKBIN) -p -s 65536 $< | dd ibs=1 skip=$(LoaderStart) of=$@ 2>/dev/null

loader.ihx: loader.rel
	$(LDZ80) $(LDZ80FLAGS) -b _CODE=$(LoaderStart) -i $<

loader.rel: loader.s loadtitle.s
	$(ASZ80) $(ASZ80FLAGS) -o $<

########################
# Stub for main loader #
########################

stub: stub.bin

stub.bin: loader.bin stub.ihx
	$(MKBIN) -p stub.ihx > "$(tmp)"
	cat "$(tmp)" loader.bin > $@
	$(RM) "$(tmp)"

stub.ihx: stub.rel
	$(LDZ80) $(LDZ80FLAGS) -b _CODE=0 -i $<

stub.rel: loadb-0.bin loader.bin stub-0.s
	sed -r \
		-e "s/\{SkipOffset\}/`stat -c "%s" loadb-0.bin`-1/g" \
		-e "s/\{LoaderStart\}/$(LoaderStart)/g" \
		-e "s/\{LoaderSize\}/`stat -c "%s" loader.bin`/g" \
		 stub-0.s > stub.s
	$(ASZ80) $(ASZ80FLAGS) -o stub.s

clean:
	$(RM) $(TMPFILES)
	make -C tools -f revbits.mk clean
