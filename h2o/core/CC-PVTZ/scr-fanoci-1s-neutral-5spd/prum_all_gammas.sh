#!/bin/bash

echo "Gamma Std"
for i in `seq 1 16`;do
   if [[ -f gamma.sh2.dat.$i ]];then
      prum_stieltjes.sh 15 22 gamma.sh2.dat.$i | grep -A1 "Average \[meV\]" | tail -1
   else
      echo "0 0"
   fi
done
