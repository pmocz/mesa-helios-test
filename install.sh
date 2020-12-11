#!/bin/bash

#SBATCH --job-name=install
#SBATCH --nodes=1
#SBATCH --export=ALL
#SBATCH --time=1:00:00
#SBATCH --mail-type=FAIL
#SBATCH --requeue

echo $PATH
gfortran --version
export OMP_NUM_THREADS=4

clean_caches

# build MESA
cd ${MESA_DIR}
./clean
./install

# nevermind, this won't work when no jobs have been run
#mesa_test submit_revision "$MESA_DIR" --force
