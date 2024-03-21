#!/bin/bash
#BSUB -J cpu # name
#BSUB -o outfiles/close_%J.out # output file
#BSUB -q gpuh100
#BSUB -n 32 ## cores
#BSUB -R "rusage[mem=1GB]" 
#BSUB -W 60 # useable time in minutes
##BSUB -N # send mail when done
#BSUB -R "span[hosts=1]"

ITER=2000
TOLERANCE=-1
START_T=5

## lscpu

for N in {50..200..50};
do
    FOLDER="../results/gpu/gpush"
    FILE_REDUCTION=$FOLDER/reduction_$N.txt
    FILE_NO_REDUCTION=$FOLDER/no_reduction_$N.txt

    rm -rf $FILE_REDUCTION
    rm -rf $FILE_NO_REDUCTION

    echo -n $threads " " >> $FILE_REDUCTION
    echo -n $threads " " >> $FILE_NO_REDUCTION
    # #./jacobi_reduction $N $ITER $TOLERANCE $START_T >> $FILE_REDUCTION
    ./jacobi_no_reduction $N $ITER $TOLERANCE $START_T >> $FILE_NO_REDUCTION


done
exit 0

