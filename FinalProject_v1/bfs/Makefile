INCLUDE = -I. -I/usr/local/cuda-6.5/include -I /usr/local/cuda-6.5/samples/common/inc -DUNIX
#CC = gcc
CC = nvcc
CFLAGS = -O3 #-DCUDA_ERROR_CHECK
#LIBS = -fopenmp -lrt -lm -lpthread
#SRCS = main.c
SRCS=main.cu
TARGET = main
all:
	$(CC) ${CFLAGS}  ${LIBS}  ${SRCS} -o ${TARGET} $(INCLUDE) 
clean:
	rm -rf ${TARGET}.out ${TARGET} 
