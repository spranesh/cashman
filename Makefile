
#Very simple makefile for a debian/ubuntu system
COMPILER=ghc
PREFIX=/usr/bin
PROG=cashman

all: ${PROG}.hs
	${COMPILER} --make ${PROG}

install: ${PROG}
	cp ${PROG} ${PREFIX}
	chmod +x ${PREFIX}/${PROG}
	chmod 777 ${PREFIX}/${PROG}
	
clean: 
	rm -rf ${PROG}.hi ${PROG}.o ${PROG}.hi ${PROG}

tar:
	git archive --format=tar --prefix=${PROG}/ HEAD | gzip > ${PROG}.tar.gz

