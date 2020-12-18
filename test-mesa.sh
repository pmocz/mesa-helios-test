#!/bin/bash

#SBATCH -n 1
#SBATCH -N 1
#SBATCH -t 00:30:00
#SBATCH -p conroy,test,itc_cluster,shared
#SBATCH --constraint="intel"
#SBATCH --mem=4G


set -euxo pipefail

# set email address for SLURM and for cleanup output
export MY_EMAIL_ADDRESS=evan.bauer.astro@gmail.com

# set how many threads; this will also be sent to SLURM as --ntasks-per-node
export OMP_NUM_THREADS=8

# set SLURM options (used for all sbatch calls)
export INSTALL_OPTIONS="--partition=conroy --constraint=intel --mem=8000 --ntasks-per-node=8"
#export INSTALL_OPTIONS="--partition=shared,itc_cluster --mem=8000 --ntasks-per-node=4"
#export INSTALL_OPTIONS="--partition=test --mem=8000 --ntasks-per-node=${OMP_NUM_THREADS}"
#export MY_SLURM_OPTIONS="--partition=conroy,shared --constraint=intel --mem=16000"
export MY_SLURM_OPTIONS="--partition=conroy --constraint=intel --mem=16000"
#export MY_SLURM_OPTIONS="--partition=serial_requeue --mem=16000"
#export MY_SLURM_OPTIONS="--partition=shared --mem=16000"


# set other relevant MESA options
#export MESA_RUN_OPTIONAL=t
#export MESA_FPE_CHECKS_ON=1


# set paths for OP opacities
#export MESA_OP_MONO_DATA_PATH=${DATA_DIR}/OP4STARS_1.3/mono
#export MESA_OP_MONO_DATA_CACHE_FILENAME=${DATA_DIR}/OP4STARS_1.3/mono/op_mono_cache.bin
#rm -f ${MESA_OP_MONO_DATA_CACHE_FILENAME}

# set non-default cache directory (will be cleaned up on each run)
#export MESA_CACHES_DIR=/tmp/mesa-cache


# set MESA_DIR
# export MESA_DIR=

# if USE_MESA_TEST is set, use mesa_test gem; pick its options via MESA_TEST_OPTIONS
# otherwise, use built-in each_test_run script
export USE_MESA_TEST=t
export MESA_TEST_OPTIONS="--force" # --no-submit"

export MESA_DIR=${CONROY_SCRATCH}/ebauer/mesa-svn$VIN
export USE_MESA_TEST=t


# if directory is already being tested, exit
if [ -e ${MESA_DIR}/.testing ]; then
    echo "Tests are in-progress"
    exit 1
fi

svn co -r "$VIN" file://${DATA_DIR}/assembla_mesa/trunk ${MESA_DIR}
if [ $? -ne 0 ]
then
    echo "Failed to checkout SVN"
    exit 1
fi

# extract the "true" svn version
(
    cd ${MESA_DIR}
    svnversion > test.version
)


# function to clean caches; executed at start of each job
clean_caches(){
    # clean up cache dir if needed
    if [ -n "${MESA_CACHES_DIR}" ]; then
        rm -rf ${MESA_CACHES_DIR}
        mkdir -p ${MESA_CACHES_DIR}
    fi
}

export -f clean_caches

# mark directory as being tested
touch ${MESA_DIR}/.testing

# submit job to install MESA
export INSTALL_JOBID=$(sbatch --parsable \
                              --output="${OUT_FOLD}/install.log" \
                              --mail-user=${MY_EMAIL_ADDRESS} \
                              ${INSTALL_OPTIONS} \
                              install.sh)


# if ci skip, then only run the first star test, cleanup, and exit
if [[ $(svn log -r "$VIN" file://${DATA_DIR}/assembla_mesa/trunk) == *'[ci skip]'* ]];then
        # run just the first star test
	export STAR_JOBID=$(sbatch --parsable \
                                   --ntasks-per-node=${OMP_NUM_THREADS} \
                                   --array=1-1 \
                                   --output="${OUT_FOLD}/star.log-%a" \
                                   --dependency=afterok:${INSTALL_JOBID} \
                                   --mail-user=${MY_EMAIL_ADDRESS} \
                                   ${MY_SLURM_OPTIONS} \
                                   star.sh)

	sbatch --output="${OUT_FOLD}/cleanup.log" \
	       --dependency=afterany:${STAR_JOBID} \
	       ${MY_SLURM_OPTIONS} \
	       cleanup.sh

	exit 0
fi

# submit job to report build error
# sbatch error.sh -W depend=afternotok:${INSTALL_JOBID}

# run the star test suite
# this is part is parallelized, so get the number of tests
cd ${MESA_DIR}/star/test_suite
export NTESTS=$(./count_tests)
cd -

export STAR_JOBID=$(sbatch --parsable \
                           --ntasks-per-node=${OMP_NUM_THREADS} \
                           --array=1-${NTESTS} \
                           --output="${OUT_FOLD}/star.log-%a" \
                           --dependency=afterok:${INSTALL_JOBID} \
                           --mail-user=${MY_EMAIL_ADDRESS} \
                           ${MY_SLURM_OPTIONS} \
                           star.sh)


# run the binary test suite
# this is part is parallelized, so get the number of tests
cd ${MESA_DIR}/binary/test_suite
export NTESTS=$(./count_tests)
cd -

export BINARY_JOBID=$(sbatch --parsable \
                             --ntasks-per-node=${OMP_NUM_THREADS} \
                             --array=1-${NTESTS} \
                             --output="${OUT_FOLD}/binary.log-%a" \
                             --dependency=afterok:${INSTALL_JOBID}\
                             --mail-user=${MY_EMAIL_ADDRESS} \
                             ${MY_SLURM_OPTIONS} \
                             binary.sh)


# run the astero test suite
# this is part is parallelized, so get the number of tests
cd ${MESA_DIR}/astero/test_suite
export NTESTS=$(./count_tests)
cd -

export ASTERO_JOBID=$(sbatch --parsable \
                             --ntasks-per-node=${OMP_NUM_THREADS} \
                             --array=1-${NTESTS} \
                             --output="${OUT_FOLD}/astero.log-%a" \
                             --dependency=afterok:${INSTALL_JOBID}\
                             --mail-user=${MY_EMAIL_ADDRESS} \
                             ${MY_SLURM_OPTIONS} \
                             astero.sh)


sbatch --output="${OUT_FOLD}/cleanup.log" \
       --dependency=afterany:${STAR_JOBID},afterany:${BINARY_JOBID},afterany:${ASTERO_JOBID} \
       ${MY_SLURM_OPTIONS} \
       cleanup.sh

