#define LIMIT -999
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#include <time.h>
//#include <pthread.h>
#include "cudaec.hpp"
struct timespec start_time;
struct timespec end_time;


////////////////////////////////////////////////////////////////////////////////
// declaration, forward
void runTest( int argc, char** argv);
__device__ __host__ int maximum( int a, int b, int c)
{
	int k;
	if( a <= b )
		k = b;
	else 
	k = a;

	if( k <=c )
	return(c);
	else
	return(k);
}


int blosum62[24][24] = {
{ 4, -1, -2, -2,  0, -1, -1,  0, -2, -1, -1, -1, -1, -2, -1,  1,  0, -3, -2,  0, -2, -1,  0, -4},
{-1,  5,  0, -2, -3,  1,  0, -2,  0, -3, -2,  2, -1, -3, -2, -1, -1, -3, -2, -3, -1,  0, -1, -4},
{-2,  0,  6,  1, -3,  0,  0,  0,  1, -3, -3,  0, -2, -3, -2,  1,  0, -4, -2, -3,  3,  0, -1, -4},
{-2, -2,  1,  6, -3,  0,  2, -1, -1, -3, -4, -1, -3, -3, -1,  0, -1, -4, -3, -3,  4,  1, -1, -4},
{ 0, -3, -3, -3,  9, -3, -4, -3, -3, -1, -1, -3, -1, -2, -3, -1, -1, -2, -2, -1, -3, -3, -2, -4},
{-1,  1,  0,  0, -3,  5,  2, -2,  0, -3, -2,  1,  0, -3, -1,  0, -1, -2, -1, -2,  0,  3, -1, -4},
{-1,  0,  0,  2, -4,  2,  5, -2,  0, -3, -3,  1, -2, -3, -1,  0, -1, -3, -2, -2,  1,  4, -1, -4},
{ 0, -2,  0, -1, -3, -2, -2,  6, -2, -4, -4, -2, -3, -3, -2,  0, -2, -2, -3, -3, -1, -2, -1, -4},
{-2,  0,  1, -1, -3,  0,  0, -2,  8, -3, -3, -1, -2, -1, -2, -1, -2, -2,  2, -3,  0,  0, -1, -4},
{-1, -3, -3, -3, -1, -3, -3, -4, -3,  4,  2, -3,  1,  0, -3, -2, -1, -3, -1,  3, -3, -3, -1, -4},
{-1, -2, -3, -4, -1, -2, -3, -4, -3,  2,  4, -2,  2,  0, -3, -2, -1, -2, -1,  1, -4, -3, -1, -4},
{-1,  2,  0, -1, -3,  1,  1, -2, -1, -3, -2,  5, -1, -3, -1,  0, -1, -3, -2, -2,  0,  1, -1, -4},
{-1, -1, -2, -3, -1,  0, -2, -3, -2,  1,  2, -1,  5,  0, -2, -1, -1, -1, -1,  1, -3, -1, -1, -4},
{-2, -3, -3, -3, -2, -3, -3, -3, -1,  0,  0, -3,  0,  6, -4, -2, -2,  1,  3, -1, -3, -3, -1, -4},
{-1, -2, -2, -1, -3, -1, -1, -2, -2, -3, -3, -1, -2, -4,  7, -1, -1, -4, -3, -2, -2, -1, -2, -4},
{ 1, -1,  1,  0, -1,  0,  0,  0, -1, -2, -2,  0, -1, -2, -1,  4,  1, -3, -2, -2,  0,  0,  0, -4},
{ 0, -1,  0, -1, -1, -1, -1, -2, -2, -1, -1, -1, -1, -2, -1,  1,  5, -2, -2,  0, -1, -1,  0, -4},
{-3, -3, -4, -4, -2, -2, -3, -2, -2, -3, -2, -3, -1,  1, -4, -3, -2, 11,  2, -3, -4, -3, -2, -4},
{-2, -2, -2, -3, -2, -1, -2, -3,  2, -1, -1, -2, -1,  3, -3, -2, -2,  2,  7, -1, -3, -2, -1, -4},
{ 0, -3, -3, -3, -1, -2, -2, -3, -3,  3,  1, -2,  1, -1, -2, -2,  0, -3, -1,  4, -3, -2, -1, -4},
{-2, -1,  3,  4, -3,  0,  1, -1,  0, -3, -4,  0, -3, -3, -2,  0, -1, -4, -3, -3,  4,  1, -1, -4},
{-1,  0,  0,  1, -3,  3,  4, -2,  0, -3, -3,  1, -1, -3, -1,  0, -1, -3, -2, -2,  1,  4, -1, -4},
{ 0, -1, -1, -1, -2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -2,  0,  0, -2, -1, -1, -1, -1, -1, -4},
{-4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4,  1}
};

double gettime() {
  struct timeval t;
  gettimeofday(&t,NULL);
  return t.tv_sec+t.tv_usec*1e-6;
}

////////////////////////////////////////////////////////////////////////////////
// Program main
////////////////////////////////////////////////////////////////////////////////
int
main( int argc, char** argv) 
{
    runTest( argc, argv);

    return EXIT_SUCCESS;
}

void usage(int argc, char **argv)
{
	fprintf(stderr, "Usage: %s <max_rows/max_cols> <penalty> <num_threads>\n", argv[0]);
	fprintf(stderr, "\t<dimension>      - x and y dimensions\n");
	fprintf(stderr, "\t<penalty>        - penalty(positive integer)\n");
	exit(1);
}

__global__ void top_left(int* input_itemsets, int index, int max_cols, int penalty, int i, int* referrence)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if( idx <= i)
    {
        index = (idx + 1) * max_cols + (i + 1 - idx);
        input_itemsets[index]= maximum( input_itemsets[index-1-max_cols]+ referrence[index], 
                input_itemsets[index-1]         - penalty, 
                input_itemsets[index-max_cols]  - penalty);
    }
}
__global__ void bottom_right(int* input_itemsets, int index, int max_cols, int penalty, int i, int* referrence)
{
     int idx = blockIdx.x * blockDim.x + threadIdx.x;
     if( idx <= i)
     {
	      index =  ( max_cols - idx - 2 ) * max_cols + idx + max_cols - i - 2 ;
		  input_itemsets[index]= maximum( input_itemsets[index-1-max_cols]+ referrence[index], 
			                              input_itemsets[index-1]         - penalty, 
									      input_itemsets[index-max_cols]  - penalty);

     }
}
//void* worker1(void* args)
//{
//    WorkerArgs* wargs((WorkerArgs*)args); 
//    top_left( wargs->start, wargs->end, wargs->input_itemsets, wargs->index, wargs->max_cols, wargs->penalty, wargs->i, wargs->referrence);
//    free(wargs);
//    return NULL;
//}

int blocks_per_grid(int N, int threads_per_blocks)
{
    return ((N + threads_per_blocks - 1) / threads_per_blocks);
}
////////////////////////////////////////////////////////////////////////////////
//! Run a simple test 
////////////////////////////////////////////////////////////////////////////////
void
runTest( int argc, char** argv) 
{
    int max_rows, max_cols, penalty,idx, index;
    int *input_itemsets, *output_itemsets, *referrence;
	int size;


   clock_gettime(CLOCK_REALTIME, &start_time); //Don't remove it

    
    // the lengths of the two sequences should be able to divided by 16.
	// And at current stage  max_rows needs to equal max_cols
	if (argc == 3)
	{
		max_rows = atoi(argv[1]);
		max_cols = atoi(argv[1]);
		penalty = atoi(argv[2]);
	}
    else{
		usage(argc, argv);
    }

	max_rows = max_rows + 1;
	max_cols = max_cols + 1;
    int N(max_rows * max_cols);
    size = N * sizeof(int);
	referrence = (int *)malloc( size );
    input_itemsets = (int *)malloc( size );
	output_itemsets = (int *)malloc( size );
    

	if (!input_itemsets)
		fprintf(stderr, "error: can not allocate memory");

    srand ( 7 );

    for (int i = 0 ; i < max_cols; i++){
		for (int j = 0 ; j < max_rows; j++){
			input_itemsets[i*max_cols+j] = 0;
		}
	}

	printf("Start Needleman-Wunsch\n");

	for( int i=1; i< max_rows ; i++){    //please define your own sequence. 
       input_itemsets[i*max_cols] = rand() % 10 + 1;
	}
    for( int j=1; j< max_cols ; j++){    //please define your own sequence.
       input_itemsets[j] = rand() % 10 + 1;
	}


	for (int i = 1 ; i < max_cols; i++){
		for (int j = 1 ; j < max_rows; j++){
		referrence[i*max_cols+j] = blosum62[input_itemsets[i*max_cols]][input_itemsets[j]];
		}
	}

    for( int i = 1; i< max_rows ; i++)
       input_itemsets[i*max_cols] = -i * penalty;
	for( int j = 1; j< max_cols ; j++)
       input_itemsets[j] = -j * penalty;

    //cuda memory configure start
    int* d_input_itemsets, *d_referrence;
    CudaSafeCall( cudaMalloc( &d_input_itemsets, size ) );
    CudaCheckError();
    CudaSafeCall( cudaMalloc( &d_referrence, size ) );
    CudaCheckError();
	CudaSafeCall( cudaMemcpy(d_input_itemsets, input_itemsets, size, cudaMemcpyHostToDevice) );
    CudaCheckError();
	CudaSafeCall( cudaMemcpy(d_referrence, referrence, size, cudaMemcpyHostToDevice) );
    CudaCheckError();
    int threads_per_blocks(256);
    //cuda memory configure end
	//Compute top-left matrix 
	printf("Processing top-left matrix\n");
    for( int i = 0 ; i < max_cols-2 ; i++){
        top_left<<<blocks_per_grid(i + 1, threads_per_blocks), threads_per_blocks>>>( 
                d_input_itemsets, 
                index, 
                max_cols, 
                penalty, 
                i, 
                d_referrence);
        CudaCheckError();

	}
	printf("Processing bottom-right matrix\n");
    //Compute bottom-right matrix 
	for( int i = max_cols - 4 ; i >= 0 ; i--){
        bottom_right<<<blocks_per_grid(i + 1, threads_per_blocks), threads_per_blocks>>>(
                d_input_itemsets,
                index, 
                max_cols, 
                penalty, 
                i, 
                d_referrence);
        CudaCheckError();       
	}
    //cuda memory copy back
	CudaSafeCall( cudaMemcpy(input_itemsets, d_input_itemsets, size, cudaMemcpyDeviceToHost) );
    CudaCheckError();
    //cuda memory copy back end

  clock_gettime(CLOCK_REALTIME, &end_time); //Don't remove it
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
  //

#define TRACEBACK
#ifdef TRACEBACK
	
	FILE *fpo = fopen("result.txt","w");
	fprintf(fpo, "print traceback value GPU:\n");
    
	for (int i = max_rows - 2,  j = max_rows - 2; i>=0, j>=0;){
		int nw, n, w, traceback;
		if ( i == max_rows - 2 && j == max_rows - 2 )
			fprintf(fpo, "%d ", input_itemsets[ i * max_cols + j]); //print the first element
		if ( i == 0 && j == 0 )
           break;
		if ( i > 0 && j > 0 ){
			nw = input_itemsets[(i - 1) * max_cols + j - 1];
		    w  = input_itemsets[ i * max_cols + j - 1 ];
            n  = input_itemsets[(i - 1) * max_cols + j];
		}
		else if ( i == 0 ){
		    nw = n = LIMIT;
		    w  = input_itemsets[ i * max_cols + j - 1 ];
		}
		else if ( j == 0 ){
		    nw = w = LIMIT;
            n  = input_itemsets[(i - 1) * max_cols + j];
		}
		else{
		}

		//traceback = maximum(nw, w, n);
		int new_nw, new_w, new_n;
		new_nw = nw + referrence[i * max_cols + j];
		new_w = w - penalty;
		new_n = n - penalty;
		
		traceback = maximum(new_nw, new_w, new_n);
		if(traceback == new_nw)
			traceback = nw;
		if(traceback == new_w)
			traceback = w;
		if(traceback == new_n)
            traceback = n;
			
		fprintf(fpo, "%d ", traceback);

		if(traceback == nw )
		{i--; j--; continue;}

        else if(traceback == w )
		{j--; continue;}

        else if(traceback == n )
		{i--; continue;}

		else
		;
	}
	
	fclose(fpo);

#endif

	free(referrence);
	free(input_itemsets);
	free(output_itemsets);

}



