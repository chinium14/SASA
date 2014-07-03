#############################################################################
#==========================================================================================

CC	=  g++
CFLAGS   = -O3 -ffast-math -finline-functions -funroll-all-loops -Wall # -lRmath
INCL      = -I/usr/include/ 
LIBS    = -L/usr/lib64 -lm 
EXEC 	  = dist_hist
#>>>>>>> 1.5

#
#############################################################################
# nothing should be changed below here


SRCS = main.cpp atom_mass.cpp 
	
     
OBJS = ${SRCS:.c=.o}

all: $(EXEC)

%.o: %.c
	${CC} ${CFLAGS} ${DFLAGS} ${INCL} -c  $< -o $@

$(EXEC):  ${OBJS}
	$(CC) ${CFLAGS} ${DFLAGS} ${INCL} -o $@ ${OBJS} $(LIBS)
	echo $(EXEC)

#$(EXEC):  ${OBJS}
#	$(CC) ${CFLAGS} ${DFLAGS} ${INCL} ${OBJS} $(LIBS)
#	echo $(EXEC)

clean:
	rm -f *.o
	rm -f $(EXEC)

