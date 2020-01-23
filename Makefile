include conf.mk

TARGET_MK = $(srcdir)/Makefile

.DEFAULT_GOAL = empty

.PHONY: empty all clean

empty clean: $(TARGET_MK)
	@make -C $(<D) -f $(<F) $@

all: $(TARGET_MK)
	@make -C $(<D) -f $(<F) $@
