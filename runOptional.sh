#!/bin/bash

# Dont let script run more than once
if [[ $(pgrep -c "`basename $0`") -gt 1 ]]; then
    echo "Process already running"
    exit 1
fi

source ~/.bashrc
which ruby
which mesa_test
gfortran --version
env

{
echo "**********************"
echo $(date)
#cd ~/mesa/scripts

cd ~/mesa-helios-test
pwd

source mesa_test.sh

module load git

cd "$MESA_GIT" || exit

if [[ $? != 0 ]];then
	echo "Update failed"
	exit 1
fi

# find the latest commit on main
i=$(git log -1 --remotes=*main --format="%h")
export OUT_FOLD=$MESA_LOG/optional_$i
echo $OUT_FOLD

if [ -d $OUT_FOLD ]; then
    echo "Skipping optional_$i"
    exit 0
else
    echo "Submitting optional_$i" 
    mkdir -p "$OUT_FOLD"
fi

sbatch -o "$OUT_FOLD"/build.txt --export=VERSION=$i,HOME=$HOME,OUT_FOLD="$OUT_FOLD" "${MESA_SCRIPTS}/test-optional.sh"

date
echo "**********************"
} 2>&1 | tee -a ~/log_mesa_optional.txt
