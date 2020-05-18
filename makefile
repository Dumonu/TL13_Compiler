GCC = gcc
LEX = flex
YACC = bison
FFLAGS = 
YFLAGS = -t -d
CFLAGS =
LFLAGS = -lfl

EXE := tl13parse

OBJ = $(patsubst %.y,%.tab.o,$(wildcard *.y))
OBJ += $(patsubst %.l,%.yy.o,$(wildcard *.l))
OBJ += $(patsubst %.c,%.o,$(wildcard *.c))

.PHONY: all debug clean

all: $(EXE)

debug: CFLAGS += -g -DDEBUG_
debug: $(EXE).dbg

%.yy.c: %.l
	$(LEX) $(FFLAGS) -o $@ $^

%.tab.c: %.y
	$(YACC) $(YFLAGS) -o $@ $^

%.o: %.c
	$(GCC) -c $(CFLAGS) -o $@ $^

$(EXE): $(OBJ)
	$(GCC) -o $@ $^ $(LFLAGS)

$(EXE).dbg: $(OBJ)
	$(GCC) -o $@ $^ $(LFLAGS)

clean:
	rm -f *.yy.c
	rm -f *.tab.c
	rm -f *.tab.h
	rm -f *.o
	rm -f $(EXE)
	rm -f $(EXE).dbg
