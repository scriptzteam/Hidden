CFLAGS := $(CFLAGS) -O2 -Wall

all: hidden

# CFLAGS=-DDEBUG make clean all
dev:
	CFLAGS="$(CFLAGS) -DDEBUG" make hidden

hidden: hidden.c
	gcc $(CFLAGS) -static -o hidden hidden.c
	strip hidden

clean:
	rm -f hidden 2>/dev/null
	if [ -f tests/Makefile ]; then $(MAKE) -C tests clean; fi

tests:
	$(MAKE) -C tests

.PHONY: all dev tests clean
