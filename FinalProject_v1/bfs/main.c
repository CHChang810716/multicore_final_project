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
#include <pthread.h>

typedef struct graphstruct {
	int tid;
} graph;

pthread_barrier_t bar;
pthread_t* thread_array = NULL;

/* global state */
struct timespec	start_time;																 
struct timespec	end_time;	

int startvtx, nedges, maxv, vsize, threadnum = 4, donext, frontier_sel, frontier_dst;
int **frontier, *visited, *cost, *nbr, *firstnbr;

unsigned int seed = 0x12345678;
unsigned int myrand(unsigned int *seed, unsigned int input) {	
	*seed = (*seed << 13) ^ (*seed >> 15) + input + 0xa174de3;
	return *seed;
};

void sig_check(int *level, int nv) {		
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
		printf("Result check of TEST2 by signature successful!!\n");
	else if(sig == 0x29c12a44)
		printf("Result check of TEST3 by signature successful!!\n");
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

/*void print_CSR_graph (graph *G) {
	int vlimit = 20;
	int elimit = 50;
	int e,v;
	printf("\nGraph has %d vertices and %d edges.\n",G->nv,G->ne);
	printf("firstnbr =");
	if (G->nv < vlimit) vlimit = G->nv;
	for (v = 0; v <= vlimit; v++) printf(" %d",G->firstnbr[v]);
	if (G->nv > vlimit) printf(" ...");
	printf("\n");
	printf("nbr =");
	if (G->ne < elimit) elimit = G->ne;
	for (e = 0; e < elimit; e++) printf(" %d",G->nbr[e]);
	if (G->ne > elimit) printf(" ...");
	printf("\n\n");
}*/

void* bfs(void * arg){
	graph *p = (graph *) arg;
	int tid = p->tid, i, start, end, temp;
	frontier_sel = 0;
	frontier_dst = 1;

	while (tid < vsize){
		cost[tid] = (tid == startvtx) ? 0 : -1;
		tid += threadnum;
	}
	while (1){
		tid = p->tid;
		pthread_barrier_wait(&bar);
		while (tid < vsize){
			if (frontier[frontier_sel][tid] && !visited[tid]){
				frontier[frontier_sel][tid] = 0;
				visited[tid] = 1;
				start = (tid == 0) ? 0 : firstnbr[tid-1];
				end = firstnbr[tid];

				while (start != end){
					temp = nbr[start];
					if (!visited[temp] && !frontier[frontier_sel][temp]){
						donext = 1;
						frontier[frontier_dst][temp] = 1;
						cost[temp] = cost[tid] + 1;
					}
					start++;
				}
			}
			tid += threadnum;
		}
		pthread_barrier_wait(&bar);
		if (!donext) break;
		pthread_barrier_wait(&bar);
		if (tid % threadnum == 0){
			frontier_sel = frontier_dst;
			frontier_dst = (frontier_dst + 1) % 2;
			donext = 0;
		}
	}
};

int main (int argc, char* argv[]) {
	graph *arg;
	pthread_attr_t attr;
	int *head, *tail;
	int nlevels = 0;
	int i, v, e;//, reached;

	if (argc == 2) {
		startvtx = atoi (argv[1]);
	} else {
		printf("usage:	 bfstest <startvtx> < <edgelistfile>\n");
		printf("example: cat sample.txt | ./bfstest 1\n");
		exit(1);
	}

	read_edge_list (&tail, &head);
	vsize = maxv+1;
	if (vsize < threadnum) threadnum = vsize;

	/* Initialize and set thread detached attribute */	
	pthread_attr_init(&attr);	
	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

	//initial barrier
	pthread_barrier_init(&bar, NULL, threadnum);

	//initial thread creation
	thread_array = (pthread_t*) malloc(sizeof(pthread_t) * threadnum);
	assert(thread_array);

	//parameter
	arg = (graph *) malloc (sizeof (graph) * threadnum);

	frontier = (int **) malloc(2 * sizeof(int*));
	frontier[0] = (int *) calloc(vsize, sizeof(int));
	frontier[1] = (int *) calloc(vsize, sizeof(int));
	visited = (int *) calloc(vsize, sizeof(int));
	cost = (int *) malloc(vsize * sizeof(int));
	firstnbr = (int *) malloc((vsize+1) * sizeof(int));
	nbr = (int *) malloc(nedges * sizeof(int));

	clock_gettime(CLOCK_REALTIME, &start_time); //stdio scanf ended, timer starts	//Don't remove it

	frontier[0][startvtx] = 1;

	// count neighbors of vertex v in firstnbr[v+1],
	for (i = 0; i < nedges; i++) firstnbr[tail[i]+1]++;

	// cumulative sum of neighbors gives firstnbr[] values
	for (v = 0; v < vsize; v++) firstnbr[v+1] += firstnbr[v];

	// pass through edges, slotting each one into the CSR structure
	for (e = 0; e < nedges; e++) {
		i = firstnbr[tail[e]]++;
		nbr[i] = head[e];
	}
clock_gettime(CLOCK_REALTIME, &end_time);
	//bfs
	for (i = 0; i < threadnum; i++){
		arg[i].tid = i;
		pthread_create(thread_array+i, &attr, bfs, (void *)(arg + i));
	}
	for(i = 0; i < threadnum; i++) pthread_join(thread_array[i], NULL);
	
	//clock_gettime(CLOCK_REALTIME, &end_time);	//graph construction and bfs completed timer ends	//Don't remove it

//	print_CSR_graph (G);
	printf("Starting vertex for BFS is %d.\n\n",startvtx);
	
//	reached = 0;
//	for (i = 0; i < nlevels; i++) reached += levelsize[i];
//	printf("Breadth-first search from vertex %d reached %d levels and %d vertices.\n",
//		startvtx, nlevels, reached);
//	for (i = 0; i < nlevels; i++) printf("level %d vertices: %d\n", i, levelsize[i]);
	if (vsize < 20) {
		printf("\nvertex	level\n");
		for (v = 0; v < vsize; v++) printf("%6d%7d\n", v, cost[v]);
	}
	printf("\n");
		
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

	sig_check(cost, vsize);
	free(cost);
	free(firstnbr);
	free(nbr);
	free(frontier[0]);
	free(frontier[1]);
	free(visited);
	free(tail);
	free(head);

}
