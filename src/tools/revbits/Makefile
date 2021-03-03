CC     = gcc
CFLAGS = -O3 -Wall
EXES   = revbits

.PHONY: usage clean

usage:
	@echo 'Usage:'; \
	echo '  make [ all | clean ]'

all: $(EXES)

revbits: main.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	$(RM) $(EXES)
