#!/bin/bash

#SBATCH -N 1
#SBATCH -c 12
#SBATCH -t 6:00:00
#SBATCH --mem 16gb
#SBATCH -J binary
#SBATCH --no-requeue
#SBATCH --exclude=helios-cn001,helios-cn004


{
echo $SLURM_JOB_NODELIST
echo $SLURM_LOCALID
echo $SLURM_NODE_ALIASES
echo $SLURM_NODEID
echo $SLURM_JOB_ID
echo $SLURMD_NODENAME
echo $MESA_DIR

#Set varaibales
cd $HOME/mesa/scripts
source $HOME/mesa/scripts/mesa_test.sh
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
#CD to folder

mkdir -p /hddstore/rfarmer
export MESA_CACHES_DIR=$(mktemp -d -p /hddstore/rfarmer)
echo $MESA_CACHES_DIR

ID=$SLURM_ARRAY_TASK_ID

folder=$(./list_tests $ID)
echo $folder $ID

mv "$folder" "$MESA_CACHES_DIR/$folder"

ln -sf "$MESA_CACHES_DIR/$folder" "$MESA_DIR/binary/test_suite/$folder"

sed -i '/mesa_dir/d' "$folder"/inlist*
sed -i '/^mesa_dir/d' "$folder/make/makefile"
sed -i '/^mesa_dir/d' "$folder/rn"

sed -i '/MESA_DIR/d' "$folder"/inlist*
sed -i '/^MESA_DIR/d' "$folder/make/makefile"
sed -i '/^MESA_DIR/d' "$folder/rn"


~/bin/mesa_test test_one $MESA_DIR $ID --force --auto-diff -m=binary

cp "$MESA_DIR/binary/test_suite/$folder/out.txt" "$OUT_FOLD/$folder".txt

rm -rf $MESA_CACHES_DIR
}
