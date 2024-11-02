export MESA_GIT=/mnt/home/pmocz/.mesa_test/mirror # Where mesa-git is
export MESA_LOG=/mnt/home/pmocz/ceph/testhub # Where to log output to
export MESA_TMP=/mnt/home/pmocz/ceph/mesa-git-tests # Where to checkout each MESA to
export MESA_SCRIPTS=~/mesa-helios-test # Where this script sits

export OMP_NUM_THREADS=64
export MESASDK_ROOT=/mnt/home/pmocz/Projects/Mesa/mesasdk
#export MESA_CLUSTER=~/mesa-test
#export GYRE_DIR=$MESA_DIR/gyre/gyre
source $MESASDK_ROOT/bin/mesasdk_init.sh
#export LD_LIBRARY_PATH=$MESA_DIR/lib:$LD_LIBRARY_PATH
#export MESA_SCRIPT=$MESA_ROOT/scripts
#export SDK=1

export MESA_GIT_LFS_SLEEP=60
