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

# get MESA version
cd ${MESA_DIR}
VERSION_DATA=$(<data/version_number)
VERSION_VC=$(<test.version)

# make version string "real (reported)"
VERSION="${VERSION_VC} (${VERSION_DATA})"

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

cp -r star/test_suite ${OUT_FOLD}/star_test_suite
cp -r binary/test_suite ${OUT_FOLD}/binary_test_suite
cp -r astero/test_suite ${OUT_FOLD}/astero_test_suite

echo "test results copied to storage, removing MESA_DIR"

rm -rf $MESA_DIR

echo "MESA_DIR has been removed from scratch, cleanup complete"
