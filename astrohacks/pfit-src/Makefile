PROG	= pfit

OBJS	= pfit.o funcs.o gaussj.o covsrt.o file.o \
  chisq.o plot.o stats.o setup.o

CFLAGS	= -w -O2 -c
LFLAGS	= 
LIBS	= -lm

CC	= f77
LD	= f77



$(PROG)	: $(OBJS)
	  $(LD) $(LFLAGS) $(OBJS) $(LIBS) -o $(PROG)

pfit.o	: pfit.f pfit.cmn
	  $(CC) $(CFLAGS) pfit.f

funcs.o	: funcs.f pfit.cmn
	  $(CC) $(CFLAGS) funcs.f

gaussj.o: gaussj.f pfit.cmn
	  $(CC) $(CFLAGS) gaussj.f

covsrt.o: covsrt.f pfit.cmn
	  $(CC) $(CFLAGS) covsrt.f

file.o	: file.f pfit.cmn
	  $(CC) $(CFLAGS) file.f

chisq.o	: chisq.f pfit.cmn
	  $(CC) $(CFLAGS) chisq.f

plot.o	: plot.f pfit.cmn
	  $(CC) $(CFLAGS) plot.f

stats.o	: stats.f pfit.cmn
	  $(CC) $(CFLAGS) stats.f

setup.o	: setup.f pfit.cmn
	  $(CC) $(CFLAGS) setup.f



clean	:
	  rm $(OBJS) $(PROG)

