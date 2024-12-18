#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <sys/time.h>

#define SIZE 128
#define BLOCK_SIZE 128

double get_clock(){
        struct timeval tv;
        int ok = gettimeofday(&tv, (void *) 0);
                if (ok<0){
                        printf("gettimeofday error");
                }
                return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
        }

__global__ void scan (int * input, int * output){
        int gIndex = threadIdx.x + blockIdx.x * blockDim.x;

        if(gIndex >= SIZE){ // invalid array index
                return;
        }

        int * start;
        int * end;

        start = &input[0];
        end = &output[0];

        int* temp;

        for (int j=1; j <= SIZE; j*=2){ //add value at j to previous value
                __syncthreads();
                if(gIndex < j){
                        end[gIndex] = start[gIndex];
                }
                else{
                        end[gIndex] = input[gIndex] + start[gIndex-1];
                }

                temp = end;
                end = start;
                start = temp;
        }
        output[gIndex] = start[gIndex];
}
int main(void){
        double t0 = get_clock();

        int *input;
        int * output;
        int x;

        cudaMallocManaged(&input, SIZE*sizeof(int));
        cudaMallocManaged(&output, SIZE*sizeof(int));

        for(int i=0; i < SIZE; i++){
                input[i] = 1;
        }

        //number of blocks needed
        if (SIZE%BLOCK_SIZE == 0){
                x = SIZE/BLOCK_SIZE;
        }
        else {
                x = SIZE/BLOCK_SIZE + 1;
        }
        printf("Number of blocks: %d\n", x);

        //launch kernal
        scan<<<x, BLOCK_SIZE>>>(input, output);
        cudaDeviceSynchronize();

        # for(int i = 0; i<SIZE; i++){
        #       printf("%d ", output[i]);
        # }
        # printf("\n");

        // print our error
        printf("%s\n", cudaGetErrorString(cudaGetLastError()));

        //free memory
        cudaFree(input);
        cudaFree(output);

        double t1 = get_clock();
        printf("time per call %f s\n", (t1-t0));

        return 0;
}
