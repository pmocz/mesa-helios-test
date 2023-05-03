export MESA_GIT=$DATA_DIR/github_mesa/.mesa_test/mirror # Where mesa-git is
#export MESA_GIT=$CONROY_SCRATCH/ebauer/mesa-git-tests/mesa_test/mirror # Where mesa-git is
export MESA_LOG=$DATA_DIR/testhub # Where to log output to
export MESA_TMP=$CONROY_SCRATCH/ebauer/mesa-git-tests # Where to checkout each MESA to
export MESA_SCRIPTS=~/mesa-helios-test # Where this script sits

export OMP_NUM_THREADS=8
export MESASDK_ROOT=$DATA_DIR/mesasdks/mesasdk-20.3.2
#export MESASDK_ROOT=$CONROY_SCRATCH/ebauer/mesa-git-tests/mesa_test/mesasdk
export MESA_CLUSTER=~/mesa-test
#export GYRE_DIR=$MESA_DIR/gyre/gyre
source $MESASDK_ROOT/bin/mesasdk_init.sh
#export LD_LIBRARY_PATH=$MESA_DIR/lib:$LD_LIBRARY_PATH
#export MESA_SCRIPT=$MESA_ROOT/scripts
export SDK=1

export MESA_GIT_LFS_SLEEP=60
