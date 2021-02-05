#!/bin/bash

#SBATCH --job-name=cleanup
#SBATCH --nodes=1
#SBATCH --export=ALL
#SBATCH --time=0:20:00
#SBATCH --mail-type=FAIL

# wait a bit for final jobs to finish. there seems to be a race
# condition where the output from the last job to finish isn't on disk
# at the time the cleanup script is executed
sleep 30

cd ${MESA_DIR}
rm -r star/test_suite/*/*LOGS*
rm -r star/test_suite/*/*photo*
rm star/test_suite/*/star
rm star/test_suite/*/*.mod

rm -r binary/test_suite/*/*LOGS*
rm -r binary/test_suite/*/*photo*
rm binary/test_suite/*/binary
rm binary/test_suite/*/*.mod

rm -r astero/test_suite/*/*LOGS*
rm -r astero/test_suite/*/*photo*
rm astero/test_suite/*/star
rm astero/test_suite/*/*.mod

cp --parents star/test_suite/*/*.txt ${OUT_FOLD}
cp --parents binary/test_suite/*/*.txt ${OUT_FOLD}
cp --parents astero/test_suite/*/*.txt ${OUT_FOLD}

cp --parents star/test_suite/*/png/*png ${OUT_FOLD}

echo "test results copied to storage, removing MESA_DIR"

rm -rf $MESA_DIR

echo "MESA_DIR has been removed from scratch, cleanup complete"
