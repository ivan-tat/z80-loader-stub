CC     = gcc
CFLAGS = -O3 -Wall
EXES   = revbits

.PHONY: empty clean

empty:
	@echo 'Usage:'; \
	echo '  make [ all | clean ]'

all: $(EXES)

%: %.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	$(RM) $(EXES)
