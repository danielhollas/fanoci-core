#!/bin/bash

# BASH function definitions for extracting excitation energies
# and transition dipole moments from TeraChem output files.

# Available public functions are:
# grep_TERA_TDDFT
# grep_TERA_ioniz
# grep_TERA_ioniz_exc

function grep_TERA_TDDFT {
   local in=$1
   local numstates=$3
   local out=$2
   local nstate1

   let nstate1=numstates+1

   checkTERA $in
   if [[ "$?" -ne "0" ]];then
      return 1
   fi

   grep -A$nstate1 -e 'Ex. Energy (eV)   Osc. (a.u.)' -e 'Root       Tx         Ty         Tz' $in |\
   awk 'BEGIN{i=1;k=1}{
	if($1 ~ /[0-9]+/ && NF==5){ 
		dx[k]=$2
		dy[k]=$3
		dz[k]=$4
		k++
	} 
	if($1 ~ /[0-9]+/ && NF>5){
		en[i]=$3
		i++
	}
	
	}END{
	for (j=1; j<k; j++) {
		print en[j]
		print dx[j],dy[j],dz[j]
	}
	}' >> $out
   return 0
}

function grep_TERA_ioniz {
   local in1=$1
   local out=$2
   local en1
   local en2

   checkTERAioniz "$in1"
   if [[ "$?" -ne "0" ]];then
      return 1
   fi

   en1=$(grep "FINAL ENERGY" $in1 | tail -1| awk '{print $3}')
   en2=$(grep "FINAL ENERGY" $in1 | head -1| awk '{print $3}')
   awk -v en1=$en1 -v en2=$en2 'BEGIN{de=27.2114*(en1-en2);if(de<0) {print -de}else{print de};exit 0}' >> $out
   return 0
}

function grep_TERA_ioniz_exc {
   local in1=$1
   local out=$2
   local numstates=$3
   local in2=$4
   local en1
   local en2
   local nstate1

   checkTERA "$in1"
   if [[ "$?" -ne "0" ]];then
      return 1
   fi
   checkTERA "$in2"
   if [[ "$?" -ne "0" ]];then
      return 1
   fi

   en1=$(grep "FINAL ENERGY" $in1 | tail -1| awk '{print $3}')
   en2=$(grep "FINAL ENERGY" $in1 | head -1| awk '{print $3}')
   local de=$(awk -v en1=$en1 -v en2=$en2 'BEGIN{print 27.2114*(en1-en2);exit 0 }')
   echo $de >> $out
   
   let nstate1=numstates+3

   grep -A$nstate1 -e 'Final Excited State Results' $in2 | tail -$numstates | \
   awk -v numstates=$numstates -v de=$de 'BEGIN{
        i=1}
        {
         if (i<=numstates) {
           #getline
           en[i]=$3+de
           print en[i]
	   i++
        }
        }
        END{
        }' >> $out

   return 0
}

function checkTERA {
if [[ $( grep "Job finished:" $1 ) ]];then
   return 0
else
   return 1
fi
}

function checkTERAioniz {
local check1
local check2
check1=$( grep -c -h "Job finished:" $1 | head -1 )
check2=$( grep -c -h "Job finished:" $1 | tail -1 )
if [ $check1 -eq 1 ] && [ $check2 -eq 1 ];then
   return 0
else
   return 1
fi
}

# This function is specialized for single water molecule!
# Change EN0 and EN_SHIFT for your case
function grep_TERA_AES {
   local in=$1
   local numstates=$3
   local out=$2
   local nstate1

   checkTERA "$in"
   if [[ "$?" -ne "0" ]];then
      return 1
   fi


   # Normalization to lowest triplet energy in optimal geometry
   # 500.5 taken from Table 4, https://www.sciencedirect.com/science/article/pii/S0368204802002700

   # EN0 taken from ../../aes_1s_neutral_vdz.inp.out, first triplet 2h state
   EN0="-74.34809444"
   # Shift to experimental peak position
   EN_SHIFT="500.5"
   #en_GS=$(grep "FINAL ENERGY" $in | awk '{print $3}')

   egrep -E -e "^\s+[0-9]+\s+[13]\s+" -e "Triplet state\s+[1-9]" -e "Singlet state\s+[1-9]" $in |\
      awk -v nstates="$numstates" -v en0="$EN0" -v en_shift="$EN_SHIFT" \
      'BEGIN{k=0;i=0}{if ($4=="energy:") {en[k]=$5;k++
        } else {
          inten[i]=$3;i++
       }
      }
      END{
      for (i=0;i<nstates;i++) {
         energy = en_shift - 27.2114*(en[i]-en0)
         print energy, inten[i];
      }
      }' >> $out

}

