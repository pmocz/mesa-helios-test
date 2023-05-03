
## Running

`scronjob` shows the scrontab for running the MESA test suite. This is a recurring slurm job, which replaces the previous crontab.
- Every 5 minutes, we call `launch.sh`, which logs a small amount of information about my current overall cluster usage, and then launches MESA test suite runs by calling `runMesaTest.sh`
- Once per night around 2am, we call runMesaOptional.sh, which just submits the latest commit at the head of `main` and runs all tests with the optional inlists included.

`runMesaTest.sh` is a fairly lightweight launching script that sets up the other jobs. It simply sets the relevant environment variables (see `mesa_test.sh`), fetches the latest commits, and submits installation jobs for any commit that does not yet exist in the `$MESA_LOG` directory. 

Each commit that needs to be installed gets submitted as a slurm job running `test-mesa.sh`. This does a full MESA checkout and installation, and then submits job arrays for the test suites. The array index (`$SLURM_ARRAY_TASK_ID`) tells the following scripts which entry from `do1_test_source` to run.
- `star.sh` runs an array for all the tests in `star/test_suite/do1_test_source`
- `binary.sh` runs an array for all the tests in `binary/test_suite/do1_test_source`
- `astero.sh` runs an array for all the tests in `astero/test_suite/do1_test_source`


`cleanup.sh` runs after all the test suite jobs have finished. This copies the test suite output (`*/test_suite/*/*.txt` files) into the relevant `$MESA_LOG` directories, and then deletes MESA installation for that commit.


## Initial Setup and Important Environment Variables

These scripts require that the `mesa_test` ruby gem is installed and configured to be ready to submit to MESA testhub.

`mesa_test.sh` contains several important environment variables that help the automated testing scripts run:
- `$MESA_GIT`: the location of the git mirror that the `mesa_test` gem is configured to use.
- `$MESA_LOG`: the location where output from test suite runs gets stored. Crucially, this is the location that gets checked to see if a commit has already been run, or still needs to be run.
- `$MESA_TMP`: the location that temporary MESA installations are checked out to and installed in.
