PROG	= pfit

OBJS	= pfit.o funcs.o gaussj.o covsrt.o file.o \
  chisq.o stats.o setup.o

CFLAGS	= -w -O2 -c
LFLAGS	= 
LIBS	= -lf2c -lm

CC	= gcc
LD	= gcc



$(PROG)	: $(OBJS)
	  $(LD) $(LFLAGS) $(OBJS) $(LIBS) -o $(PROG)

pfit.o	: pfit.c
	  $(CC) $(CFLAGS) pfit.c

funcs.o	: funcs.c
	  $(CC) $(CFLAGS) funcs.c

gaussj.o: gaussj.c
	  $(CC) $(CFLAGS) gaussj.c

covsrt.o: covsrt.c
	  $(CC) $(CFLAGS) covsrt.c

file.o	: file.c
	  $(CC) $(CFLAGS) file.c

chisq.o	: chisq.c
	  $(CC) $(CFLAGS) chisq.c

stats.o	: stats.c
	  $(CC) $(CFLAGS) stats.c

setup.o	: setup.c
	  $(CC) $(CFLAGS) setup.c



clean	:
	  rm $(OBJS) $(PROG)

