#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define SIZE 128

double get_clock() {
        struct timeval tv;
        int ok;
        ok = gettimeofday(&tv, (void *) 0);
        if (ok<0) {
                printf("gettimeofday error");
        }
        return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
}

int main() {
        double t0 = get_clock();


        // allocate memory
        int* input = malloc(sizeof(int) * SIZE);
        int* output = malloc(sizeof(int) * SIZE);

        // initialize inputs
        srand(123);
        for (int i = 0; i < SIZE; i++) {
        input[i] = rand() % 100;
        }

        // do the scan
        for (int i = 0; i < SIZE; i++) {
        int value = 0;
        for (int j = 0; j <= i; j++) {
        value += input[j]; // prefix sum
        }
    output[i] = value;
        }

        // check results
        for (int i = 0; i < SIZE; i++) {
        printf("%d ", output[i]);
        }
        printf("\n");

        // free mem
        free(input);
        free(output);

        double t1 = get_clock();
        printf("time per call: %f s\n", ((t1-t0)) );

        return 0;
}
