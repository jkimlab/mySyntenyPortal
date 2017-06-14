ARCH ?= $(shell arch)

CC = gcc
#CDEBUG = -ggdb -g -mcmodel=medium# -pg
CDEBUG = -ggdb -g # -pg
OPTM = -O3
WARN = -W -Wall
CFLAGS = $(WARN) -I.

BIN = $(HOME)/bin/$(ARCH)
RM = rm -rf

D = DATA

ALLSRC = checkNets readNets getSegments partitionGenomes makeOrthologyBlocks makeOrthologyBlocks_pair\
         orthoBlocksToOrders makeConservedSegments outgroupSegsToOrders \
         cleanOutgroupSegs createGenomeFile inferCars createCarFile \
         splitChain splitNet onlySpe bpPosition mergePieces

OBJ = util.o base.o species.o

all: $D $(OBJ) $(ALLSRC)

$D:
	-mkdir $D
	ln -s ../mk.data $D/Makefile
	ln -s ../config.file $D/config.file

%.o: %.c %.h
	$(CC) $(CDEBUG) $(CFLAGS) -c $(addsuffix .c, $(basename $@))

partitionGenomes: partitionGenomes.c $(OBJ)
	$(CC) $(CDEBUG) $(CFLAGS) $+ -o $@

%: %.c util.o species.o
	$(CC) $(CDEBUG) $(CFLAGS) $+ -o $@

.PHONY: clean
clean:
	$(RM) *.dSYM $(ALLSRC)  $(OBJ)
	
