#!/bin/bash
#BSUB -J mgpu04 # name
#BSUB -o outfiles/mgpu04_%J.out # output file
#BSUB -q gpuh100
#BSUB -n 64 ## cores
#BSUB -R "rusage[mem=1GB]" 
#BSUB -W 1:30 # useable time in minutes
##BSUB -N # send mail when done
#BSUB -R "span[ptile=32]"
#BSUB -gpu "num=2:mode=exclusive_process"

ITER=1000
TOLERANCE=-1
START_T=5

## lscpu

ARCH=`uname -m`

module load gcc

module load cuda/12.2.2

module load mpi/5.0.2-gcc-12.3.0-binutils-2.40

module load nccl/2.19.3-1-cuda-12.2.2 

echo "Running on gpuh100"

FOLDER="../results/mgpu"
EXECUTEFOLDER="../implementation/execute/"

FILE_NO_REDUCTION=$FOLDER/no_reduction/result04.txt
## FILE_NO_REDUCTION_ASYN=$FOLDER/no_reduction_asyn/result04.txt
FILE_REDUCTION=$FOLDER/reduction/result04.txt

rm -rf $FILE_NO_REDUCTION
rm -rf $FILE_REDUCTION
## rm -rf $FILE_NO_REDUCTION_ASYN

##for N in {10..500..10} {520..600..20} {630..690..30};
##for N in {10..90..10} {100..200..25} {250..1250..50};
for N in {10..90..10} {100..200..25} {250..1250..50};
do

    NCCL_SOCKET_NTHREADS=32 mpirun -npernode 1 ./${EXECUTEFOLDER}mgpu_no_reduction $N $ITER $TOLERANCE $START_T >> $FILE_NO_REDUCTION
    ## NCCL_SOCKET_NTHREADS=16 mpirun -npernode 2 ./${EXECUTEFOLDER}mgpu_no_reduction_asyn $N $ITER $TOLERANCE $START_T >> $FILE_NO_REDUCTION_ASYN
    NCCL_SOCKET_NTHREADS=32 mpirun -npernode 1 ./${EXECUTEFOLDER}mgpu_reduction $N $ITER $TOLERANCE $START_T >> $FILE_REDUCTION

done

exit 0

