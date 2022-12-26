#!/bin/bash

. SetEnvironment.sh FANOCI

for i in `seq 1 9`;do
   stieltjes < fort.100$i
   if [[ $? -eq 0 ]];then
      mv gamma.sh2.dat gamma.sh2.dat.$i
   fi
done

for i in `seq 10 16`;do
   stieltjes < fort.10$i
   if [[ $? -eq 0 ]];then
      mv gamma.sh2.dat gamma.sh2.dat.$i
   fi
done
