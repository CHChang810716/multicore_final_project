# C compiler
#CC = g++
CC = nvcc
#CC_FLAGS = -O2 -m32  
CC_FLAGS = -O2
#LIB = -lpthread
SOURCE = needle.cu
#SOURCE = needle.cpp
needle: 
	$(CC) $(CC_FLAGS) $(SOURCE) -o needle -lrt  $(LIB)

clean:
	rm -f needle result.txt 
