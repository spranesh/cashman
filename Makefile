
#Very simple makefile for a debian/ubuntu system
COMPILER=ghc
PREFIX=/usr/bin
PROG=cashman

all: ${PROG}.hs
	${COMPILER} --make ${PROG}

install: ${PROG}
	mv ${PROG} ${PREFIX}
	chmod +x ${PREFIX}/${PROG}
	chmod -777 ${PREFIX}/${PROG}
	
clean: 
	rm -rf ${PROG}.hi ${PROG}.o ${PROG}.hi ${PROG}


