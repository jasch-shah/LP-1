#include <stdio.h>
#include <stdlib.h>
#include <math.h>
 
// CUDA kernel. Each thread takes care of one element of c
__global__ void vecAdd(int *a, int *c, int n)
{
    // Get our global thread ID
    int id = blockIdx.x*blockDim.x+threadIdx.x;
   // c[id]=0;
    // Make sure we do not go out of bounds
    if (id < n)
        *c+= a[id];
   // printf("\n%d", c[id]);
}
 
int main( int argc, char* argv[] )
{
    // Size of vectors
    // int n = 100000;
	int n=5;
 const int size = n * sizeof(int);  
    // Host input vectors
    int *h_a;
   // double *h_b;
    //Host output vector
    int *h_c;
 
    // Device input vectors
    int *d_a;
    //double *d_b;
    //Device output vector
    int *d_c;
    int dev=0;
    // Size, in bytes, of each vector
    size_t bytes = n*sizeof(double);
 
    // Allocate memory for each vector on host
    //h_a = (int*)malloc(bytes);
    //h_b = (double*)malloc(bytes);
    h_c = (int*)malloc(bytes);
 
    // Allocate memory for each vector on GPU
    cudaMalloc(&d_a, bytes);
   // cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);
 
    int i;
    printf("Input array");
    // Initialize vectors on host
    /*for( i = 0; i < n; i++ ) {
        // h_a[i] = sin(i)*sin(i);
        //printf("\n",i); 
	h_a[i]=i;
	//printf("\n%d", h_a[i]);
	//h_b[i]=i;
        //h_b[i] = cos(i)*cos(i);
    }*/
   
   int a[]= {0, 1, 2, 3, 4};
   
   cudaMalloc(&h_a, size);
 
    // Copy host vectors to device
    cudaMemcpy( h_a, a, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy( d_c, &dev, sizeof(int), cudaMemcpyHostToDevice);
//    cudaMemcpy( d_b, h_b, bytes, cudaMemcpyHostToDevice);
 
    int blockSize, gridSize;
 
    // Number of threads in each thread block
    blockSize = 2;
 
    // Number of thread blocks in grid
    gridSize = (int)ceil((float)n/blockSize);
 
    // Execute the kernel
    vecAdd<<<gridSize, blockSize>>>(d_a,d_c,n);
      int result;
    // Copy array back to host
    cudaMemcpy( &result,d_c, sizeof(int), cudaMemcpyDeviceToHost );
 
    // Sum up vector c and print result divided by n, this should equal 1 within error
    double sum = 0;
    //for(i=0; i<n; i++)
      //  sum += h_c[i];
     
    printf("final result: %f\n",result );

   // vecdev<<<gridSize, blockSize>>>(d_a,d_c, n);
 
    // Release device memory
    cudaFree(d_a);
    //cudaFree(d_b);
    cudaFree(d_c);
 
    // Release host memory
    free(h_a);
    //free(h_b);
    free(h_c);
 
    return 0;
}
