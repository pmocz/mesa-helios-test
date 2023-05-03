#!/bin/bash

#SBATCH --job-name=star
#SBATCH --nodes=1
#SBATCH --export=ALL
#SBATCH --mail-type=FAIL
#SBATCH --requeue

clean_caches

if [ -n "${USE_MESA_TEST}" ]; then
    mesa_test test ${SLURM_ARRAY_TASK_ID} --module=star ${MESA_TEST_OPTIONS}
    echo "MESA_TEST_SUITE_RESOLUTION_FACTOR"
    echo $MESA_TEST_SUITE_RESOLUTION_FACTOR
else
    cd ${MESA_DIR}/star/test_suite
    ./each_test_run ${SLURM_ARRAY_TASK_ID}
fi
