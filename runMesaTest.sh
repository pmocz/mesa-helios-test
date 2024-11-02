#!/bin/bash

# Dont let script run more than once
if [[ $(pgrep -c "`basename $0`") -gt 1 ]]; then
    echo "Process already running"
    exit 1
fi

{
echo "**********************"
echo $(date)
#cd ~/mesa/scripts
pwd

source ~/.bashrc
source mesa_test.sh

module load git
#spack load git-lfs # also loads a new git

cd "$MESA_GIT" || exit

# Get all updates over all branches
git fetch --all

if [[ $? != 0 ]];then
	echo "Update failed"
	exit 1
fi

last_ver=-1
# Loop over recent commits, do both time and number to catch when things go wrong
for i in $(git log --since="10 minutes" --all --format="%h") $(git log -15 --all --format="%h");
do
	export OUT_FOLD=$MESA_LOG/$i

	if [ -d $OUT_FOLD ]; then
		echo "Skipping $i"
		continue
	else
		echo "Submitting $i" 
		mkdir -p "$OUT_FOLD"
	fi

	if [[ $last_ver -lt 0 ]]; then
		last_ver=$(sbatch -o "$OUT_FOLD"/build.txt --parsable --export=VERSION=$i,HOME=$HOME,OUT_FOLD="$OUT_FOLD" "${MESA_SCRIPTS}/test-mesa.sh")
	else
		last_ver=$(sbatch -o "$OUT_FOLD"/build.txt --dependency=afterany:$last_ver --parsable --export=VERSION=$i,HOME=$HOME,OUT_FOLD="$OUT_FOLD" "${MESA_SCRIPTS}/test-mesa.sh")
	fi
	echo $last_ver

done
date
echo "**********************"
} 2>&1 | tee -a ~/log_mesa_test.txt
