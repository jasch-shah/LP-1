#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include<bits/stdc++.h>
#include <iostream>
#include <numeric>

using namespace std;

#define BLOCK_SIZE 4

__global__ void avg(int* input)				// kernel function definition
{
	const int tid = threadIdx.x;
	int avg=0;
	int index=0;
	int step_size = 1;
	int number_of_threads = blockDim.x;		// blockDim = 4 i.e. number of threads per block = 4
	

	while (number_of_threads > 0)
	{
		if (tid < number_of_threads) // still alive?
		{     
			const int fst = tid * step_size * 2;		//get the index in array
			const int snd = fst + step_size;			//get the index in array
			input[fst] += input[snd];
			avg =input[fst];
			index=fst;
			
			//input[fst]=input[fst]/2;
			
		}

		step_size <<= 1; 			// increment step_size by 1
		number_of_threads >>= 1;	//decrement number of threads by 2
	}
	input[index]=avg/7;				// calculate average
}

int main()
{
	const int count = 8 ;
	
	
	const int size = count * sizeof(int);
	
	
	int h[] = {13, 27, 15, 14, 33, 2, 24};

	int* d;						//GPU parameter
       	
	cudaMalloc(&d, size);		//assign memory to parameters on GPU
	
	cudaMemcpy(d, h, size, cudaMemcpyHostToDevice);		//copy the array from CPU to GPU
	avg <<<1, count / 2 >>>(d);							// call kernel function <<<number of blocks, number of threads= number of elements/2
	
	int result;
	
	cudaMemcpy(&result, d, sizeof(int), cudaMemcpyDeviceToHost);		// copy the result back from GPU to CPU

	cout << "Avg is " << result << endl;

	getchar();

	cudaFree(d);		// Free the allocated memory
	delete[] h;

	return 0;
}
