// BFSTEST : Test breadth-first search in a graph.
// 
// example: cat sample.txt | ./bfstest 1
//
// John R. Gilbert, 17 Feb 20ll

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <assert.h>
#include <sm_11_atomic_functions.h>
#include <helper_cuda.h>
#include "cudaec.c"

#define cutilSafeCall(x) checkCudaErrors(x)
#define cutilCheckMsg(x) getLastCudaError(x)

/* global state */
struct timespec	start_time;																 
struct timespec	end_time;	

int nedges, maxv;

unsigned int seed = 0x12345678;
unsigned int myrand(unsigned int *seed, unsigned int input) {	
	*seed = (*seed << 13) ^ (*seed >> 15) + input + 0xa174de3;
	return *seed;
};

void sig_check(char *level, int nv) {		
	int i;
	unsigned int sig = 0x123456;
	
	for(i = 0; i < nv; i++)
	{		
		myrand(&sig, level[i]);		
	}					 
		
	printf("Computed check sum signature:0x%08x\n", sig);
	if(sig == 0x18169857)
		printf("Result check of sample.txt by signature successful!!\n");
	else if(sig == 0xef872cf0)
		printf("Result check of TEST1 by signature successful!!\n");
	else if(sig == 0xe61d1d00) 
		printf("Result check of TEST3 by signature successful!!\n");
	else if(sig == 0x29c12a44)
		printf("Result check of TEST2 by signature successful!!\n");
	else
		printf("Result check by signature failed!!\n");
}

/* Read input from stdio (for genx.pl files, no more than 40 seconds) */
void read_edge_list (int **tailp, int **headp) {
	int max_edges = 100000000;
	int nr, t, h;
	
	*tailp = (int *) calloc(max_edges, sizeof(int));
	*headp = (int *) calloc(max_edges, sizeof(int));
	nedges = 0;
	maxv = 0;
	nr = scanf("%i %i",&t,&h);
	while (nr == 2) {
		if (nedges >= max_edges) {
			printf("Limit of %d edges exceeded.\n",max_edges);
			exit(1);
		}
		
		if (t > maxv) maxv = t;
		if (h > maxv) maxv = h;
		
		(*tailp)[nedges] = t;
		(*headp)[nedges++] = h;
		nr = scanf("%i %i",&t,&h);
	}
}

__global__ void bfs_cuda(int vsize, char* d_frontier, char* d_visited, char* d_cost, int* d_firstnbr, int* d_nbr, int* d_over, int nlevels){
	const int nodeid = blockIdx.x * 1024 + threadIdx.x;
	int head, tail, temp, frontier_sel = nlevels%2;

	if (nodeid > vsize) return;
	if (frontier_sel == 1 && (d_frontier[nodeid] & 0x80) == 0) return;
	else if (frontier_sel == 0 && (d_frontier[nodeid] & 0x1) == 0) return;

	d_frontier[nodeid] = (frontier_sel == 1) ? (d_frontier[nodeid] & 0x7F) : (d_frontier[nodeid] & 0xFE);
	d_visited[nodeid] = 1;
	head = (nodeid == 0) ? 0 : d_firstnbr[nodeid-1];
	tail = d_firstnbr[nodeid];

	while (head != tail){
		temp = d_nbr[head];
		if (!d_visited[temp]){
			d_frontier[temp] = (frontier_sel == 1) ? 0x1 : 0x80;
			d_cost[temp] = d_cost[nodeid] + 1;
			*d_over = 1;
		}
		head++;
	}
};

__global__ void bfs_cuda_init(int vsize, int startvtx, char* d_frontier, char* d_visited, char* d_cost){
	const int nodeid = blockIdx.x * 1024 + threadIdx.x;
	if (nodeid > vsize) return;
	d_frontier[nodeid] = (nodeid == startvtx) ? 1 : 0;
	d_visited[nodeid] = 0;
	d_cost[nodeid] = (nodeid == startvtx) ? 0 : -1;
};

int main (int argc, char* argv[]) {
	int *head, *tail;
	int *h_firstnbr, *h_nbr;
	int *d_firstnbr, *d_nbr;
	char *h_cost;
	char *d_frontier, *d_visited, *d_cost;
	int block, grid, nlevels = 0;
	int startvtx;
	int i, j;
	int vsize;
	int h_over, *d_over;

	if (argc == 2) {
		startvtx = atoi (argv[1]);
	} else {
		printf("usage:	 bfstest <startvtx> < <edgelistfile>\n");
		printf("example: cat sample.txt | ./bfstest 1\n");
		exit(1);
	}
	
	read_edge_list (&tail, &head);

	clock_gettime(CLOCK_REALTIME, &start_time); //stdio scanf ended, timer starts	//Don't remove it

	vsize = maxv+1;
	block = (vsize > 1023) ? 1024 : vsize;
	grid = (vsize >> 10) + 1;
	
	h_nbr = (int *) calloc(nedges, sizeof(int));
	h_firstnbr = (int *) calloc(vsize+1, sizeof(int));
	h_cost = (char *) malloc(vsize * sizeof(char));

	// count neighbors of vertex v in firstnbr[v+1],
	for (i = 0; i < nedges; i++) h_firstnbr[tail[i]+1]++;

	// cumulative sum of neighbors gives firstnbr[] values
	for (i = 0; i < vsize; i++) h_firstnbr[i+1] += h_firstnbr[i];

	// pass through edges, slotting each one into the CSR structure
	for (i = 0; i < nedges; i++) {
		j = h_firstnbr[tail[i]]++;
		h_nbr[j] = head[i];
	}

	// Allocate vectors in device memory
	cutilSafeCall( cudaMalloc((void**)&d_firstnbr, (vsize+1)*sizeof(int)) );
    CudaCheckError();
	cutilSafeCall( cudaMalloc((void**)&d_nbr, nedges*sizeof(int)) );
    CudaCheckError();
	cutilSafeCall( cudaMalloc((void**)&d_frontier, vsize*sizeof(char)) );
    CudaCheckError();
	cutilSafeCall( cudaMalloc((void**)&d_visited, vsize*sizeof(char)) );
    CudaCheckError();
	cutilSafeCall( cudaMalloc((void**)&d_cost, vsize*sizeof(char)) );
    CudaCheckError();
	cutilSafeCall( cudaMalloc((void**)&d_over, sizeof(int)) );
    CudaCheckError();

	// Copy vectors from host memory to device memory
	cutilSafeCall( cudaMemcpy(d_firstnbr, h_firstnbr, (vsize+1)*sizeof(int), cudaMemcpyHostToDevice) );		
    CudaCheckError();
	cutilSafeCall( cudaMemcpy(d_nbr, h_nbr, nedges*sizeof(int), cudaMemcpyHostToDevice) );
    CudaCheckError();
	bfs_cuda_init<<<grid, block>>>(vsize, startvtx, d_frontier, d_visited, d_cost);
    CudaCheckError();

    while (1){
        h_over = 0;
        cutilSafeCall( cudaMemcpy(d_over, &h_over, sizeof(int), cudaMemcpyHostToDevice) );
        CudaCheckError();
        bfs_cuda<<<grid, block>>>(vsize, d_frontier, d_visited, d_cost, d_firstnbr, d_nbr, d_over, nlevels);
        cutilSafeCall( cudaThreadSynchronize() );
        CudaCheckError();
        nlevels++;
        cutilSafeCall( cudaMemcpy(&h_over, d_over, sizeof(int), cudaMemcpyDeviceToHost) );
        CudaCheckError();
        if (!h_over) break;
    }
		
	cutilSafeCall( cudaMemcpy(h_cost, d_cost, vsize*sizeof(char), cudaMemcpyDeviceToHost) );
    CudaCheckError();

	clock_gettime(CLOCK_REALTIME, &end_time);	//graph construction and bfs completed timer ends	//Don't remove it

	printf("Starting vertex for BFS is %d.\n\n",startvtx);
		
	//Don't remove it
	printf("s_time.tv_sec:%ld, s_time.tv_nsec:%09ld\n", start_time.tv_sec, start_time.tv_nsec);
	printf("e_time.tv_sec:%ld, e_time.tv_nsec:%09ld\n", end_time.tv_sec, end_time.tv_nsec);
	if(end_time.tv_nsec > start_time.tv_nsec)
	{
		printf("[diff_time:%ld.%09ld sec]\n",
		end_time.tv_sec - start_time.tv_sec,
		end_time.tv_nsec - start_time.tv_nsec);
	}
	else
	{
		printf("[diff_time:%ld.%09ld sec]\n",
		end_time.tv_sec - start_time.tv_sec - 1,
		end_time.tv_nsec - start_time.tv_nsec + 1000*1000*1000);
	}

	sig_check(h_cost, vsize);
	free(h_cost);
	free(h_firstnbr);
	free(h_nbr);
	free(tail);
	free(head);
}
