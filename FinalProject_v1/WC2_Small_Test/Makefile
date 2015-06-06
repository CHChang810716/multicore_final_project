CC=g++
CFLAG=-std=c++98

all:s1 s2

s1:reducer_s1 mapper_s1

reducer_s1:
	$(CC) $(CFLAG) -o reducer_s1 reducer_s1.c

mapper_s1:
	$(CC) $(CFLAG) -o mapper_s1 mapper_s1.c

s2:reducer_s2 mapper_s2

reducer_s2:
	$(CC) $(CFLAG) reducer_s2.cpp -o reducer_s2

mapper_s2:
	$(CC) $(CFLAG) mapper_s2.cpp -o mapper_s2
clean:
	rm reducer_s2 mapper_s2 mapper_s1 reducer_s1
