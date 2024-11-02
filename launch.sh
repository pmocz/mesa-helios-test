#!/bin/bash

source .bashrc
cd mesa-helios-test

env

which ruby
which mesa_test
gfortran --version

date --rfc-3339='seconds' | tr -d '\n' >> $HOME/track_share.txt
sshare | grep pmocz >> $HOME/track_share.txt
./runMesaTest.sh
