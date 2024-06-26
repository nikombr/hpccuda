#include <math.h>
#include <stdio.h>
#include <omp.h>
#include <cuda_runtime_api.h>

__global__ void iteration_inner(double *** u, double *** uold, double *** f, int N, double *res, double delta2, double frac) {
    double val = 0;
    int k = threadIdx.x + blockIdx.x * blockDim.x + 1;
    int j = threadIdx.y + blockIdx.y * blockDim.y + 1;
    int i = threadIdx.z + blockIdx.z * blockDim.z + 1;
    if ((i < N + 1) && (j < N + 1) && (k < N + 1)) {
        u[i][j][k] = frac*(uold[i-1][j][k] + uold[i+1][j][k] + uold[i][j-1][k] + uold[i][j+1][k] \
                        + uold[i][j][k+1] + uold[i][j][k-1] + delta2*f[i][j][k]);
        val = u[i][j][k] - uold[i][j][k];
    }

    double reg = val*val;
    atomicAdd(res,reg);
    
}

__global__ void init_zero(double *res) {
    *res = 0.0;
}

void iteration(double *** u, double *** uold, double *** f, int N, double *sum) {
    init_zero<<<1, 1>>>(sum);
    cudaDeviceSynchronize();
    double delta = 2.0/(N+1), delta2 = delta*delta, frac = 1.0/6.0;
    // Blocks and threads
    dim3 dimBlock(32,4,2);
    dim3 dimGrid((N+dimBlock.x-1)/dimBlock.x,(N+dimBlock.y-1)/dimBlock.y,(N+dimBlock.z-1)/dimBlock.z);

    // Do iteration
    iteration_inner<<<dimGrid, dimBlock>>>(u, uold, f, N, sum, delta2, frac);
    cudaDeviceSynchronize();
}