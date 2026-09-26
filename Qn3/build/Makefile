# Qn3 Makefile
# Builds the Tcl -> C++ transpiler (tclc) into this build/ directory.

SRC_DIR = ../src
CC = gcc
CFLAGS = -w

all: tclc

tclc: $(SRC_DIR)/tcl.tab.c $(SRC_DIR)/lex.yy.c
	$(CC) $(CFLAGS) -o tclc $(SRC_DIR)/tcl.tab.c $(SRC_DIR)/lex.yy.c

$(SRC_DIR)/tcl.tab.c: $(SRC_DIR)/tcl.y
	bison -d -o $(SRC_DIR)/tcl.tab.c $(SRC_DIR)/tcl.y

$(SRC_DIR)/lex.yy.c: $(SRC_DIR)/tcl.l
	flex -o $(SRC_DIR)/lex.yy.c $(SRC_DIR)/tcl.l

clean:
	rm -f tclc $(SRC_DIR)/tcl.tab.c $(SRC_DIR)/tcl.tab.h $(SRC_DIR)/lex.yy.c output.cpp

.PHONY: all clean
