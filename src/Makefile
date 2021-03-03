# Supported environment:
#   GNU/Linux

include conf/defs.mk

# tools

MFLAGS     ?= -w
CC         = gcc
CFLAGS     = -O3 -Wall
CCZ80      = sdcc
CZ80FLAGS  = -mz80 -no-std-crt0
ASZ80      = sdasz80
ASZ80FLAGS = -pw
LDZ80      = sdldz80
LDZ80FLAGS = -nw
MKBIN      = makebin
MKBAS      = zmakebas
MKWAV      = tape2wav

# local tools

BIN2BAS    = ./tools/bin2bas
PBM2ASM    = ./tools/pbm2asm

# local variables

tmp        = temp.tmp
TMPS       =

# local scripts

need_to_configure = $(error Run "$(MAKE) configure-TARGET" first)

# Assigns specified shell's variable a BASIC integer number in compact form.
# $(1)=name $(2)=value
define set_int_compact =
	if   [ $(2) -eq 0 ]; then $(1)='not pi'; \
	elif [ $(2) -eq 1 ]; then $(1)='sgn pi'; \
	elif [ $(2) -eq 3 ]; then $(1)='int pi'; \
	elif [ $(2) -lt 32 -o $(2) -eq 34 -o $(2) -gt 255 ]; then \
		if   [ $$(($(2)%10000)) -eq 0 ]; then $(1)="val \"$$(($(2)/10000))e4\""; \
		elif [ $$(($(2)% 1000)) -eq 0 ]; then $(1)="val \"$$(($(2)/ 1000))e3\""; \
		else $(1)="val \"$(2)\""; \
		fi; \
	else \
		$(1)="code \"\\\\{$(2)}\""; \
	fi
endef

.PHONY: \
 all \
 build-revbits \
 build-tools \
 clean \
 clean-conf \
 clean-revbits \
 clean-tools \
 configure-long \
 configure-short \
 dist-clean \
 usage

usage:
	@echo 'Usage:'; \
	echo '  $(MAKE) [ build-tools | clean-tools | configure-TARGET | all | clean | dist-clean ]'; \
	echo 'where:'; \
	echo '  build-tools - build local tools'; \
	echo '  clean-tools - clean local tools'; \
	echo '  configure-TARGET - configure the project for specified target'; \
	echo '  all         - build project'; \
	echo '  clean       - clean only project files'; \
	echo '  clean-conf  - clean only configuration files'; \
	echo '  dist-clean  - clean all (local tools, project and configuration files)'; \
	echo 'TARGET is one of:'; \
	echo '  short - short loader form'; \
	echo '  long  - long loader form'

# tools

$(PBM2ASM): tools/revbits/revbits

build-revbits: tools/revbits/revbits

tools/revbits/revbits: tools/revbits/Makefile
	$(MAKE) $(MFLAGS) -C $(<D) all

clean-revbits: tools/revbits/Makefile
	$(MAKE) $(MFLAGS) -C $(<D) clean

build-tools: build-revbits

clean-tools: clean-revbits

# configure

configure-short: templates/loader-head-short.bas
	echo -n '$<' > conf/loader-head.lnk

configure-long: templates/loader-head-long.bas
	echo -n '$<' > conf/loader-head.lnk

conf/loader-head.lnk:
	$(call need_to_configure)

clean-conf:
	$(RM) conf/loader-head.lnk

# sources

loader-head.bas: conf/loader-head.lnk
	cp `cat $<` $@
TMPS += loader-head.bas

loader-head.bin: loader-head.bas
	cp $< "$(tmp)"
	head -n-1 $< > "$(tmp)"
	tail -n 1 $< | sed -re 's/(.+)\\/\1/' >> "$(tmp)"
	$(MKBAS) -a 1 -r -o $@ "$(tmp)"
	$(RM) "$(tmp)"
TMPS += loader-head.bin

loader-title.inc: loader-title.pbm $(PBM2ASM)
	$(PBM2ASM) $< > $@
TMPS += loader-title.inc

loader-asm.rel: loader-asm.s loader-title.inc
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

loader-body.bas: loader-body.bin $(BIN2BAS)
	$(BIN2BAS) $< > $(tmp)
	head -n-1 $(tmp) > $@
	tail -n 1 $(tmp) | sed -re 's/(.+)\\/\1/' >> $@
	$(RM) "$(tmp)"
TMPS += loader-body.bas

loader-tail.bas: templates/loader-tail.bas loader-head.bin
	$(call set_int_compact,_LoaderStart,$(LoaderStart)); \
	$(call set_int_compact,_SkipOffset,$(shell stat -c "%s" loader-head.bin)); \
	sed -r \
		-e "s/\{LoaderStart\}/$$_LoaderStart/g" \
		-e "s/\{SkipOffset\}/$$_SkipOffset/g" \
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

# all

all: test.tap test.wav

# clean

clean:
	$(RM) $(TMPS)

dist-clean: clean-tools clean-conf
	$(RM) $(TMPS)
