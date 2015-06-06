CC = gcc
CFLAGS = -g -O3
LIBS = -fopenmp -lrt -lm -lpthread
SRCS = main.c
TARGET = main
all:
	gcc ${CFLAGS}  ${LIBS}  ${SRCS} -o ${TARGET} -lrt
clean:
	rm -rf ${TARGET}.out ${TARGET} 
