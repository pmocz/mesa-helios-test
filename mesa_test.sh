

export OMP_NUM_THREADS=8
export MESASDK_ROOT=$DATA_DIR/mesasdks/mesasdk-20.3.2
export MESA_CLUSTER=~/mesa-test
#export GYRE_DIR=$MESA_DIR/gyre/gyre
source $MESASDK_ROOT/bin/mesasdk_init.sh
#export LD_LIBRARY_PATH=$MESA_DIR/lib:$LD_LIBRARY_PATH
#export MESA_SCRIPT=$MESA_ROOT/scripts
export SDK=1

#export OP_MONO_BASE=~/mesa/mesa
#export MESA_OP_MONO_DATA_PATH=$OP_MONO_BASE/OP4STARS_1.3/mono
#export MESA_OP_MONO_DATA_CACHE_FILENAME=$OP_MONO_BASE/OP4STARS_1.3/mono/op_mono_cache.bin
