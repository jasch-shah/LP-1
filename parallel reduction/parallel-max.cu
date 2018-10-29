#include <stdio.h>
#include <string.h>
#include <stdlib.h> // for rand()
#include <errno.h>

#include <cuda_runtime_api.h>
#include <math_constants.h>

#define N 2*2*2

/* host buffer */
float *data;
/* device buffers */
float *dSrc, *dDst;

void check_error(cudaError error, const char *message) {
    if (error != cudaSuccess) {
        fprintf(stderr, "%s (%s)\n", message,
            cudaGetErrorString(error));
        if (dSrc)
            cudaFree(dSrc);
        if (dDst)
            cudaFree(dDst);
        exit(1);
    }
}

#define WARP_SIZE 32
#define BLOCK_SIZE (12*WARP_SIZE)

__global__ void findmax(float *dDst, const float *dSrc, uint dim)
{
    __shared__ float cache[BLOCK_SIZE];					//cache is shared array between the block of threads

    uint gix = threadIdx.x + blockDim.x*blockIdx.x;

#define tid threadIdx.x

    float acc = CUDART_NAN_F;		//acc is initialized to certain random floating point value

    while (gix < dim) {				//this code executed by each thread
        acc = fmax(acc, dSrc[gix]);
        gix += blockDim.x*gridDim.x;
    }

    cache[tid] = acc;				//each thread keeps its result in cache index

    uint active = blockDim.x >> 1;	//active is incremented by 1

    do {
        __syncthreads();			// guarantee that all threads are in the same iteration of the do- while loop at the same time
        if (tid < active)
            cache[tid] = fmax(cache[tid], cache[tid+active]);			//calculate final result by comparing the values kept by each thread in cache
        active >>= 1;
    } while (active > 0);

    if (tid == 0)					//executed by parent thread
        dDst[blockIdx.x] = cache[0];
}

int main(int argc, char **argv) {
    data = (float*) calloc(N, sizeof(float));
    size_t data_size = N * sizeof(float);				// Here, N = 8
    float max = nan(""), d_max = nan("");				// returns a value of type double

    for (size_t i = 0; i < N; ++i) {
        data[i] = i; 									// input array
        max = fmax(max, data[i]);						// calculate max value sequentially
    }
    printf("%u elements generated, max %g, data size %zu (%zuMB)\n",
            N, max, data_size, data_size>>20);

    cudaError_t err;

    err = cudaMalloc(&dSrc, data_size);
    check_error(err, "allocating array");

    err = cudaMemcpy(dSrc, data, data_size, cudaMemcpyHostToDevice);		// copy array to device
    check_error(err, "copy UP");

    uint nblocks = 8;

    err = cudaMalloc(&dDst, nblocks*sizeof(*dDst));
    check_error(err, "allocating Dst array");

    cudaEvent_t start, stop;
    float runtime;
    cudaEventCreate(&start);				//Creates an event object for the current device
    cudaEventCreate(&stop);					//Creates an event object for the current device

    cudaEventRecord(start, 0);				// records an event. first parameter: event object, second parameter:stream in which to record the event, if value is zero, records the event after all preceding operations are completed
    findmax<<<nblocks,BLOCK_SIZE>>>(dDst, dSrc, N);		//call kernel function
    findmax<<<1,BLOCK_SIZE>>>(dDst, dDst, nblocks);
    cudaEventRecord(stop, 0);

    cudaEventSynchronize(stop);				//Wait until the completion of all device work preceding the most recent call to cudaEventRecord()
    cudaEventElapsedTime(&runtime, start, stop);		//Computes the elapsed time between two events and stores in first parameter

    /* Giga-elements per second */
    printf("%u elements processed in %gms: %gGE/s\n",
        N, runtime, (N/runtime)/(1000000));

    /* Actual bandwith in GB/s */
    uint total_els = N + nblocks;
    float sizeMB = float(total_els)*sizeof(float)/(1024*1024);
    printf("Bandwidth: %u elements (%gMB) read in two steps. "
        "Runtime: %gms (%gGB/s)\n",
        total_els, sizeMB, runtime, sizeMB/runtime);

    err = cudaMemcpy(&d_max, dDst, sizeof(d_max), cudaMemcpyDeviceToHost);		//copy the result back to host
    check_error(err, "copy DOWN");

    cudaFree(dSrc); dSrc = NULL;
    cudaFree(dDst); dDst = NULL;
    free(data);

    printf("Parallel max: %g vs %g\n", d_max, max);
}

