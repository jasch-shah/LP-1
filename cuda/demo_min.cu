#include <cuda.h>
    #include <stdio.h>
    #include <time.h>

   // #define SIZE 1000
#define SIZE 10

    __global__ void max(int *a , int *c)	// kernel function definition
    {
    int i = threadIdx.x;					// initialize i to thread ID

    *c = a[0];

            if(a[i] < *c)
                    {
                    *c = a[i];
                    }

    }

    int main()
    {
    int i;
    srand(time(NULL));		//makes use of the computer's internal clock to control the choice of the seed

    int a[SIZE]={12,4,7,3,9,5,11,6,1,76};
    int c;

    int *dev_a, *dev_c;		//GPU / device parameters

    cudaMalloc((void **) &dev_a, SIZE*sizeof(int));		//assign memory to parameters on GPU from CUDA runtime API
    cudaMalloc((void **) &dev_c, SIZE*sizeof(int));

   // for( i = 0 ; i < SIZE ; i++)
    //{
    	//a[i] = i;			// input the numbers
   // }
    
    cudaMemcpy(dev_a , a, SIZE*sizeof(int),cudaMemcpyHostToDevice);		//copy the array from CPU to GPU
    max<<<1,SIZE>>>(dev_a,dev_c);										// call kernel function <<<number of blocks, number of threads
    cudaMemcpy(&c, dev_c, SIZE*sizeof(int),cudaMemcpyDeviceToHost);		// copy the result back from GPU to CPU

    printf("\nmin =  %d ",c);

    cudaFree(dev_a);		// Free the allocated memory
    cudaFree(dev_c);
    printf("");

    return 0;
    }                                                  
