include conf/defs.mk

CC         = gcc
CFLAGS     = -O3 -Wall
CCZ80      = sdcc
CZ80FLAGS  = -mz80 -no-std-crt0
ASZ80      = sdasz80
ASZ80FLAGS = -pw
LDZ80      = sdldz80
LDZ80FLAGS = -w
MKBIN      = makebin
BIN2BAS    = ./tools/bin2bas
PBM2ASM    = ./tools/pbm2asm
MKBAS      = zmakebas
MKWAV      = tape2wav
loader_head = templates/loader-head-long.bas
#loader_head = templates/loader-head-short.bas
TMPS       =
tmp         = temp.tmp

# Assigns specified shell's variable a BASIC integer number in compact form.
# $(1)=name $(2)=value
define set_int_compact =
	if   [ $(2) -eq 0 ]; then $(1)='not pi'; \
	elif [ $(2) -eq 1 ]; then $(1)='sgn pi'; \
	elif [ $(2) -eq 3 ]; then $(1)='int pi'; \
	elif [ $(2) -lt 32 -o $(2) -eq 34 -o $(2) -gt 255 ]; then \
		$(1)="val \"$(2)\""; \
	else \
		$(1)="code \"\\\\{$(2)}\""; \
	fi
endef

.PHONY: empty all clean

empty:
	@echo 'Usage:'; \
	echo '  make [ all | clean ]'

tools/revbits: tools/revbits.mk
	make -C $(<D) -f $(<F) all

loader-head.bas: $(loader_head)
	cp $< $@
TMPS += loader-head.bas

loader-head.bin: loader-head.bas
	cp $< "$(tmp)"
	head -n-1 $< > "$(tmp)"
	tail -n 1 $< | sed -re 's/(.+)\\/\1/' >> "$(tmp)"
	$(MKBAS) -a 1 -r -o $@ "$(tmp)"
	$(RM) "$(tmp)"
TMPS += loader-head.bin

loader-title.s: loader-title.pbm tools/revbits
	$(PBM2ASM) $< > $@
TMPS += loader-title.s

loader-asm.rel: loader-asm.s loader-title.s
	$(ASZ80) $(ASZ80FLAGS) -ol $<
TMPS += loader-asm.rel loader-asm.lst

loader-asm.ihx: loader-asm.rel
	$(LDZ80) $(LDZ80FLAGS) -b _CODE=$(LoaderStart) -i $<
TMPS += loader-asm.ihx

loader-asm.bin: loader-asm.ihx
	$(MKBIN) -p -s 65536 $< | dd ibs=1 skip=$(LoaderStart) of=$@ 2>/dev/null
TMPS += loader-asm.bin

startup.s: templates/startup.s loader-head.bin loader-asm.bin
	sed -r \
		-e "s/\{SkipOffset\}/`stat -c "%s" loader-head.bin`-1/g" \
		-e "s/\{LoaderStart\}/$(LoaderStart)/g" \
		-e "s/\{LoaderSize\}/`stat -c "%s" loader-asm.bin`/g" \
		 $< > $@
TMPS += startup.s

startup.rel: startup.s
	$(ASZ80) $(ASZ80FLAGS) -ol $<
TMPS += startup.rel startup.lst

startup.ihx: startup.rel
	$(LDZ80) $(LDZ80FLAGS) -b _CODE=0 -i $<
TMPS += startup.ihx

startup.bin: startup.ihx
	$(MKBIN) -p $< > $@
TMPS += startup.bin

loader-body.bin: startup.bin loader-asm.bin
	cat $^ > $@
TMPS += loader-body.bin

loader-body.bas: loader-body.bin
	$(BIN2BAS) $< > $(tmp)
	head -n-1 $(tmp) > $@
	tail -n 1 $(tmp) | sed -re 's/(.+)\\/\1/' >> $@
	$(RM) "$(tmp)"
TMPS += loader-body.bas

loader-tail.bas: templates/loader-tail.bas loader-head.bin
	$(call set_int_compact,SkipOffset,$(shell stat -c "%s" loader-head.bin)); \
	sed -r \
		-e "s/\{LoaderStart\}/$(LoaderStart)/g" \
		-e "s/\{SkipOffset\}/$$SkipOffset/g" \
		$< > $@
TMPS += loader-tail.bas

loader-full.bas: loader-head.bas loader-body.bas loader-tail.bas
	cat $^ > $@
TMPS += loader-full.bas

test.tap: loader-full.bas
	$(MKBAS) -n "Test" -a 1 -o $@ $<
TMPS += test.tap

test.wav: test.tap
	$(MKWAV) $< $@
TMPS += test.wav

all: tools/revbits test.tap test.wav

clean:
	$(RM) $(TMPS)
	make -C tools -f revbits.mk clean
