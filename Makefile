include conf.mk

MFLAGS    ?= -w
TARGET_MK = $(srcdir)/Makefile

PHONY_TARGETS = \
 all \
 build-tools \
 clean \
 clean-conf \
 clean-tools \
 configure-long \
 configure-short \
 dist-clean \
 usage

.PHONY: $(PHONY_TARGETS)

.DEFAULT_GOAL = usage

$(PHONY_TARGETS): $(TARGET_MK)
	@$(MAKE) $(MFLAGS) -C $(<D) -f $(<F) $@
