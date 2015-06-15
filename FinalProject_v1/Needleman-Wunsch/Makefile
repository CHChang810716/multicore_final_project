CC_FLAGS = -O2 -gencode=arch=compute_11,code=\"sm_11,compute_11\"  -gencode=arch=compute_20,code=\"sm_20,compute_20\" --compiler-options -fno-strict-aliasing  -I. -I/usr/local/cuda-6.5/include -I /usr/local/cuda-6.5/samples/common/inc -DUNIX 
LIB = -fPIC -L /usr/local/cuda-6.5/lib64 -lcudart -lrt
# C compiler
#CC = g++
CC = nvcc
#CC_FLAGS = -O2 -m32  
CC_FLAGS = -O2
#LIB = -lpthread -lrt
#SOURCE = needle.cu
#SOURCE = needle_thread.cpp
SOURCE = needle.cpp
needle: 
	$(CC) -c $(CC_FLAGS) $(SOURCE) -o needle.o
	g++ -o needle needle.o $(LIB)
clean:
	rm -f needle result.txt 
