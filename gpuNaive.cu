#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <sys/time.h>

#define SIZE 128
#define BLOCK_SIZE 128

double get_clock(){
        struct timeval tv;
        int ok = gettimeofday(&tv, (void *) 0);
        if (ok < 0){
                printf("gettimeofday error");
        }
        return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
}

__global__ void scan(int* input, int* output){
        int gIndex = threadIdx.x + blockIdx.x * blockDim.x;

        if (gIndex >= SIZE){ // stop when there's no correspondng index value in the array
                return;
        }

        for (int i = 0; i<SIZE; i++){
                int value = 0;
                for (int j = 0; j <= i; j++){
                        value += input[j];
                }
                output[i] = value;
        }

        __syncthreads();

}
int main(void ){
        double t0 = get_clock();

        int *input;
        int *output;
        int x;
        cudaMallocManaged(&input, SIZE*sizeof(int));
        cudaMallocManaged(&output, SIZE*sizeof(int));

        for(int i = 0; i < SIZE; i++){
                input[i] = 1;
        }

        // determine number of blocks
        if (SIZE % BLOCK_SIZE == 0){
                x = SIZE/BLOCK_SIZE;
        }
        else{
                x = (SIZE/BLOCK_SIZE) + 1;
        }

        //launch kernal
        scan<<<x, BLOCK_SIZE>>>(input, output);

        cudaDeviceSynchronize();

        for (int i = 0; i <SIZE; i++){
                printf("%d ", output[i]);
        }

        cudaFree(input);
        cudaFree(output);

        double t1 = get_clock();
        printf("time per call: %f s\n", (t1-t0));

        return 0;

}
